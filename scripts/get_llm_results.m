function [llm_confidence, llm_fscore] = get_llm_results(dataset, case_names)
    % Check if OPENAI_API_KEY is set
    if isempty(getenv('OPENAI_API_KEY'))
        error('OPENAI_API_KEY environment variable is not set');
    end
    
    % Initialize LLM parameters
    exp_param = ExperimentParameter();
    exp_param.create_model = true;
    exp_param.use_llm_rules = true;
    
    % Load dataset
    data = load(dataset);
    
    % Get enhanced rules using LLM
    enhanced_rules = cell(size(data.causes));
    for i = 1:length(data.causes)
        try
            enhanced_rules{i} = llm_rule_generator(data.causes{i}, ...
                data.test_datasets{i}, data.abnormal_regions{i});
            pause(1); % Rate limiting
        catch e
            warning('Failed to generate rules for case %d: %s', i, e.message);
        end
    end
    
    % Evaluate with enhanced rules
    [llm_confidence, llm_fscore] = evaluate_with_enhanced_rules(data, enhanced_rules, exp_param);
    
    % Verify results are valid
    if isempty(llm_confidence) || all(llm_confidence == 0) || ...
       isempty(llm_fscore) || all(llm_fscore == 0)
        error('LLM evaluation returned no valid results');
    end
end 