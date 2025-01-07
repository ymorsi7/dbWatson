function perform_evaluation_merged_causal_models(dataset_name)
    if nargin < 1
        dataset_name = 'dbsherlock_dataset_tpcc_16w.mat';
    end
    
    % Original evaluation code
    [merged_conf, merged_fscore] = evaluate_merged_models(dataset_name);
    
    % Get LLM results with error handling
    has_llm_results = false;
    try
        [llm_conf, llm_fscore] = get_llm_results(dataset_name);
        if ~isempty(llm_fscore) && any(llm_fscore ~= 0)
            has_llm_results = true;
            plot_data = [merged_conf, merged_fscore, llm_fscore];
            legend_labels = {'Merged Confidence', 'Merged F-score', 'DBWatson F-score'};
        else
            warning('LLM evaluation returned no valid results');
            plot_data = [merged_conf, merged_fscore];
            legend_labels = {'Merged Confidence', 'Merged F-score'};
        end
    catch e
        warning('LLM evaluation failed: %s', e.message);
        plot_data = [merged_conf, merged_fscore];
        legend_labels = {'Merged Confidence', 'Merged F-score'};
    end
    
    % Plot comparison
    figure('Position', [100, 100, 800, 600]);
    
    % Plot original merged results and LLM results
    plot(plot_data, 'LineWidth', 2, 'Marker', 'o');
    
    title('Merged Models Performance', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Number of Merged Models', 'FontWeight', 'bold');
    ylabel('Score (%)', 'FontWeight', 'bold');
    legend(legend_labels, ...
           'Location', 'southoutside', 'Orientation', 'horizontal');
    grid on;
    ylim([0 100]);
    
    saveas(gcf, 'merged_models_comparison.png');
end 