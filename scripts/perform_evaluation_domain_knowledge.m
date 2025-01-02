function perform_evaluation_domain_knowledge(dataset_name)
    if nargin < 1
        dataset_name = 'dbsherlock_dataset_tpcc_16w.mat';
    end
    
    % Original evaluation code remains same until plotting
    [dk_conf, dk_fscore] = evaluate_domain_knowledge(dataset_name);
    
    % Get LLM results
    [llm_conf, llm_fscore] = get_llm_results(dataset_name);
    
    % Plot comparison
    figure('Position', [100, 100, 800, 600]);
    
    % Combined bar plot
    bar_data = [dk_conf, dk_fscore, llm_fscore];
    b = bar(bar_data, 'grouped');
    
    title('Domain Knowledge Integration Performance', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Test Case', 'FontWeight', 'bold');
    ylabel('Score (%)', 'FontWeight', 'bold');
    legend('With Domain Knowledge', 'Original F-score', 'DBWatson F-score', ...
           'Location', 'southoutside', 'Orientation', 'horizontal');
    grid on;
    ylim([0 100]);
    
    saveas(gcf, 'domain_knowledge_comparison.png');
end 