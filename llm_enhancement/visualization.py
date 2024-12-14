import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
import pandas as pd
import numpy as np
from typing import List, Dict, Any

class EnhancedVisualizer:
    def __init__(self, theme: str = 'plotly_dark'):
        """Initialize the Enhanced Visualizer.
        
        Args:
            theme: Plotly theme to use for plots
        """
        self.theme = theme
        
    def plot_metric_comparison(self, normal_metrics: pd.DataFrame, anomaly_metrics: pd.DataFrame,
                             rules: List[Dict[str, Any]], title: str = "Metric Comparison") -> go.Figure:
        """Create an interactive comparison plot of normal vs anomaly metrics with rule highlights."""
        # Create subplots for each metric
        n_metrics = len(normal_metrics.columns)
        fig = make_subplots(rows=n_metrics, cols=1, subplot_titles=normal_metrics.columns,
                           vertical_spacing=0.05)
        
        for i, metric in enumerate(normal_metrics.columns, 1):
            # Plot normal data
            fig.add_trace(
                go.Scatter(x=normal_metrics.index, y=normal_metrics[metric],
                          name=f"Normal {metric}", line=dict(color='blue', width=1)),
                row=i, col=1
            )
            
            # Plot anomaly data
            fig.add_trace(
                go.Scatter(x=anomaly_metrics.index, y=anomaly_metrics[metric],
                          name=f"Anomaly {metric}", line=dict(color='red', width=1)),
                row=i, col=1
            )
            
            # Add rule thresholds if applicable
            for rule in rules:
                if metric in rule['condition']:
                    threshold = self._extract_threshold(rule['condition'], metric)
                    if threshold:
                        fig.add_hline(y=threshold, line_dash="dash", line_color="green",
                                    annotation_text=f"Rule: {rule['name']}", row=i, col=1)
        
        fig.update_layout(
            height=300 * n_metrics,
            title_text=title,
            showlegend=True,
            template=self.theme
        )
        
        return fig
    
    def plot_rule_effectiveness(self, rule_metrics: Dict[str, Dict[str, float]]) -> go.Figure:
        """Create an interactive bar plot showing rule effectiveness metrics."""
        rules = list(rule_metrics.keys())
        metrics = ['precision', 'recall', 'f1_score']
        
        fig = go.Figure()
        
        for metric in metrics:
            values = [rule_metrics[rule][metric] for rule in rules]
            fig.add_trace(
                go.Bar(name=metric.capitalize(), x=rules, y=values)
            )
        
        fig.update_layout(
            barmode='group',
            title="Rule Effectiveness Metrics",
            xaxis_title="Rules",
            yaxis_title="Score",
            template=self.theme
        )
        
        return fig
    
    def plot_anomaly_timeline(self, metrics: pd.DataFrame, rules: List[Dict[str, Any]],
                            anomaly_regions: List[Dict[str, Any]]) -> go.Figure:
        """Create an interactive timeline showing metrics and detected anomalies."""
        fig = go.Figure()
        
        # Plot base metrics
        for column in metrics.columns:
            fig.add_trace(
                go.Scatter(x=metrics.index, y=metrics[column],
                          name=column, line=dict(width=1))
            )
        
        # Add anomaly regions as highlighted areas
        for region in anomaly_regions:
            fig.add_vrect(
                x0=region['start_time'],
                x1=region['end_time'],
                fillcolor="red",
                opacity=0.2,
                layer="below",
                line_width=0,
                annotation_text=region.get('cause', 'Unknown Anomaly')
            )
        
        fig.update_layout(
            title="Anomaly Timeline",
            xaxis_title="Time",
            yaxis_title="Metric Value",
            template=self.theme,
            showlegend=True
        )
        
        return fig
    
    def _extract_threshold(self, condition: str, metric: str) -> float:
        """Extract threshold value from rule condition for a specific metric."""
        try:
            # This is a simple parser - in practice you'd want a more robust solution
            if '>' in condition:
                return float(condition.split('>')[-1].strip())
            elif '<' in condition:
                return float(condition.split('<')[-1].strip())
            return None
        except:
            return None
    
    def plot_correlation_matrix(self, metrics: pd.DataFrame) -> go.Figure:
        """Create an interactive correlation matrix heatmap."""
        corr_matrix = metrics.corr()
        
        fig = go.Figure(data=go.Heatmap(
            z=corr_matrix,
            x=corr_matrix.columns,
            y=corr_matrix.columns,
            colorscale='RdBu',
            zmid=0,
            text=np.round(corr_matrix, 2),
            texttemplate='%{text}',
            textfont={"size": 10},
            hoverongaps=False
        ))
        
        fig.update_layout(
            title="Metric Correlation Matrix",
            template=self.theme,
            height=800,
            width=800
        )
        
        return fig 