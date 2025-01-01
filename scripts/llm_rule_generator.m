function [rules, predicates] = llm_rule_generator(dataset, abnormalIdx, normalIdx, field_names, model_name)
    openai_config = struct(...
        'api_key', getenv('OPENAI_API_KEY'),...
        'model', 'gpt-4-turbo-preview',...
        'temperature', 0.7);
    
    metrics = extract_performance_metrics(dataset, field_names);
    patterns = analyze_anomaly_patterns(dataset.data, abnormalIdx, normalIdx);
    prompt = generate_diagnostic_prompt(metrics, patterns, model_name);
    llm_response = call_llm_api(prompt, openai_config);
    [rules, predicates] = parse_llm_rules(llm_response, field_names);
end 