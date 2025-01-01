function prompt = generate_learning_prompt(patterns)
    prompt = sprintf(['Analyze these database performance patterns:\n\n%s\n\n', ...
                     'Generate diagnostic rules focusing on:\n', ...
                     '1. Multi-metric correlations and their thresholds\n', ...
                     '2. Time-series patterns (trends, seasonality, changepoints)\n', ...
                     '3. Statistical anomalies and their significance\n', ...
                     '4. Complex relationships between metrics\n\n', ...
                     'Format response as JSON with:\n', ...
                     '- "patterns": discovered patterns\n', ...
                     '- "rules": diagnostic rules\n', ...
                     '- "confidence": confidence score for each pattern'], ...
                     jsonencode(patterns));
end 