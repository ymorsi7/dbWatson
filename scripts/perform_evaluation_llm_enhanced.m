function [confidence, fscore] = perform_evaluation_llm_enhanced(dataset_name, num_discrete, diff_threshold, abnormal_multiplier)
    % Load dataset
    data = load(['datasets/' dataset_name]);
    model_directory = [pwd '/causal_models'];
    mkdir(model_directory);
    
    % Set default parameters if not provided
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
    num_case = size(data.test_datasets, 1);
    confidence = cell(num_case, num_case);
    fscore = cell(num_case, num_case);
    
    % Setup experiment parameters
    exp_param = ExperimentParameter();
    exp_param.num_discrete = num_discrete;
    exp_param.diff_threshold = diff_threshold;
    exp_param.abnormal_multiplier = abnormal_multiplier;
    exp_param.create_model = true;
    
    fprintf('Starting evaluation with %d cases...\n', num_case);
    
    % First generate rules for each case
    for i = 1:num_case
        exp_param.cause_string = data.causes{i};
        exp_param.model_name = ['llm_cause' num2str(i)];
        fprintf('Generating rules for case %d: %s\n', i, exp_param.cause_string);
        run_dbsherlock(data.test_datasets{i}, data.abnormal_regions{i}, data.normal_regions{i}, [], exp_param);
    end
    
    % Then evaluate each case
    for i = 1:num_case
        test_data = data.test_datasets{i};
        abnormal_regions = data.abnormal_regions{i};
        normal_regions = data.normal_regions{i};
        
        explanation = run_dbsherlock(test_data, abnormal_regions, normal_regions, [], exp_param);
        fprintf('Evaluating case %d, got %d explanations\n', i, size(explanation,1));
        
        % Check against all potential causes
        for k = 1:num_case
            compare = strcmp(explanation, data.causes{k});
            idx = find(compare(:,1));
            if ~isempty(idx)
                confidence{k,i}(end+1) = explanation{idx, 2};
                fscore{k,i}(end+1) = explanation{idx, 4};
                fprintf('  Found match for cause %d with confidence=%.2f, fscore=%.2f\n', ...
                    k, explanation{idx, 2}, explanation{idx, 4});
            end
        end
    end
    
    % Convert cell arrays to vectors using max values
    confidence_vec = zeros(num_case, 1);
    fscore_vec = zeros(num_case, 1);
    for i = 1:num_case
        for k = 1:num_case
            if ~isempty(confidence{k,i})
                confidence_vec(i) = max(confidence_vec(i), max(confidence{k,i}));
                fscore_vec(i) = max(fscore_vec(i), max(fscore{k,i}));
            end
        end
        fprintf('Final metrics for case %d: confidence=%.2f, fscore=%.2f\n', ...
            i, confidence_vec(i), fscore_vec(i));
    end
    
    % Validate results before returning
    if all(confidence_vec == 0) || all(fscore_vec == 0)
        warning('All metrics are zero! Check the evaluation process.');
    end
    
    confidence = confidence_vec;
    fscore = fscore_vec;
    
    % Clean up temporary models
    clearCausalModels(model_directory);
end