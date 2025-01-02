function plot_combined_results(conf_llm, fscore_llm)
    figure('Name', 'Combined Analysis Results', 'Position', [100, 100, 1200, 800]);
    
    % Plot 1: Performance comparison
    subplot(2,2,1);
    hold on;
    bar([mean(conf_llm) mean(fscore_llm)]);
    errorbar([1 2], [mean(conf_llm) mean(fscore_llm)], ...
        [std(conf_llm) std(fscore_llm)], 'k.');
    title('Average Performance Metrics');
    set(gca, 'XTickLabel', {'Confidence', 'F-score'});
    ylabel('Score (%)');
    hold off;
    
    % Plot 2: Box plots
    subplot(2,2,2);
    boxplot([conf_llm, fscore_llm], 'Labels', {'Confidence', 'F-score'});
    title('Performance Distribution');
    ylabel('Score (%)');
    
    % Plot 3: Time series comparison
    subplot(2,2,[3,4]);
    hold on;
    plot(conf_llm, 'b-', 'LineWidth', 2);
    plot(fscore_llm, 'r--', 'LineWidth', 2);
    title('Performance Metrics Over Cases');
    xlabel('Case Number');
    ylabel('Score (%)');
    legend('Confidence', 'F-score');
    grid on;
    hold off;
    
    % Adjust layout
    sgtitle('DBSherlock Combined Analysis Results');
end 