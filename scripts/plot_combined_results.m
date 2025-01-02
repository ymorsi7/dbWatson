function plot_combined_results(conf_llm, fscore_llm)
    figure('Position', [100, 100, 1200, 800]);
    
    % 1. Time Series View
    subplot(2,2,1);
    plot(1:length(conf_llm), conf_llm, '-o', 1:length(fscore_llm), fscore_llm, '-s');
    title('Performance Trends');
    xlabel('Case Number');
    ylabel('Score (%)');
    legend('Confidence', 'F-score', 'Location', 'best');
    grid on;
    
    % 2. Correlation Analysis
    subplot(2,2,2);
    scatter(conf_llm, fscore_llm, 50, 1:length(conf_llm), 'filled');
    colorbar('Ticks', 1:length(conf_llm), 'TickLabels', cellstr(num2str((1:length(conf_llm))')));
    title('Metric Correlation by Case');
    xlabel('Confidence (%)');
    ylabel('F-score (%)');
    grid on;
    
    % 3. Performance Distribution
    subplot(2,2,[3,4]);
    data = [conf_llm(:), fscore_llm(:)];
    violinplot(data, {'Confidence', 'F-score'});
    hold on;
    plot(xlim, [mean(conf_llm) mean(conf_llm)], '--r');
    plot(xlim, [mean(fscore_llm) mean(fscore_llm)], '--b');
    title('Score Distributions with Means');
    ylabel('Score (%)');
    grid on;
    
    % Add summary title
    sgtitle(sprintf('DBSherlock Performance Analysis\nMean Confidence: %.1f%%, Mean F-score: %.1f%%', ...
        mean(conf_llm), mean(fscore_llm)));
    
    % Save plot
    saveas(gcf, 'combined_analysis_results.png');
    fprintf('\nPlot saved as combined_analysis_results.png\n');
end 