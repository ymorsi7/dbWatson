function prompt = generate_diagnostic_prompt(metrics, patterns, model_name)
    % Create a structured prompt for the LLM
    prompt = sprintf('Analyze the following performance metrics and patterns for %s:\n\n', model_name);
    
    % Add metrics information
    prompt = [prompt 'Performance Metrics:\n'];
    fields = fieldnames(metrics);
    for i = 1:length(fields)
        field = fields{i};
        m = metrics.(field);
        prompt = [prompt sprintf('%s: mean=%.2f, std=%.2f, min=%.2f, max=%.2f\n', ...
            field, m.mean, m.std, m.min, m.max)];
    end
    
    % Add pattern information
    prompt = [prompt '\nObserved Patterns:\n'];
    prompt = [prompt sprintf('Abnormal patterns: mean_diff=%.2f, std_ratio=%.2f\n', ...
        patterns.deviations.mean_diff(1), patterns.deviations.std_ratio(1))];
    
    % Request for analysis
    prompt = [prompt '\nBased on these metrics and patterns, please:'];
    prompt = [prompt '\n1. Identify potential performance anomalies'];
    prompt = [prompt '\n2. Generate rules to detect similar issues'];
    prompt = [prompt '\n3. Format response as JSON with "rules" array containing conditions'];
    
    return;
end 