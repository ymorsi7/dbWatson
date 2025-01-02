function plot_comprehensive_analysis(conf_llm, fscore_llm, case_names)
    if nargin < 3
        case_names = arrayfun(@(x) sprintf('Case %d', x), 1:length(conf_llm), 'UniformOutput', false);
    end
    
    % Define consistent colors
    conf_color = [0.2 0.6 0.8];
    fscore_color = [0.8 0.4 0.2];
    
    figure('Name', 'Performance Overview', 'Position', [100, 100, 1400, 800]);
    
    % Bar plot with improved spacing
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
    
    % Improved scatter plot with smart label placement
    subplot(2,2,2);
    scatter(conf_llm, fscore_llm, 100, 'filled', 'MarkerFaceColor', [0.3 0.6 0.9], 'MarkerFaceAlpha', 0.7);
    hold on;
    
    % Trend line with shaded confidence region
    p = polyfit(conf_llm, fscore_llm, 1);
    x_trend = linspace(min(conf_llm)-5, max(conf_llm)+5, 100);
    y_trend = polyval(p, x_trend);
    plot(x_trend, y_trend, 'Color', [0.8 0.2 0.2], 'LineWidth', 2);
    
    % Add R² with better positioning
    R2 = corrcoef(conf_llm, fscore_llm);
    R2 = R2(1,2)^2;
    text(5, 95, sprintf('R² = %.3f', R2), 'FontSize', 10, ...
         'BackgroundColor', [1 1 1 0.8], 'EdgeColor', [0.8 0.8 0.8]);
    
    % New label placement strategy
    [sorted_conf, idx] = sort(conf_llm, 'descend');
    sorted_fscore = fscore_llm(idx);
    sorted_names = case_names(idx);
    
    % Define quadrants for label placement with more spread
    quadrants = [
        [90, 98];  % top right
        [10, 98];  % top left
        [10, 80];  % upper middle left
        [90, 80];  % upper middle right
        [10, 60];  % lower middle left
        [90, 60];  % lower middle right
        [10, 40];  % bottom left
        [90, 40];  % bottom right
        [50, 20];  % bottom center
        [50, 98]   % top center
    ];
    
    % Place labels in predefined positions
    for i = 1:length(sorted_names)
        x = sorted_conf(i);
        y = sorted_fscore(i);
        
        % Choose quadrant based on point position
        label_x = quadrants(i,1);
        label_y = quadrants(i,2);
        
        % Draw connection line
        plot([x label_x], [y label_y], ':', 'Color', [0.7 0.7 0.7]);
        
        % Add label with background
        text(label_x, label_y, sorted_names{i}, ...
             'FontSize', 8, 'HorizontalAlignment', 'center', ...
             'BackgroundColor', [1 1 1 0.95], 'EdgeColor', [0.8 0.8 0.8], ...
             'Margin', 2);
    end
    
    title('Confidence vs F-score Correlation', 'FontWeight', 'bold', 'FontSize', 12);
    xlabel('Confidence (%)', 'FontWeight', 'bold');
    ylabel('F-score (%)', 'FontWeight', 'bold');
    grid on;
    ax = gca;
    ax.GridAlpha = 0.1;
    axis([0 100 0 100]);
    
    % Improved box plot
    subplot(2,2,[3,4]);
    boxplot([conf_llm(:), fscore_llm(:)], {'Confidence', 'F-score'}, ...
            'Colors', [conf_color; fscore_color], ...
            'Symbol', '', 'Width', 0.7);
    
    hold on;
    % Add jittered points with transparency
    jitter = 0.2;
    scatter(ones(size(conf_llm)) + (rand(size(conf_llm))-0.5)*jitter, conf_llm, 50, ...
           conf_color, 'filled', 'MarkerFaceAlpha', 0.6);
    scatter(2*ones(size(fscore_llm)) + (rand(size(fscore_llm))-0.5)*jitter, fscore_llm, 50, ...
           fscore_color, 'filled', 'MarkerFaceAlpha', 0.6);
    
    % Add point labels with better positioning
    for i = 1:length(case_names)
        % Label confidence points
        text(1 + (rand-0.5)*jitter, conf_llm(i), case_names{i}, ...
             'FontSize', 7, 'HorizontalAlignment', 'right', ...
             'VerticalAlignment', 'middle', 'Rotation', 45, ...
             'BackgroundColor', [1 1 1 0.9]);
        % Label F-score points
        text(2 + (rand-0.5)*jitter, fscore_llm(i), case_names{i}, ...
             'FontSize', 7, 'HorizontalAlignment', 'right', ...
             'VerticalAlignment', 'middle', 'Rotation', 45, ...
             'BackgroundColor', [1 1 1 0.9]);
    end
    
    title('Score Distributions', 'FontWeight', 'bold', 'FontSize', 12);
    ylabel('Score (%)', 'FontWeight', 'bold');
    legend('Confidence Points', 'F-score Points', 'Location', 'eastoutside');
    grid on;
    ax = gca;
    ax.GridAlpha = 0.1;
    ylim([0 100]);
    
    % Save with high resolution
    set(gcf, 'PaperPositionMode', 'auto');
    print('performance_overview.png', '-dpng', '-r300');
end

function best_pos = find_best_label_position(x, y, prev_positions, label_text, offset, trend_points)
    angles = 0:30:330;
    distances = [4 5 6 7 8] * offset;  % Increased distances
    min_overlap = inf;
    best_pos = [x, y + offset];
    
    % Get label size
    temp_text = text(0, 0, label_text, 'Units', 'data');
    ext = get(temp_text, 'Extent');
    delete(temp_text);
    label_width = ext(3);
    label_height = ext(4);
    
    margin = 3;  % Increased margin
    
    for angle = angles
        for dist = distances
            test_x = x + dist * cosd(angle);
            test_y = y + dist * sind(angle);
            
            % Keep within plot bounds with margin
            test_x = min(max(test_x, 10), 90);
            test_y = min(max(test_y, 10), 90);
            
            % Calculate label bounds
            label_bounds = [test_x - label_width/2 - margin, ...
                          test_x + label_width/2 + margin, ...
                          test_y - label_height/2 - margin, ...
                          test_y + label_height/2 + margin];
            
            % Check overlap with trend line
            trend_overlap = 0;
            for i = 1:length(trend_points)-1
                if line_box_intersection(trend_points(i,:), trend_points(i+1,:), label_bounds)
                    trend_overlap = trend_overlap + 1;
                end
            end
            
            % Check overlap with existing labels and data points
            label_overlap = 0;
            for p = 1:size(prev_positions,1)
                if ~isempty(prev_positions) && prev_positions(p,1) ~= 0
                    dist_to_prev = norm([prev_positions(p,1) - test_x, prev_positions(p,2) - test_y]);
                    label_overlap = label_overlap + 1/(1 + dist_to_prev^2);
                end
            end
            
            % Calculate distance from data point
            point_dist = norm([x - test_x, y - test_y]);
            
            % Combined cost function with higher weight for trend line overlap
            total_cost = trend_overlap * 2 + label_overlap + point_dist * 0.05;
            
            if total_cost < min_overlap
                min_overlap = total_cost;
                best_pos = [test_x test_y];
            end
        end
    end
end

% Helper function to check line-box intersection
function intersects = line_box_intersection(p1, p2, box)
    % box = [left, right, bottom, top]
    box_lines = [
        [box(1) box(3)] [box(2) box(3)];  % bottom
        [box(2) box(3)] [box(2) box(4)];  % right
        [box(2) box(4)] [box(1) box(4)];  % top
        [box(1) box(4)] [box(1) box(3)]   % left
    ];
    
    intersects = false;
    for i = 1:4
        if line_intersection(p1, p2, box_lines(i,1:2), box_lines(i,3:4))
            intersects = true;
            return;
        end
    end
end

% Helper function to check line intersection
function intersects = line_intersection(p1, p2, p3, p4)
    x1 = p1(1); y1 = p1(2);
    x2 = p2(1); y2 = p2(2);
    x3 = p3(1); y3 = p3(2);
    x4 = p4(1); y4 = p4(2);
    
    denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if denominator == 0
        intersects = false;
        return;
    end
    
    t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denominator;
    u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denominator;
    
    intersects = t >= 0 && t <= 1 && u >= 0 && u <= 1;
end 