function trend = calculate_trend(data)
    % Fit a linear trend to the time series data
    x = 1:size(data, 1);
    trend = zeros(1, size(data, 2));
    
    for i = 1:size(data, 2)
        p = polyfit(x', data(:,i), 1);
        trend(i) = p(1); % Return slope as trend indicator
    end
end 