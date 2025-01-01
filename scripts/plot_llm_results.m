function plot_llm_results(confidence, fscore)
    figure('Name', 'LLM-Enhanced Analysis Results');
    
    subplot(2,1,1);
    bar(confidence);
    title('Confidence Scores');
    ylabel('Confidence (%)');
    xlabel('Case Number');
    ylim([0 100]);
    
    subplot(2,1,2);
    bar(fscore);
    title('F1-Scores');
    ylabel('F1-Score (%)');
    xlabel('Case Number');
    ylim([0 100]);
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