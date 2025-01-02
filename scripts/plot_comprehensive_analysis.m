function plot_comprehensive_analysis(conf_llm, fscore_llm, case_names)
    if nargin < 3
        case_names = arrayfun(@(x) sprintf('Case %d', x), 1:length(conf_llm), 'UniformOutput', false);
    end
    
    % Figure setup
    figure('Name', 'Performance Overview', 'Position', [100, 100, 1200, 800]);
    
    % Bar plot comparing metrics
    subplot(2,2,1);
    b = bar([conf_llm, fscore_llm], 'grouped', 'BarWidth', 0.8);
    b(1).FaceColor = [0.2 0.6 0.8];
    b(2).FaceColor = [0.8 0.4 0.2];
    title('Performance by Case', 'FontWeight', 'bold', 'FontSize', 12);
    xlabel('Case Type', 'FontWeight', 'bold');
    ylabel('Score (%)', 'FontWeight', 'bold');
    legend('Confidence', 'F-score', 'Location', 'southoutside', 'Orientation', 'horizontal');
    grid on;
    ax = gca;
    ax.XTickLabel = case_names;
    ax.XTickLabelRotation = 45;
    ax.TickLabelInterpreter = 'none';
    ax.FontSize = 8;
    ylim([0 100]);
    
    % Scatter plot with improved label placement
    subplot(2,2,2);
    scatter(conf_llm, fscore_llm, 100, 'filled', 'MarkerFaceColor', [0.3 0.6 0.9]);
    hold on;
    
    % Add trend line with confidence bounds
    p = polyfit(conf_llm, fscore_llm, 1);
    x_trend = linspace(min(conf_llm)-5, max(conf_llm)+5, 100);
    y_trend = polyval(p, x_trend);
    plot(x_trend, y_trend, 'r-', 'LineWidth', 2);
    
    % Smart label placement to avoid overlap
    for i = 1:length(case_names)
        % Calculate offset based on point density
        nearby_points = sum(abs(conf_llm - conf_llm(i)) < 5 & abs(fscore_llm - fscore_llm(i)) < 5);
        offset = 3 * nearby_points;
        text(conf_llm(i), fscore_llm(i)+offset, case_names{i}, ...
             'FontSize', 8, 'HorizontalAlignment', 'center');
    end
    
    title('Confidence vs F-score Correlation', 'FontWeight', 'bold', 'FontSize', 12);
    xlabel('Confidence (%)', 'FontWeight', 'bold');
    ylabel('F-score (%)', 'FontWeight', 'bold');
    grid on;
    axis([0 100 0 100]);
    hold off;
    
    % Box plot with individual points
    subplot(2,2,[3,4]);
    boxplot([conf_llm(:), fscore_llm(:)], {'Confidence', 'F-score'}, ...
            'Labels', {'Confidence', 'F-score'}, ...
            'Widths', 0.7, 'Colors', [0.2 0.6 0.8; 0.8 0.4 0.2]);
    hold on;
    % Add individual points
    jitter = 0.2;
    scatter(ones(size(conf_llm)) + (rand(size(conf_llm))-0.5)*jitter, conf_llm, 50, [0.2 0.6 0.8], 'filled', 'MarkerFaceAlpha', 0.6);
    scatter(2*ones(size(fscore_llm)) + (rand(size(fscore_llm))-0.5)*jitter, fscore_llm, 50, [0.8 0.4 0.2], 'filled', 'MarkerFaceAlpha', 0.6);
    hold off;
    
    title('Score Distributions', 'FontWeight', 'bold', 'FontSize', 12);
    ylabel('Score (%)', 'FontWeight', 'bold');
    grid on;
    ylim([0 100]);
    
    % Save plot
    saveas(gcf, 'performance_overview.png');
    
    % Print summary statistics
    fprintf('\nSummary Statistics:\n');
    fprintf('Confidence: mean=%.2f, std=%.2f, median=%.2f, range=[%.2f, %.2f]\n', ...
        mean(conf_llm), std(conf_llm), median(conf_llm), min(conf_llm), max(conf_llm));
    fprintf('F-score: mean=%.2f, std=%.2f, median=%.2f, range=[%.2f, %.2f]\n\n', ...
        mean(fscore_llm), std(fscore_llm), median(fscore_llm), min(fscore_llm), max(fscore_llm));
end 