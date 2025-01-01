function plot_combined_results(conf_llm, fscore_llm)
    figure('Name', 'Combined Analysis Results');
    
    % Create subplot for confidence scores
    subplot(2,2,1);
    histogram(conf_llm, 'Normalization', 'probability');
    title('LLM-Enhanced Confidence Scores');
    xlabel('Confidence Score (%)');
    ylabel('Frequency');
    
    % Create subplot for F-scores
    subplot(2,2,2);
    histogram(fscore_llm, 'Normalization', 'probability');
    title('LLM-Enhanced F-scores');
    xlabel('F-score');
    ylabel('Frequency');
    
    % Add comparison with baseline
    subplot(2,2,[3,4]);
    boxplot([conf_llm, fscore_llm], 'Labels', {'Confidence', 'F-score'});
    title('Performance Metrics Distribution');
    ylabel('Score (%)');
    
    % Adjust layout
    sgtitle('DBSherlock Combined Analysis Results');
end 