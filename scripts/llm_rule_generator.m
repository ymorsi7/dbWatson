function [rules, predicates] = llm_rule_generator(dataset, abnormalIdx, normalIdx, field_names, model_name)
    % Check if OPENAI_API_KEY is set
    if isempty(getenv('OPENAI_API_KEY'))
        error('OPENAI_API_KEY environment variable is not set');
    end
    
    % Initialize outputs
    rules = struct('rules', []);
    predicates = cell(0, 8);
    
    try
        % Extract metrics and patterns
        metrics = extract_metrics(dataset.data, field_names);
        patterns = extract_patterns(dataset.data, abnormalIdx, normalIdx);
        
        % Generate and send prompt to OpenAI
        prompt = generate_prompt(metrics, patterns, model_name);
        response = call_openai(prompt);
        
        % Parse response into predicates format
        [rules, predicates] = parse_llm_rules(response, field_names);
    catch e
        warning('LLM rule generation failed: %s', e.message);
    end
end

function metrics = extract_metrics(data, field_names)
    metrics = struct();
    for i = 1:length(field_names)
        metrics.(field_names{i}) = struct(...
            'mean', mean(data(:,i)),...
            'std', std(data(:,i)));
    end
end

function patterns = extract_patterns(data, abnormalIdx, normalIdx)
    abnormal_data = data(abnormalIdx, :);
    normal_data = data(normalIdx, :);
    patterns = struct(...
        'abnormal_mean', mean(abnormal_data),...
        'normal_mean', mean(normal_data),...
        'abnormal_std', std(abnormal_data),...
        'normal_std', std(normal_data));
end

function prompt = generate_prompt(metrics, patterns, model_name)
    prompt = sprintf('Analyze metrics for %s:\n%s\nPatterns:\n%s', ...
        model_name, jsonencode(metrics), jsonencode(patterns));
end

function response = call_openai(prompt)
    response = webwrite('https://api.openai.com/v1/chat/completions', ...
        struct(...
            'model', 'gpt-4-turbo-preview',...
            'messages', {[struct('role', 'user', 'content', prompt)]},...
            'temperature', 0.7), ...
        weboptions('HeaderFields', {...
            'Authorization', ['Bearer ' getenv('OPENAI_API_KEY')],...
            'Content-Type', 'application/json'}));
    response = response.choices(1).message.content;
end 