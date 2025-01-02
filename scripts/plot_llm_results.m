function plot_llm_results(confidence, fscore)
    if isempty(confidence) || isempty(fscore)
        error('No data available to plot. Check if evaluation generated results.');
    end
    
    if all(confidence == 0) || all(fscore == 0)
        error('All values are zero. Check if metrics are being calculated correctly.');
    end
    
    figure('Name', 'LLM-Enhanced Analysis Results');
    
    % Create subplot for confidence scores
    subplot(2,1,1);
    histogram(confidence, 'BinMethod', 'scott', 'Normalization', 'count');
    title(sprintf('Distribution of Confidence Scores (n=%d)', length(confidence)));
    xlabel('Confidence Score (%)');
    ylabel('Count');
    grid on;
    ylim([0 max(histcounts(confidence)) + 1]);
    
    % Create subplot for F-scores
    subplot(2,1,2);
    histogram(fscore, 'BinMethod', 'scott', 'Normalization', 'count');
    title(sprintf('Distribution of F-scores (n=%d)', length(fscore)));
    xlabel('F-score (%)');
    ylabel('Count');
    grid on;
    ylim([0 max(histcounts(fscore)) + 1]);
    
    sgtitle('DBSherlock LLM-Enhanced Performance Metrics');
    
    % Print summary statistics
    fprintf('\nSummary Statistics:\n');
    fprintf('Confidence: mean=%.2f, std=%.2f, median=%.2f, range=[%.2f, %.2f]\n', ...
        mean(confidence), std(confidence), median(confidence), min(confidence), max(confidence));
    fprintf('F-score: mean=%.2f, std=%.2f, median=%.2f, range=[%.2f, %.2f]\n', ...
        mean(fscore), std(fscore), median(fscore), min(fscore), max(fscore));
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