function prompt = generate_diagnostic_prompt(metrics, patterns, model_name)
    prompt = sprintf('Analyze performance metrics for model %s:\n', model_name);
    prompt = [prompt 'Metrics:\n' jsonencode(metrics) '\n'];
    prompt = [prompt 'Patterns:\n' jsonencode(patterns) '\n'];
    prompt = [prompt 'Generate diagnostic rules based on these patterns.'];
end 