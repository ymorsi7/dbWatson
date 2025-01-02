function plot_llm_results(confidence, fscore)
    % Create a new figure with multiple subplots
    figure('Name', 'LLM-Enhanced Analysis Results', 'Position', [100, 100, 1200, 800]);
    
    % Plot 1: Bar chart comparing average metrics
    subplot(2,2,1);
    metrics = [mean(confidence) mean(fscore)];
    std_metrics = [std(confidence) std(fscore)];
    bar(metrics);
    hold on;
    errorbar(1:2, metrics, std_metrics, 'k.');
    title('Average Performance Metrics');
    set(gca, 'XTickLabel', {'Confidence', 'F-score'});
    ylabel('Score (%)');
    grid on;
    
    % Plot 2: Cause-wise comparison
    subplot(2,2,2);
    num_cases = length(confidence);
    plot(1:num_cases, confidence, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
    hold on;
    plot(1:num_cases, fscore, 'rd--', 'LineWidth', 2, 'MarkerSize', 8);
    title('Performance by Cause');
    xlabel('Cause Number');
    ylabel('Score (%)');
    legend('Confidence', 'F-score', 'Location', 'best');
    grid on;
    
    % Plot 3: Scatter plot with regression line
    subplot(2,2,3);
    scatter(confidence, fscore, 100, 'filled');
    hold on;
    p = polyfit(confidence, fscore, 1);
    x_fit = linspace(min(confidence), max(confidence), 100);
    y_fit = polyval(p, x_fit);
    plot(x_fit, y_fit, 'r--', 'LineWidth', 2);
    title('Confidence vs F-score Correlation');
    xlabel('Confidence Score (%)');
    ylabel('F-score (%)');
    grid on;
    
    % Plot 4: Cumulative distribution
    subplot(2,2,4);
    sorted_conf = sort(confidence);
    sorted_fscore = sort(fscore);
    plot(sorted_conf, (1:length(confidence))/length(confidence), 'b-', 'LineWidth', 2);
    hold on;
    plot(sorted_fscore, (1:length(fscore))/length(fscore), 'r--', 'LineWidth', 2);
    title('Cumulative Distribution');
    xlabel('Score (%)');
    ylabel('Cumulative Probability');
    legend('Confidence', 'F-score', 'Location', 'best');
    grid on;
    
    % Adjust layout and add overall title
    sgtitle('DBSherlock LLM-Enhanced Analysis Results', 'FontSize', 14);
end 

function plot_combined_results(conf_llm, fscore_llm)
    figure('Name', 'Combined Analysis Results');
    
    % Plot confidence comparison
    subplot(2,1,1);
    hold on;
    bar([conf_llm mean(conf_llm)]);
    title('Confidence Scores (Original vs LLM-Enhanced)');
    legend('LLM-Enhanced', 'Mean');
    ylabel('Confidence (%)');
    xlabel('Case Number');
    ylim([0 100]);
    hold off;
    
    % Plot F1-score comparison
    subplot(2,1,2);
    hold on;
    bar([fscore_llm mean(fscore_llm)]);
    title('F1-Scores (Original vs LLM-Enhanced)');
    legend('LLM-Enhanced', 'Mean');
    ylabel('F1-Score (%)');
    xlabel('Case Number');
    ylim([0 100]);
    hold off;
end