function perform_evaluation_single_causal_models(dataset_name)
    if nargin < 1
        dataset_name = 'dbsherlock_dataset_tpcc_16w.mat';
    end
    
    % Get original results
    [original_conf, original_fscore] = evaluate_original_models(dataset_name);
    
    % Get LLM results for comparison
    has_llm_results = false;
    try
        if ~isempty(getenv('OPENAI_API_KEY'))
            [llm_conf, llm_fscore] = perform_evaluation_llm_enhanced(dataset_name);
            if ~isempty(llm_fscore) && any(llm_fscore ~= 0)
                has_llm_results = true;
            else
                warning('LLM evaluation returned no valid results');
            end
        else
            warning('OPENAI_API_KEY not set - skipping LLM evaluation');
        end
    catch e
        warning('LLM evaluation failed: %s', e.message);
    end
    
    % Plot comparison
    figure('Position', [100, 100, 800, 600]);
    
    % Create grouped bar data
    num_cases = length(original_conf);
    x = 1:num_cases;
    
    if has_llm_results
        bar_data = [original_conf, original_fscore, llm_conf, llm_fscore];
        legend_labels = {'Original Confidence', 'Original F-score', ...
                        'DBWatson Confidence', 'DBWatson F-score'};
    else
        bar_data = [original_conf, original_fscore];
        legend_labels = {'Original Confidence', 'Original F-score'};
    end
    
    % Create grouped bar plot with explicit colors
    b = bar(x, bar_data, 'grouped');
    
    % Set bar colors
    colors = [
        0.0000, 0.4470, 0.7410;  % blue - Original Confidence
        0.8500, 0.3250, 0.0980;  % red - Original F-score
        0.9290, 0.6940, 0.1250;  % yellow - DBWatson Confidence
        0.4940, 0.1840, 0.5560   % purple - DBWatson F-score
    ];
    
    for i = 1:length(b)
        b(i).FaceColor = colors(i,:);
    end
    
    % Customize appearance
    title('Single Causal Models Performance', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Case Number', 'FontWeight', 'bold');
    ylabel('Score (%)', 'FontWeight', 'bold');
    legend(legend_labels, 'Location', 'southoutside', 'Orientation', 'horizontal');
    grid on;
    ylim([0 100]);
    
    % Add case numbers to x-axis
    xticks(1:num_cases);
    
    % Save plot
    saveas(gcf, 'single_causal_models_comparison.png');
end 