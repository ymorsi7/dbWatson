import os
import scipy.io
import pandas as pd
import numpy as np
from typing import Dict, List, Any, Tuple
import matlab.engine
from llm_rules import LLMRuleEnhancer, RuleEvaluator
from visualization import EnhancedVisualizer
import json
from pathlib import Path

class DBSherlockEnhanced:
    def __init__(self, openai_api_key: str, matlab_workspace: str):
        """Initialize the enhanced DBSherlock system.
        
        Args:
            openai_api_key: OpenAI API key for LLM integration
            matlab_workspace: Path to MATLAB workspace
        """
        self.llm_enhancer = LLMRuleEnhancer(openai_api_key)
        self.rule_evaluator = RuleEvaluator()
        self.visualizer = EnhancedVisualizer()
        
        # Initialize MATLAB engine with proper error handling
        try:
            self.matlab_engine = matlab.engine.start_matlab()
            self.matlab_engine.addpath(matlab_workspace)
            # Add the scripts directory to MATLAB path
            scripts_path = os.path.join(matlab_workspace, 'scripts')
            self.matlab_engine.addpath(scripts_path)
        except Exception as e:
            raise RuntimeError(f"Failed to initialize MATLAB engine: {str(e)}")
        
    def process_dataset(self, dataset_path: str, output_dir: str) -> Dict[str, Any]:
        """Process a dataset through the enhanced pipeline.
        
        Args:
            dataset_path: Path to .mat dataset file
            output_dir: Directory to save results and visualizations
            
        Returns:
            Dictionary containing results and metrics
        """
        # Load and preprocess data
        data = self._load_matlab_data(dataset_path)
        metrics_df = self._convert_to_pandas(data)
        
        # Get original DBSherlock rules
        original_rules = self._run_dbsherlock_analysis(data)
        
        # Enhance rules using LLM
        enhanced_rules = self.llm_enhancer.enhance_rules(metrics_df, original_rules)
        
        # Evaluate rules
        original_metrics = self.rule_evaluator.evaluate_rules(metrics_df, original_rules)
        enhanced_metrics = self.rule_evaluator.evaluate_rules(metrics_df, enhanced_rules)
        
        # Generate visualizations
        self._generate_visualizations(metrics_df, original_rules, enhanced_rules,
                                   original_metrics, enhanced_metrics, output_dir)
        
        # Prepare and save results
        results = {
            'original_rules': original_rules,
            'enhanced_rules': enhanced_rules,
            'original_metrics': original_metrics,
            'enhanced_metrics': enhanced_metrics
        }
        
        self._save_results(results, output_dir)
        return results
    
    def _load_matlab_data(self, dataset_path: str) -> Dict[str, Any]:
        """Load MATLAB dataset file."""
        return scipy.io.loadmat(dataset_path)
    
    def _convert_to_pandas(self, matlab_data: Dict[str, Any]) -> pd.DataFrame:
        """Convert MATLAB data structure to pandas DataFrame."""
        test_datasets = matlab_data['test_datasets']
        metrics_list = []
        causes = matlab_data['causes']
        
        # Iterate through the cell structure
        for i in range(test_datasets.shape[0]):  # 10 test cases
            for j in range(test_datasets.shape[1]):  # 11 time durations
                if test_datasets[i,j].size > 0:
                    metrics = test_datasets[i,j]
                    data = metrics if isinstance(metrics, np.ndarray) else metrics.data
                    
                    if len(data) > 0:
                        # Add metadata
                        metrics_dict = {
                            'test_case': i,
                            'cause': causes[i][0] if i < len(causes) else f'unknown_{i}',
                            'duration': 30 + (j * 5),  # 30 to 80 seconds in 5-second increments
                            'is_normal': 0 if i in matlab_data['abnormal_regions'] else 1
                        }
                        
                        # Add metrics using field names if available
                        field_names = matlab_data.get('field_names', [])
                        for k, value in enumerate(data[0]):
                            field_name = field_names[k] if k < len(field_names) else f'metric_{k}'
                            metrics_dict[field_name] = value
                            
                        metrics_list.append(metrics_dict)
        
        return pd.DataFrame(metrics_list)
    
    def _run_dbsherlock_analysis(self, data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Run original DBSherlock analysis using MATLAB engine."""
        try:
            # Convert Python data structure to MATLAB
            matlab_data = {
                'data': self.matlab_engine.double(data['test_datasets'].tolist()),
                'field_names': data['field_names'],
                'abnormal_regions': data['abnormal_regions'],
                'normal_regions': data['normal_regions']
            }
            
            # Create ExperimentParameter object in MATLAB
            exp_param = self.matlab_engine.eval('ExperimentParameter')
            
            # Run DBSherlock analysis
            results = self.matlab_engine.run_dbsherlock(
                matlab_data, 
                data['abnormal_regions'], 
                data['normal_regions'],
                [], # empty attribute_types
                exp_param,
                nargout=5  # Number of output arguments
            )
            
            return self._convert_matlab_rules(results[0])  # Only take explanation results
        except Exception as e:
            print(f"Error running MATLAB analysis: {str(e)}")
            return []
    
    def _convert_matlab_rules(self, matlab_results: Any) -> List[Dict[str, Any]]:
        """Convert MATLAB rule format to our enhanced format."""
        rules = []
        # Convert MATLAB cell arrays to Python dictionaries
        # This needs to be adapted based on your specific rule format
        for rule in matlab_results:
            rules.append({
                'name': str(rule[0]),
                'condition': str(rule[1]),
                'confidence': float(rule[2])
            })
        return rules
    
    def _generate_visualizations(self, metrics_df: pd.DataFrame,
                               original_rules: List[Dict[str, Any]],
                               enhanced_rules: List[Dict[str, Any]],
                               original_metrics: Dict[str, Dict[str, float]],
                               enhanced_metrics: Dict[str, Dict[str, float]],
                               output_dir: str):
        """Generate and save all visualizations."""
        try:
            Path(output_dir).mkdir(parents=True, exist_ok=True)
            
            # Check if required columns exist
            if 'is_normal' not in metrics_df.columns:
                metrics_df['is_normal'] = 0  # Default to abnormal
                
            # Generate visualizations
            fig_metrics = self.visualizer.plot_metric_comparison(
                metrics_df[metrics_df['is_normal'] == 1],
                metrics_df[metrics_df['is_normal'] == 0],
                enhanced_rules
            )
            fig_metrics.write_html(os.path.join(output_dir, 'metric_comparison.html'))
            
            # Generate rule effectiveness comparison
            fig_rules = self.visualizer.plot_rule_effectiveness({
                'Original Rules': original_metrics,
                'Enhanced Rules': enhanced_metrics
            })
            fig_rules.write_html(os.path.join(output_dir, 'rule_effectiveness.html'))
            
            # Generate correlation matrix
            fig_corr = self.visualizer.plot_correlation_matrix(metrics_df)
            fig_corr.write_html(os.path.join(output_dir, 'correlation_matrix.html'))
            
        except Exception as e:
            print(f"Error generating visualizations: {str(e)}")
    
    def _save_results(self, results: Dict[str, Any], output_dir: str):
        """Save analysis results to files."""
        output_path = os.path.join(output_dir, 'analysis_results.json')
        with open(output_path, 'w') as f:
            json.dump(results, f, indent=2)
            
    def __del__(self):
        """Cleanup MATLAB engine on deletion."""
        if hasattr(self, 'matlab_engine'):
            self.matlab_engine.quit()

def main():
    """Main function to run the enhanced DBSherlock analysis."""
    # Configuration
    OPENAI_API_KEY = os.getenv('OPENAI_API_KEY')
    if not OPENAI_API_KEY:
        raise ValueError("Please set the OPENAI_API_KEY environment variable")
    
    MATLAB_WORKSPACE = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    DATASET_PATH = os.path.join(MATLAB_WORKSPACE, 'datasets', 'dbsherlock_dataset_tpcc_16w.mat')
    OUTPUT_DIR = os.path.join(MATLAB_WORKSPACE, 'results')
    
    # Initialize and run analysis
    dbsherlock = DBSherlockEnhanced(OPENAI_API_KEY, MATLAB_WORKSPACE)
    results = dbsherlock.process_dataset(DATASET_PATH, OUTPUT_DIR)
    
    print("Analysis completed. Results saved to:", OUTPUT_DIR)
    
if __name__ == "__main__":
    main() 