import numpy as np
from typing import List, Dict, Any
import openai
import pandas as pd
from sklearn.preprocessing import StandardScaler
import json

class LLMRuleEnhancer:
    def __init__(self, api_key: str):
        """Initialize the LLM Rule Enhancer with OpenAI API key."""
        openai.api_key = api_key
        self.system_prompt = """You are an expert system for analyzing database performance anomalies.
        Given performance metrics and patterns, generate precise rules to explain anomalies.
        Focus on actionable insights and clear explanations."""
    
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
        return enhanced_rules
    
    def _prepare_context(self, metrics: pd.DataFrame, existing_rules: List[Dict[str, Any]]) -> str:
        """Prepare context for LLM by combining metrics and existing rules."""
        # Calculate statistical summaries
        stats = metrics.describe()
        
        # Format existing rules
        rules_str = json.dumps(existing_rules, indent=2)
        
        context = f"""
        Performance Metrics Summary:
        {stats.to_string()}
        
        Existing Rules:
        {rules_str}
        
        Please analyze these metrics and existing rules to:
        1. Enhance rule precision by adding statistical thresholds
        2. Add natural language explanations for each rule
        3. Suggest new rules based on patterns in the metrics
        4. Prioritize rules by their likelihood of identifying true anomalies
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

class RuleEvaluator:
    def __init__(self):
        """Initialize the Rule Evaluator."""
        self.scaler = StandardScaler()
        
    def evaluate_rules(self, metrics: pd.DataFrame, rules: List[Dict[str, Any]]) -> Dict[str, float]:
        """Evaluate rule effectiveness using statistical measures."""
        results = {}
        
        # Scale metrics for consistent evaluation
        scaled_metrics = pd.DataFrame(
            self.scaler.fit_transform(metrics),
            columns=metrics.columns
        )
        
        for rule in rules:
            try:
                # Apply rule condition
                mask = eval(rule['condition'], {'df': scaled_metrics, 'np': np})
                
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