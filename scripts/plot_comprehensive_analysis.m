function plot_comprehensive_analysis(conf_llm, fscore_llm, case_names)
    if nargin < 3
        case_names = arrayfun(@(x) sprintf('Case %d', x), 1:length(conf_llm), 'UniformOutput', false);
    end
    
    % Figure 1: Performance Overview
    figure('Name', 'Performance Overview', 'Position', [100, 100, 1200, 800]);
    
    % Bar plot comparing metrics
    subplot(2,2,1);
    bar([conf_llm, fscore_llm]);
    title('Performance by Case');
    xlabel('Case Number');
    ylabel('Score (%)');
    legend('Confidence', 'F-score');
    grid on;
    set(gca, 'XTickLabel', case_names, 'XTickLabelRotation', 45);
    
    % Scatter plot with case labels
    subplot(2,2,2);
    scatter(conf_llm, fscore_llm, 100, 'filled');
    text(conf_llm, fscore_llm, case_names, 'VerticalAlignment', 'bottom');
    title('Confidence vs F-score Correlation');
    xlabel('Confidence (%)');
    ylabel('F-score (%)');
    grid on;
    
    % Distribution plots
    subplot(2,2,[3,4]);
    boxplot([conf_llm(:), fscore_llm(:)], {'Confidence', 'F-score'});
    title('Score Distributions');
    ylabel('Score (%)');
    grid on;
    
    % Figure 2: Detailed Analysis
    figure('Name', 'Detailed Analysis', 'Position', [150, 150, 1200, 800]);
    
    % Performance ranking
    subplot(2,2,1);
    [sorted_scores, idx] = sort(fscore_llm, 'descend');
    barh(sorted_scores);
    yticks(1:length(sorted_scores));
    yticklabels(case_names(idx));
    title('Cases Ranked by F-score');
    xlabel('F-score (%)');
    grid on;
    
    % Time series view
    subplot(2,2,2);
    plot(1:length(conf_llm), conf_llm, '-o', 1:length(fscore_llm), fscore_llm, '-s', 'LineWidth', 2);
    title('Performance Trends');
    xlabel('Case Number');
    ylabel('Score (%)');
    legend('Confidence', 'F-score', 'Location', 'best');
    grid on;
    
    % Summary statistics table
    subplot(2,2,[3,4]);
    stats = [mean([conf_llm fscore_llm]); 
            median([conf_llm fscore_llm]);
            std([conf_llm fscore_llm]);
            min([conf_llm fscore_llm]);
            max([conf_llm fscore_llm])];
    
    uitable('Data', stats, ...
            'RowName', {'Mean', 'Median', 'Std Dev', 'Min', 'Max'}, ...
            'ColumnName', {'Confidence', 'F-score'}, ...
            'Units', 'Normalized', ...
            'Position', [0.1 0.1 0.8 0.8]);
    
    % Save plots
    saveas(figure(1), 'performance_overview.png');
    saveas(figure(2), 'detailed_analysis.png');
    
    % Print summary statistics
    fprintf('\nSummary Statistics:\n');
    fprintf('Confidence: mean=%.2f, std=%.2f, median=%.2f, range=[%.2f, %.2f]\n', ...
        mean(conf_llm), std(conf_llm), median(conf_llm), min(conf_llm), max(conf_llm));
    fprintf('F-score: mean=%.2f, std=%.2f, median=%.2f, range=[%.2f, %.2f]\n\n', ...
        mean(fscore_llm), std(fscore_llm), median(fscore_llm), min(fscore_llm), max(fscore_llm));
end 