function plot_llm_results(confidence, fscore)
    figure('Name', 'LLM-Enhanced Analysis Results');
    
    % Create subplot for confidence scores
    subplot(2,1,1);
    histogram(confidence, 'Normalization', 'probability');
    title('Distribution of Confidence Scores');
    xlabel('Confidence Score (%)');
    ylabel('Frequency');
    
    % Create subplot for F-scores
    subplot(2,1,2);
    histogram(fscore, 'Normalization', 'probability');
    title('Distribution of F-scores');
    xlabel('F-score');
    ylabel('Frequency');
    
    % Adjust layout
    sgtitle('DBSherlock LLM-Enhanced Performance Metrics');
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