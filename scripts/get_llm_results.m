function [llm_confidence, llm_fscore] = get_llm_results(dataset_name, num_discrete, diff_threshold, abnormal_multiplier)
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
    
    % Create model directory
    model_directory = [pwd '/causal_models'];
    mkdir(model_directory);
    
    % Set default parameters if not provided (match perform_evaluation_llm_enhanced)
    if nargin < 2 || isempty(num_discrete)
        num_discrete = 500;
    end
    if nargin < 3 || isempty(diff_threshold)
        diff_threshold = 0.2;
    end
    if nargin < 4 || isempty(abnormal_multiplier)
        abnormal_multiplier = 10;
    end
    
    % Initialize parameters
    num_cases = length(data.causes);
    llm_rules = cell(num_cases, 1);
    llm_confidence = cell(num_cases, num_cases);
    llm_fscore = cell(num_cases, num_cases);
    
    % Setup experiment parameters
    exp_param = ExperimentParameter();
    exp_param.num_discrete = num_discrete;
    exp_param.diff_threshold = diff_threshold;
    exp_param.abnormal_multiplier = abnormal_multiplier;
    exp_param.create_model = true;
    exp_param.use_llm_rules = true;
    exp_param.llm_only = true;
    
    fprintf('Starting evaluation with %d cases...\n', num_cases);
    
    % First generate all rules
    for i = 1:num_cases
        try
            exp_param.cause_string = data.causes{i};
            exp_param.model_name = ['llm_cause' num2str(i)];
            fprintf('Generating rules for case %d: %s\n', i, exp_param.cause_string);
            
            [rules, predicates] = llm_rule_generator(data.test_datasets{i}, ...
                data.abnormal_regions{i}, data.normal_regions{i}, exp_param);
            
            % Store both rules and predicates
            llm_rules{i}.rules = rules;
            llm_rules{i}.predicates = predicates;
            
            % Validate rules were generated
            if isempty(rules) || isempty(predicates)
                warning('No rules generated for case %d', i);
                continue;
            end
            
            pause(1); % Rate limiting for API calls
        catch e
            warning('Failed to generate rules for case %d: %s', i, e.message);
        end
    end
    
    % Then evaluate using stored rules
    for i = 1:num_cases
        if isempty(llm_rules{i}) || isempty(llm_rules{i}.predicates)
            warning('Skipping evaluation for case %d - no valid rules', i);
            continue;
        end
        
        exp_param.current_rules = llm_rules{i}.predicates;
        test_data = data.test_datasets{i};
        abnormal_regions = data.abnormal_regions{i};
        normal_regions = data.normal_regions{i};
        
        explanation = run_dbsherlock(test_data, abnormal_regions, normal_regions, [], exp_param);
        fprintf('Evaluating case %d, got %d explanations\n', i, size(explanation,1));
        
        % Check against all potential causes
        for k = 1:num_cases
            compare = strcmp(explanation, data.causes{k});
            idx = find(compare(:,1));
            if ~isempty(idx)
                llm_confidence{k,i}(end+1) = explanation{idx, 2};
                llm_fscore{k,i}(end+1) = explanation{idx, 4};
                fprintf('  Found match for cause %d with confidence=%.2f, fscore=%.2f\n', ...
                    k, explanation{idx, 2}, explanation{idx, 4});
            end
        end
    end
    
    % Convert cell arrays to vectors using max values
    conf_vec = zeros(num_cases, 1);
    fscore_vec = zeros(num_cases, 1);
    
    for i = 1:num_cases
        for k = 1:num_cases
            if ~isempty(llm_confidence{k,i})
                conf_vec(i) = max(conf_vec(i), max(llm_confidence{k,i}));
                fscore_vec(i) = max(fscore_vec(i), max(llm_fscore{k,i}));
            end
        end
        fprintf('Final metrics for case %d: confidence=%.2f, fscore=%.2f\n', ...
            i, conf_vec(i), fscore_vec(i));
    end
    
    % Validate results before returning
    if all(conf_vec == 0) || all(fscore_vec == 0)
        warning('All metrics are zero! Check the evaluation process.');
    end
    
    llm_confidence = conf_vec;
    llm_fscore = fscore_vec;
    
    % Clean up temporary models
    clearCausalModels(model_directory);
end 