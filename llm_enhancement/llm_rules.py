import numpy as np
from typing import List, Dict, Any
import openai
import pandas as pd
from sklearn.preprocessing import StandardScaler
import json
import plotly.graph_objects as go

class LLMRuleEnhancer:
    def __init__(self, api_key: str):
        """Initialize the LLM Rule Enhancer with OpenAI API key."""
        openai.api_key = api_key
        self.system_prompt = """You are an expert system for analyzing database performance anomalies.
        Your task is to generate precise rules to detect and explain database performance anomalies.
        
        Rules should follow this structure:
        {
            "name": "Clear descriptive name",
            "condition": "Python boolean expression using df[column_name]",
            "explanation": "Detailed technical explanation",
            "confidence": float between 0-1,
            "severity": "HIGH|MEDIUM|LOW",
            "remediation": "Steps to address the issue"
        }
        
        Example rules:
        [
            {
                "name": "High CPU Utilization Spike",
                "condition": "df['cpu_usage'] > 0.85 and df['cpu_usage'].diff() > 0.2",
                "explanation": "CPU usage spiked above 85% with a sudden increase of >20%",
                "confidence": 0.95,
                "severity": "HIGH",
                "remediation": "Check for resource-intensive queries, consider query optimization"
            },
            {
                "name": "Memory Pressure",
                "condition": "df['memory_used'] / df['memory_total'] > 0.9 and df['swap_used'].rolling(3).mean().diff() > 0",
                "explanation": "Memory usage >90% with increasing swap usage trend",
                "confidence": 0.9,
                "severity": "HIGH",
                "remediation": "Increase available memory, optimize memory-intensive queries"
            }
        ]
        
        Focus on:
        1. Statistical patterns and trends
        2. Correlations between metrics
        3. Rate of change and sudden spikes
        4. Resource utilization thresholds
        5. System bottlenecks"""
    
    def enhance_rules(self, metrics: pd.DataFrame, existing_rules: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Enhance existing rules using LLM insights.
        
        Args:
            metrics: DataFrame containing performance metrics
            existing_rules: List of existing rules from DBSherlock
            
        Returns:
            Enhanced rules with LLM-generated insights
        """
        # Prepare context for LLM
        context = self._prepare_context(metrics, existing_rules)
        
        # Generate enhanced rules using GPT-4
        response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": self.system_prompt},
                {"role": "user", "content": context}
            ],
            temperature=0.3,
            max_tokens=2000
        )
        
        # Parse and validate enhanced rules
        enhanced_rules = self._parse_llm_response(response.choices[0].message['content'])
        print("Enhanced rules:", json.dumps(enhanced_rules, indent=2))  # Debug print
        return enhanced_rules
    
    def _prepare_context(self, metrics: pd.DataFrame, existing_rules: List[Dict[str, Any]]) -> str:
        """Prepare enhanced context for LLM."""
        # Get numeric columns first
        numeric_columns = metrics.select_dtypes(include=[np.number]).columns
        
        # Calculate statistical summaries
        stats = metrics[numeric_columns].describe()
        correlations = metrics[numeric_columns].corr()
        changes = metrics[numeric_columns].diff().describe()
        
        # Identify top correlations
        top_correlations = []
        for col in correlations.columns:
            corrs = correlations[col].sort_values(ascending=False)
            top_correlations.extend([
                f"{col} strongly correlated with {other_col} (r={corr:.2f})"
                for other_col, corr in corrs.items()
                if corr < 1.0 and abs(corr) > 0.7
            ])

        context = f"""
        Performance Metrics Analysis:
        
        Statistical Summary:
        {stats.to_string()}
        
        Rate of Change Analysis:
        {changes.to_string()}
        
        Key Correlations:
        {chr(10).join(top_correlations)}
        
        Existing Rules:
        {json.dumps(existing_rules, indent=2)}
        
        Please analyze these patterns to:
        1. Generate precise anomaly detection rules
        2. Consider both absolute values and rates of change
        3. Include correlations between metrics
        4. Provide clear remediation steps
        5. Assign confidence levels based on statistical significance
        """
        return context
    
    def _parse_llm_response(self, response: str) -> List[Dict[str, Any]]:
        """Parse and validate LLM response into structured rules."""
        try:
            enhanced_rules = json.loads(response)
            # Validate rule structure
            for rule in enhanced_rules:
                required_fields = ['name', 'condition', 'explanation', 'confidence']
                if not all(field in rule for field in required_fields):
                    raise ValueError(f"Missing required fields in rule: {rule}")
            return enhanced_rules
        except json.JSONDecodeError:
            # Fallback parsing for non-JSON responses
            return self._fallback_parse(response)
    
    def _fallback_parse(self, response: str) -> List[Dict[str, Any]]:
        """Fallback parsing for non-JSON LLM responses."""
        rules = []
        current_rule = {}
        
        lines = response.split('\n')
        for line in lines:
            line = line.strip()
            if line.startswith('Rule:'):
                if current_rule:
                    rules.append(current_rule)
                current_rule = {'name': line[5:].strip()}
            elif line.startswith('Condition:'):
                current_rule['condition'] = line[10:].strip()
            elif line.startswith('Explanation:'):
                current_rule['explanation'] = line[12:].strip()
            elif line.startswith('Confidence:'):
                try:
                    current_rule['confidence'] = float(line[11:].strip())
                except ValueError:
                    current_rule['confidence'] = 0.5
                    
        if current_rule:
            rules.append(current_rule)
            
        return rules
    
    def _convert_matlab_rules(self, matlab_results: Any) -> List[Dict[str, Any]]:
        """Convert MATLAB rule format to our enhanced format."""
        rules = []
        try:
            for rule in matlab_results:
                # Convert and validate each field
                name = str(rule[0]) if rule[0] is not None else "Unknown Rule"
                condition = str(rule[1]) if rule[1] is not None else ""
                confidence = float(rule[2]) if rule[2] is not None else 0.0
                
                rules.append({
                    'name': name,
                    'condition': condition,
                    'confidence': confidence
                })
        except Exception as e:
            print(f"Error converting MATLAB rules: {str(e)}")
        return rules

class RuleEvaluator:
    def __init__(self):
        """Initialize the Rule Evaluator."""
        self.scaler = StandardScaler()
        
    def evaluate_rules(self, metrics_df: pd.DataFrame, rules: List[Dict[str, Any]]) -> Dict[str, Dict[str, float]]:
        """Evaluate rule effectiveness using statistical measures."""
        results = {}
        
        if not rules:
            print("Warning: No rules provided for evaluation")
            return results
        
        # Validate each rule has required fields
        valid_rules = []
        for i, rule in enumerate(rules):
            if not isinstance(rule, dict):
                print(f"Warning: Rule {i} is not a dictionary")
                continue
            if 'name' not in rule or 'condition' not in rule:
                print(f"Warning: Skipping rule {i} due to missing required fields: {rule}")
                continue
            valid_rules.append(rule)
        
        if not valid_rules:
            print("No valid rules found for evaluation")
            return results
        
        # Convert numpy array back to DataFrame for rule evaluation
        metrics = pd.DataFrame(metrics_df)
        
        for rule in valid_rules:
            try:
                # Replace df[] with actual DataFrame reference
                condition = rule['condition'].replace('df[', 'metrics[')
                # Apply rule condition
                mask = eval(condition, {'metrics': metrics, 'np': np})
                
                # Calculate rule effectiveness metrics
                precision = self._calculate_precision(mask, metrics)
                recall = self._calculate_recall(mask, metrics)
                f1_score = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
                
                results[rule['name']] = {
                    'precision': precision,
                    'recall': recall,
                    'f1_score': f1_score
                }
            except Exception as e:
                print(f"Error evaluating rule {rule['name']}: {str(e)}")
                results[rule['name']] = {
                    'precision': 0,
                    'recall': 0,
                    'f1_score': 0
                }
        
        return results
    
    def _calculate_precision(self, predicted_anomalies: np.ndarray, metrics: pd.DataFrame) -> float:
        """Calculate precision of rule predictions."""
        # This is a simplified version - in practice, you'd need actual anomaly labels
        return np.mean(predicted_anomalies)
    
    def _calculate_recall(self, predicted_anomalies: np.ndarray, metrics: pd.DataFrame) -> float:
        """Calculate recall of rule predictions."""
        # This is a simplified version - in practice, you'd need actual anomaly labels
        return np.sum(predicted_anomalies) / len(metrics) 

