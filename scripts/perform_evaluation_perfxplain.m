function [prec_dbseer, recl_dbseer, f_dbseer, prec_perfxplain, recl_perfxplain, f_perfxplain, prec_llm, recl_llm, f_llm] = perform_evaluation_perfxplain(dataset_name)
    if nargin < 1
        dataset_name = 'dbsherlock_dataset_tpcc_16w.mat';
    end
    
    % Set default parameters
    num_discrete = 500;
    diff_threshold = 0.2;
    abnormal_multiplier = 10;
    
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
    if isempty(abnormal_multiplier)
        abnormal_multiplier = 10;
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
    if ~isempty(abnormal_multiplier)
        train_param.abnormal_multiplier = abnormal_multiplier;
        test_param.abnormal_multiplier = abnormal_multiplier;
    end

    prec_dbseer = {};
    recl_dbseer = {};
    f_dbseer = {};
    prec_perfxplain = {};
    recl_perfxplain = {};
    f_perfxplain = {};
    prec_llm = {};
    recl_llm = {};
    f_llm = {};

    for i=1:num_case
        prec_perfxplain{i} = [];
        recl_perfxplain{i} = [];
        f_perfxplain{i} = [];
        prec_dbseer{i} = [];
        recl_dbseer{i} = [];
        f_dbseer{i} = [];
        prec_llm{i} = [];
        recl_llm{i} = [];
        f_llm{i} = [];
    end

    % Get LLM results once for comparison
    [llm_conf, llm_fscore] = get_llm_results(dataset_name);

    for batch=1:num_samples

        samples = [1:num_samples];
        test_samples = batch;
        samples(ismember(samples,test_samples)) = [];
        train_samples = samples;

        clearCausalModels(model_directory);

        % construct a causal model from a number of training samples.
        for i=1:num_case
            trainMatrix = []; % for perfxplain
            testMatrix = data.test_datasets{i,batch}.data; % for perfxplain
            for j=1:size(train_samples,2)
                train_idx = train_samples(j);
                train_param.cause_string = causes{i};
                train_param.model_name = ['cause' num2str(i) '-' num2str(train_idx)];
                trainMatrix = vertcat(trainMatrix, data.test_datasets{i,train_idx}.data);
                run_dbsherlock(data.test_datasets{i,train_idx}, data.abnormal_regions{i,train_idx}, data.normal_regions{i,train_idx}, [], train_param);
            end
            [exp prec recl f predStr] = run_perfxplain(trainMatrix, testMatrix, data.test_datasets{i,batch}.field_names, 5);
            prec_perfxplain{i}(end+1) = prec;
            recl_perfxplain{i}(end+1) = recl;
            f_perfxplain{i}(end+1) = f;
        end

        % calculate confidence
        for i=1:num_case
            for j=1:size(test_samples,2)
                test_idx = test_samples(j);
                explanation = run_dbsherlock(data.test_datasets{i,test_idx}, data.abnormal_regions{i,test_idx}, data.normal_regions{i,test_idx}, [], test_param);
                prec_dbseer{i}(end+1) = explanation{1, 3};
                f_dbseer{i}(end+1) = explanation{1, 4};
                recl_dbseer{i}(end+1) = explanation{1, 5};
            end
        end
    end

    % Plot results including LLM comparison
    figure('Name', 'Performance Comparison', 'Position', [100, 100, 800, 600]);
    
    % Calculate means for plotting
    mean_f_dbseer = cellfun(@mean, f_dbseer);
    mean_f_perfxplain = cellfun(@mean, f_perfxplain);
    
    % Create grouped bar plot
    bar_data = [mean_f_dbseer', mean_f_perfxplain', llm_fscore];
    b = bar(bar_data, 'grouped');
    
    % Customize appearance
    title('Performance Comparison', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Case Number', 'FontWeight', 'bold');
    ylabel('F-score (%)', 'FontWeight', 'bold');
    legend('DBSherlock', 'PerfXplain', 'DBWatson (LLM)', 'Location', 'southoutside', 'Orientation', 'horizontal');
    grid on;
    ylim([0 100]);
    
    % Save plot
    saveas(gcf, 'perfxplain_comparison.png');
end
