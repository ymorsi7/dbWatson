function perform_evaluation_single_causal_models(dataset_name)
    if nargin < 1
        dataset_name = 'dbsherlock_dataset_tpcc_16w.mat';
    end
    
    % Original evaluation code remains same until plotting
    [original_conf, original_fscore] = evaluate_original_models(dataset_name);
    
    % Get LLM results for comparison
    [llm_conf, llm_fscore] = get_llm_results(dataset_name);
    
    % Plot comparison
    figure('Position', [100, 100, 800, 600]);
    
    % Combine data for grouped bar plot
    bar_data = [original_conf, original_fscore, llm_fscore];
    b = bar(bar_data, 'grouped');
    
    title('Single Causal Models Performance', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Case Number', 'FontWeight', 'bold');
    ylabel('Score (%)', 'FontWeight', 'bold');
    legend('Original Confidence', 'Original F-score', 'DBWatson F-score', ...
           'Location', 'southoutside', 'Orientation', 'horizontal');
    grid on;
    ylim([0 100]);
    
    saveas(gcf, 'single_causal_models_comparison.png');
end 