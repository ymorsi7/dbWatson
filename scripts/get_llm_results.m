function [llm_confidence, llm_fscore] = get_llm_results(dataset_name)
    % Check if OPENAI_API_KEY is set
    if isempty(getenv('OPENAI_API_KEY'))
        error('OPENAI_API_KEY environment variable is not set');
    end
    
    % Load dataset with correct path
    try
        data = load(['datasets/' dataset_name]);
    catch e
        error('Dataset not found: %s. Error: %s', dataset_name, e.message);
    end
    
    % Initialize LLM parameters with same defaults as perform_evaluation_llm_enhanced
    exp_param = ExperimentParameter();
    exp_param.num_discrete = 500;
    exp_param.diff_threshold = 0.2;
    exp_param.abnormal_multiplier = 10;
    exp_param.create_model = true;
    exp_param.use_llm_rules = true;
    exp_param.llm_only = true;
    
    % Generate and store LLM rules
    num_cases = length(data.causes);
    llm_rules = cell(num_cases, 1);
    llm_confidence = cell(num_cases, num_cases);
    llm_fscore = cell(num_cases, num_cases);
    
    for i = 1:num_cases
        try
            % Generate rules using LLM
            exp_param.cause_string = data.causes{i};
            exp_param.model_name = ['llm_cause' num2str(i)];
            
            [rules, predicates] = llm_rule_generator(data.test_datasets{i}, ...
                data.abnormal_regions{i}, data.normal_regions{i}, exp_param);
            
            if ~isempty(rules) && ~isempty(predicates)
                exp_param.current_rules = predicates;
                explanation = run_dbsherlock(data.test_datasets{i}, ...
                    data.abnormal_regions{i}, data.normal_regions{i}, [], exp_param);
                
                % Check against all potential causes
                for k = 1:num_cases
                    compare = strcmp(explanation, data.causes{k});
                    idx = find(compare(:,1));
                    if ~isempty(idx)
                        llm_confidence{k,i}(end+1) = explanation{idx, 2};
                        llm_fscore{k,i}(end+1) = explanation{idx, 4};
                    end
                end
            else
                warning('No valid rules generated for case %d', i);
            end
            
            pause(1); % Rate limiting
        catch e
            warning('Failed to evaluate case %d: %s', i, e.message);
        end
    end
    
    % Convert cell arrays to vectors using max values (for compatibility)
    conf_vec = zeros(num_cases, 1);
    fscore_vec = zeros(num_cases, 1);
    
    for i = 1:num_cases
        max_conf = 0;
        max_fscore = 0;
        for j = 1:num_cases
            if ~isempty(llm_confidence{i,j})
                max_conf = max(max_conf, max(llm_confidence{i,j}));
                max_fscore = max(max_fscore, max(llm_fscore{i,j}));
            end
        end
        conf_vec(i) = max_conf;
        fscore_vec(i) = max_fscore;
    end
    
    llm_confidence = conf_vec;
    llm_fscore = fscore_vec;
end 