function trend = calculate_trend(data)
    % Calculate linear trend
    x = 1:size(data, 1);
    trend = struct();
    
    for i = 1:size(data, 2)
        p = polyfit(x', data(:,i), 1);
        trend.slope(i) = p(1);
        trend.intercept(i) = p(2);
    end
end

function seasonality = detect_seasonality(data)
    % Detect seasonal patterns using FFT
    seasonality = struct();
    
    for i = 1:size(data, 2)
        [f, P1] = perform_fft(data(:,i));
        [peaks, locs] = findpeaks(P1);
        seasonality.periods{i} = 1./f(locs);
        seasonality.strengths{i} = peaks;
    end
end

function changepoints = find_changepoints(data)
    % Detect significant changes in time series
    changepoints = struct();
    window = 10; % sliding window size
    
    for i = 1:size(data, 2)
        series = data(:,i);
        changes = detect_changes(series, window);
        changepoints.locations{i} = find(changes);
        changepoints.magnitudes{i} = abs(diff(series(changes)));
    end
end

function [f, P1] = perform_fft(x)
    L = length(x);
    Y = fft(x);
    P2 = abs(Y/L);
    P1 = P2(1:floor(L/2+1));
    P1(2:end-1) = 2*P1(2:end-1);
    f = (0:(L/2))/L;
end

function changes = detect_changes(series, window)
    n = length(series);
    changes = zeros(n, 1);
    
    for i = (window+1):(n-window)
        before = mean(series(i-window:i-1));
        after = mean(series(i:i+window-1));
        if abs(after - before) > 2*std(series)
            changes(i) = 1;
        end
    end
end 