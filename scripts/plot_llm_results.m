function plot_llm_results(confidence, fscore)
    if isempty(confidence) || isempty(fscore)
        error('No data available to plot. Check if evaluation generated results.');
    end
    
    % Create figure with multiple subplots
    figure('Position', [100, 100, 1200, 800]);
    
    % 1. Performance by Case
    subplot(2,2,1);
    cases = 1:length(confidence);
    bar([confidence, fscore]);
    title('Performance Metrics by Case');
    xlabel('Case Number');
    ylabel('Score (%)');
    legend('Confidence', 'F-score');
    grid on;
    
    % 2. Correlation Plot
    subplot(2,2,2);
    scatter(confidence, fscore, 50, 'filled');
    hold on;
    fit = polyfit(confidence, fscore, 1);
    plot(confidence, polyval(fit, confidence), 'r--');
    title('Correlation: Confidence vs F-score');
    xlabel('Confidence Score (%)');
    ylabel('F-score (%)');
    grid on;
    
    % 3. Distribution Analysis
    subplot(2,2,3);
    violinplot([confidence, fscore], {'Confidence', 'F-score'});
    title('Score Distributions');
    ylabel('Score (%)');
    grid on;
    
    % 4. Performance Ranking
    subplot(2,2,4);
    [sorted_scores, idx] = sort(fscore, 'descend');
    barh(sorted_scores);
    title('Cases Ranked by F-score');
    xlabel('F-score (%)');
    ylabel('Case Rank');
    grid on;
    
    % Add overall title with summary statistics
    sgtitle(sprintf('DBSherlock Analysis Results\nMean Confidence: %.1f%%, Mean F-score: %.1f%%', ...
        mean(confidence), mean(fscore)));
    
    % Print detailed statistics
    fprintf('\nPerformance Summary:\n');
    fprintf('Confidence Scores:\n');
    fprintf('  Mean: %.2f%%\n  Median: %.2f%%\n  Std: %.2f%%\n  Range: [%.2f%%, %.2f%%]\n', ...
        mean(confidence), median(confidence), std(confidence), min(confidence), max(confidence));
    fprintf('\nF-scores:\n');
    fprintf('  Mean: %.2f%%\n  Median: %.2f%%\n  Std: %.2f%%\n  Range: [%.2f%%, %.2f%%]\n', ...
        mean(fscore), median(fscore), std(fscore), min(fscore), max(fscore));
    
    % Save plot
    saveas(gcf, 'llm_analysis_results.png');
    fprintf('\nPlot saved as llm_analysis_results.png\n');
end