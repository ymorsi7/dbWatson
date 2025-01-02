function plot_llm_results(confidence, fscore)
    % Create a new figure with multiple subplots
    figure('Name', 'LLM-Enhanced Analysis Results', 'Position', [100, 100, 1200, 800]);
    
    % Plot 1: Confidence Score Distribution
    subplot(2,3,1);
    histogram(confidence, 'Normalization', 'probability');
    title('Distribution of Confidence Scores');
    xlabel('Confidence Score (%)');
    ylabel('Frequency');
    
    % Plot 2: F-score Distribution
    subplot(2,3,2);
    histogram(fscore, 'Normalization', 'probability');
    title('Distribution of F-scores');
    xlabel('F-score');
    ylabel('Frequency');
    
    % Plot 3: Scatter plot of Confidence vs F-score
    subplot(2,3,3);
    scatter(confidence, fscore, 'filled');
    title('Confidence vs F-score');
    xlabel('Confidence Score (%)');
    ylabel('F-score');
    
    % Plot 4: Box plots
    subplot(2,3,4);
    boxplot([confidence, fscore], 'Labels', {'Confidence', 'F-score'});
    title('Performance Metrics Distribution');
    ylabel('Score (%)');
    
    % Plot 5: Time series-like plot
    subplot(2,3,[5,6]);
    hold on;
    plot(confidence, 'b-', 'LineWidth', 2);
    plot(fscore, 'r--', 'LineWidth', 2);
    title('Performance Metrics Over Cases');
    xlabel('Case Number');
    ylabel('Score (%)');
    legend('Confidence', 'F-score');
    grid on;
    hold off;
    
    % Adjust layout
    sgtitle('DBSherlock LLM-Enhanced Analysis Results');
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