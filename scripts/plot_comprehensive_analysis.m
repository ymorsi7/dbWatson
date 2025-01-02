function plot_comprehensive_analysis(conf_llm, fscore_llm, case_names)
    if nargin < 3
        case_names = arrayfun(@(x) sprintf('Case %d', x), 1:length(conf_llm), 'UniformOutput', false);
    end
    
    % Define consistent colors
    conf_color = [0.2 0.6 0.8];
    fscore_color = [0.8 0.4 0.2];
    
    figure('Name', 'Performance Overview', 'Position', [100, 100, 1200, 800]);
    
    % Bar plot comparing metrics
    subplot(2,2,1);
    b = bar([conf_llm, fscore_llm], 'grouped', 'BarWidth', 0.8);
    b(1).FaceColor = conf_color;
    b(2).FaceColor = fscore_color;
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
    ax.GridAlpha = 0.1;
    ylim([0 100]);

    % Scatter plot with improved label placement
    subplot(2,2,2);
    scatter(conf_llm, fscore_llm, 100, 'filled', 'MarkerFaceColor', [0.3 0.6 0.9], 'MarkerFaceAlpha', 0.7);
    hold on;
    
    % Add trend line and R² value
    p = polyfit(conf_llm, fscore_llm, 1);
    x_trend = linspace(min(conf_llm)-5, max(conf_llm)+5, 100);
    y_trend = polyval(p, x_trend);
    plot(x_trend, y_trend, 'Color', [0.8 0.2 0.2], 'LineWidth', 2);
    R2 = corrcoef(conf_llm, fscore_llm);
    R2 = R2(1,2)^2;
    text(5, 95, sprintf('R² = %.3f', R2), 'FontSize', 10, 'BackgroundColor', [1 1 1 0.8]);
    
    % Smart label placement
    positions = smart_label_placement(conf_llm, fscore_llm, case_names);
    for i = 1:length(case_names)
        plot([conf_llm(i) positions(i,1)], [fscore_llm(i) positions(i,2)], ...
             'Color', [0.7 0.7 0.7], 'LineStyle', ':');
        text(positions(i,1), positions(i,2), case_names{i}, ...
             'FontSize', 8, 'HorizontalAlignment', 'center', ...
             'BackgroundColor', [1 1 1 0.8]);
    end
    
    title('Confidence vs F-score Correlation', 'FontWeight', 'bold', 'FontSize', 12);
    xlabel('Confidence (%)', 'FontWeight', 'bold');
    ylabel('F-score (%)', 'FontWeight', 'bold');
    grid on;
    ax = gca;
    ax.GridAlpha = 0.1;
    axis([0 100 0 100]);
    hold off;
    
    % Box plot with individual points
    subplot(2,2,[3,4]);
    boxplot([conf_llm(:), fscore_llm(:)], {'Confidence', 'F-score'}, ...
            'Colors', [conf_color; fscore_color], ...
            'Symbol', '');
    
    hold on;
    % Add jittered points
    jitter = 0.2;
    scatter(ones(size(conf_llm)) + (rand(size(conf_llm))-0.5)*jitter, conf_llm, 50, ...
           conf_color, 'filled', 'MarkerFaceAlpha', 0.6);
    scatter(2*ones(size(fscore_llm)) + (rand(size(fscore_llm))-0.5)*jitter, fscore_llm, 50, ...
           fscore_color, 'filled', 'MarkerFaceAlpha', 0.6);
    
    title('Score Distributions', 'FontWeight', 'bold', 'FontSize', 12);
    ylabel('Score (%)', 'FontWeight', 'bold');
    grid on;
    ax = gca;
    ax.GridAlpha = 0.1;
    ylim([0 100]);
    hold off;
    
    saveas(gcf, 'performance_overview.png');
    
    % Print statistics
    fprintf('\nSummary Statistics:\n');
    fprintf('Confidence: mean=%.2f, std=%.2f, median=%.2f, range=[%.2f, %.2f]\n', ...
        mean(conf_llm), std(conf_llm), median(conf_llm), min(conf_llm), max(conf_llm));
    fprintf('F-score: mean=%.2f, std=%.2f, median=%.2f, range=[%.2f, %.2f]\n\n', ...
        mean(fscore_llm), std(fscore_llm), median(fscore_llm), min(fscore_llm), max(fscore_llm));
end

function positions = smart_label_placement(x, y, labels)
    n = length(x);
    positions = zeros(n, 2);
    
    % Sort points by y-coordinate
    [~, idx] = sort(y);
    
    for i = 1:n
        point_idx = idx(i);
        % Try different angles and distances
        best_pos = [x(point_idx), y(point_idx) + 5];  % Default offset
        min_overlap = inf;
        
        for angle = 0:45:315
            for dist = [5 10 15 20]
                test_x = x(point_idx) + dist * cosd(angle);
                test_y = y(point_idx) + dist * sind(angle);
                
                % Keep within bounds
                test_x = min(max(test_x, 0), 100);
                test_y = min(max(test_y, 0), 100);
                
                % Check overlap with existing labels
                overlap = sum(abs(positions(1:i-1,1) - test_x) < 10 & ...
                            abs(positions(1:i-1,2) - test_y) < 5);
                
                if overlap < min_overlap
                    min_overlap = overlap;
                    best_pos = [test_x test_y];
                end
            end
        end
        positions(point_idx,:) = best_pos;
    end
end 