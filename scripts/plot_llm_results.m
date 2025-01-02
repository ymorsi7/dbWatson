function plot_llm_results(confidence, fscore)
    % Create a new figure with multiple subplots
    figure('Name', 'LLM-Enhanced Analysis Results', 'Position', [100, 100, 1200, 800]);
    
    % Plot 1: Cause-wise accuracy comparison
    subplot(2,2,1);
    num_cases = length(confidence);
    bar([confidence fscore], 'grouped');
    title('Accuracy by Cause');
    xlabel('Cause ID');
    ylabel('Score (%)');
    legend('Confidence', 'F-score');
    grid on;
    ylim([0 100]);
    
    % Plot 2: Precision-Recall curve
    subplot(2,2,2);
    sorted_conf = sort(confidence, 'descend');
    recall = (1:length(sorted_conf))/length(sorted_conf);
    plot(recall, sorted_conf, 'b-', 'LineWidth', 2);
    title('Precision-Recall Curve');
    xlabel('Recall');
    ylabel('Precision (%)');
    grid on;
    
    % Plot 3: Performance distribution
    subplot(2,2,3);
    violinplot([confidence fscore], {'Confidence', 'F-score'});
    title('Score Distribution');
    ylabel('Score (%)');
    ylim([0 100]);
    
    % Plot 4: Temporal analysis
    subplot(2,2,4);
    plot(1:num_cases, movmean(confidence, 3), 'b-', 'LineWidth', 2);
    hold on;
    plot(1:num_cases, movmean(fscore, 3), 'r--', 'LineWidth', 2);
    title('Moving Average Performance');
    xlabel('Case Number');
    ylabel('Score (%)');
    legend('Confidence (3-pt avg)', 'F-score (3-pt avg)');
    grid on;
    ylim([0 100]);
    
    % Add overall title
    sgtitle({'DBSherlock LLM-Enhanced Analysis Results', ...
             sprintf('Avg Confidence: %.1f%%, Avg F-score: %.1f%%', ...
             mean(confidence), mean(fscore))}, ...
             'FontSize', 14);
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