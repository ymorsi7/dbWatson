function [confidence, fscore] = evaluate_original_models(dataset_name)
    % Load dataset
    data = load(['datasets/' dataset_name]);
    model_directory = [pwd '/causal_models'];
    mkdir(model_directory);
    
    % Initialize parameters
    num_case = size(data.test_datasets, 1);
    confidence = zeros(num_case, 1);
    fscore = zeros(num_case, 1);
    
    % Setup experiment parameters
    exp_param = ExperimentParameter();
    exp_param.create_model = true;
    
    fprintf('Starting original model evaluation with %d cases...\n', num_case);
    
    % Generate and evaluate each case
    for i = 1:num_case
        exp_param.cause_string = data.causes{i};
        exp_param.model_name = ['orig_cause' num2str(i)];
        
        % Run evaluation
        test_data = data.test_datasets{i};
        abnormal_regions = data.abnormal_regions{i};
        normal_regions = data.normal_regions{i};
        
        explanation = run_dbsherlock(test_data, abnormal_regions, normal_regions, [], exp_param);
        
        if ~isempty(explanation)
            confidence(i) = explanation{1, 2};  % confidence score
            fscore(i) = explanation{1, 4};      % f1-measure
            fprintf('Case %d: confidence=%.2f, fscore=%.2f\n', i, confidence(i), fscore(i));
        end
    end
    
    % Clean up
    clearCausalModels(model_directory);
end 