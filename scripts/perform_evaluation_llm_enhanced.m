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
    confidence = zeros(num_case, 1);
    fscore = zeros(num_case, 1);
    
    % Setup experiment parameters with LLM configuration
    exp_param = LLMExperimentParameter();
    exp_param.num_discrete = num_discrete;
    exp_param.diff_threshold = diff_threshold;
    exp_param.abnormal_multiplier = abnormal_multiplier;
    
    % Process each test case
    for i = 1:num_case
        % Get current test dataset and regions
        test_data = data.test_datasets{i};
        abnormal_regions = data.abnormal_regions{i};
        normal_regions = data.normal_regions{i};
        
        % Set cause string for model naming
        exp_param.cause_string = data.causes{i};
        exp_param.model_name = ['cause' num2str(i)];
        
        % Run DBSherlock with LLM enhancement
        explanation = run_dbsherlock(test_data, abnormal_regions, normal_regions, [], exp_param);
        
        % Extract metrics from explanation
        if ~isempty(explanation)
            confidence(i) = explanation{1, 2};  % confidence score
            fscore(i) = explanation{1, 4};      % f1-measure
        end
    end
    
    % Clean up temporary models
    clearCausalModels(model_directory);
end 