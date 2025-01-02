function perform_evaluation_compound_situations(dataset_name)
    if nargin < 1
        dataset_name = 'dbsherlock_dataset_tpcc_16w.mat';
    end
    
    % Original evaluation code remains same until plotting
    [compound_conf, compound_fscore] = evaluate_compound_situations(dataset_name);
    
    % Get LLM results
    [llm_conf, llm_fscore] = get_llm_results(dataset_name);
    
    % Plot comparison
    figure('Position', [100, 100, 800, 600]);
    
    % Combined line plot
    plot_data = [compound_conf, compound_fscore, llm_fscore];
    plot(plot_data, 'LineWidth', 2, 'Marker', 'o');
    
    title('Compound Situations Analysis', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Number of Combined Situations', 'FontWeight', 'bold');
    ylabel('Score (%)', 'FontWeight', 'bold');
    legend('Compound Confidence', 'Compound F-score', 'DBWatson F-score', ...
           'Location', 'southoutside', 'Orientation', 'horizontal');
    grid on;
    ylim([0 100]);
    
    saveas(gcf, 'compound_situations_comparison.png');
end 