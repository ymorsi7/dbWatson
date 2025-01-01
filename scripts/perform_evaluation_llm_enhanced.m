function [confidence, fscore] = perform_evaluation_llm_enhanced(dataset_name, num_discrete, diff_threshold, abnormal_multiplier)
    % Load dataset
    data = load(['datasets/' dataset_name]);
    
    % Initialize parameters
    llm_param = LLMExperimentParameter();
    llm_param.use_llm_rules = true;
    llm_param.create_model = true;
    
    % Learn patterns from historical data
    historical_patterns = llm_pattern_learner(data.test_datasets, data.causes);
    
    % Enhance existing rules with learned patterns
    enhanced_rules = combine_rules(load_template_rules(), historical_patterns);
    
    % Run evaluation with enhanced rules
    [confidence, fscore] = evaluate_with_enhanced_rules(data, enhanced_rules, llm_param);
end

function enhanced_rules = combine_rules(template_rules, learned_patterns)
    enhanced_rules = struct();
    fields = fieldnames(template_rules);
    
    for i = 1:length(fields)
        field = fields{i};
        enhanced_rules.(field) = struct(...
            'base_rule', template_rules.(field),...
            'learned_patterns', learned_patterns.(field),...
            'combined_pattern', combine_patterns(template_rules.(field), learned_patterns.(field))...
        );
    end
end 