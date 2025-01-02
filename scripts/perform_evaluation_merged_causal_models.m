function perform_evaluation_merged_causal_models(dataset_name)
    if nargin < 1
        dataset_name = 'dbsherlock_dataset_tpcc_16w.mat';
    end
    
    % Original evaluation code remains same until plotting
    [merged_conf, merged_fscore] = evaluate_merged_models(dataset_name);
    
    % Get LLM results
    [llm_conf, llm_fscore] = get_llm_results(dataset_name);
    
    % Plot comparison
    figure('Position', [100, 100, 800, 600]);
    
    % Plot original merged results and LLM results
    plot_data = [merged_conf, merged_fscore, llm_fscore];
    plot(plot_data, 'LineWidth', 2, 'Marker', 'o');
    
    title('Merged Models Performance', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Number of Merged Models', 'FontWeight', 'bold');
    ylabel('Score (%)', 'FontWeight', 'bold');
    legend('Merged Confidence', 'Merged F-score', 'DBWatson F-score', ...
           'Location', 'southoutside', 'Orientation', 'horizontal');
    grid on;
    ylim([0 100]);
    
    saveas(gcf, 'merged_models_comparison.png');
end 