import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
import pandas as pd
import numpy as np
from typing import List, Dict, Any

class EnhancedVisualizer:
    def __init__(self):
        """Initialize the visualizer."""
        self.theme = 'plotly_white'  # Set default theme
        self.colors = px.colors.qualitative.Set3
        
    def plot_metric_comparison(self, normal_metrics: pd.DataFrame, 
                             anomaly_metrics: pd.DataFrame,
                             rules: List[Dict[str, Any]]) -> go.Figure:
        """Create an enhanced metric comparison visualization."""
        fig = make_subplots(rows=len(normal_metrics.columns), cols=1,
                           subplot_titles=normal_metrics.columns,
                           vertical_spacing=0.05)
        
        for i, metric in enumerate(normal_metrics.columns, 1):
            # Add normal data with confidence intervals
            normal_mean = normal_metrics[metric].rolling(5).mean()
            normal_std = normal_metrics[metric].rolling(5).std()
            
            fig.add_trace(
                go.Scatter(
                    x=normal_metrics.index,
                    y=normal_mean,
                    name=f"Normal {metric}",
                    line=dict(color='blue', width=1)
                ), row=i, col=1
            )
            
            # Add confidence intervals
            fig.add_trace(
                go.Scatter(
                    x=normal_metrics.index,
                    y=normal_mean + 2*normal_std,
                    fill=None,
                    mode='lines',
                    line=dict(width=0),
                    showlegend=False
                ), row=i, col=1
            )
            
            fig.add_trace(
                go.Scatter(
                    x=normal_metrics.index,
                    y=normal_mean - 2*normal_std,
                    fill='tonexty',
                    mode='lines',
                    line=dict(width=0),
                    name='95% Confidence',
                    fillcolor='rgba(0, 0, 255, 0.1)'
                ), row=i, col=1
            )
            
            # Add anomaly points with hover info
            fig.add_trace(
                go.Scatter(
                    x=anomaly_metrics.index,
                    y=anomaly_metrics[metric],
                    mode='markers',
                    name=f"Anomaly {metric}",
                    marker=dict(
                        color='red',
                        size=8,
                        symbol='x'
                    ),
                    hovertemplate="Time: %{x}<br>" +
                                f"{metric}: %{y:.2f}<br>" +
                                "Anomaly<extra></extra>"
                ), row=i, col=1
            )

        fig.update_layout(
            height=300 * len(normal_metrics.columns),
            template=self.theme,
            showlegend=True,
            title={
                'text': "Metric Comparison with Anomaly Detection",
                'y':0.95,
                'x':0.5,
                'xanchor': 'center',
                'yanchor': 'top'
            }
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