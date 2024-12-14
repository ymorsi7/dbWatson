function [confidence, fscore, enhanced_metrics] = perform_evaluation_causal_models(dataset_name, num_discrete, diff_threshold)

  data = load(['datasets/' dataset_name]);
  model_directory = [pwd '/causal_models'];
  mkdir(model_directory);

  num_case = size(data.test_datasets, 1);
  num_samples = size(data.test_datasets, 2);

  confidence = cell(num_case, num_case);
  fscore = cell(num_case, num_case);

  causes = data.causes;

  if isempty(num_discrete)
    num_discrete = 500;
  end
  if isempty(diff_threshold)
    diff_threshold = 0.2;
  end

  train_param = ExperimentParameter;
  test_param = ExperimentParameter;
  train_param.create_model = true;

  if ~isempty(num_discrete)
    train_param.num_discrete = num_discrete;
    test_param.num_discrete = num_discrete;
  end
  if ~isempty(diff_threshold)
    train_param.diff_threshold = diff_threshold;
    test_param.diff_threshold = diff_threshold;
  end

  % Initialize enhanced metrics structure
  enhanced_metrics = struct();

  for i=1:num_case
    for test_idx=1:num_samples
      % Get enhanced DBSherlock analysis
      [explanation, metrics, patterns, correlations] = run_dbsherlock(...
        data.test_datasets{i,test_idx}, ...
        data.abnormal_regions{i,test_idx}, ...
        data.normal_regions{i,test_idx}, ...
        [], test_param);
      
      % Store enhanced metrics for LLM analysis
      enhanced_metrics(i,test_idx) = struct(...
        'explanation', explanation, ...
        'metrics', metrics, ...
        'patterns', patterns, ...
        'correlations', correlations ...
      );
    end
  end
end
