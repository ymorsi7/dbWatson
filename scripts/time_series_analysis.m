function trend = calculate_trend(data)
    % Calculate linear trend
    n = size(data, 1);
    x = (1:n)';
    trend = struct();
    
    for i = 1:size(data, 2)
        p = polyfit(x, data(:,i), 1);
        trend.(['metric_' num2str(i)]) = struct(...
            'slope', p(1),...
            'intercept', p(2)...
        );
    end
end

function seasonality = detect_seasonality(data)
    % Detect seasonal patterns using FFT
    n = size(data, 1);
    seasonality = struct();
    
    for i = 1:size(data, 2)
        Y = fft(data(:,i));
        P2 = abs(Y/n);
        P1 = P2(1:floor(n/2)+1);
        P1(2:end-1) = 2*P1(2:end-1);
        f = (0:(n/2))/n;
        
        [~, idx] = max(P1(2:end));
        seasonality.(['metric_' num2str(i)]) = struct(...
            'frequency', f(idx+1),...
            'amplitude', P1(idx+1)...
        );
    end
end

function changepoints = find_changepoints(data)
    % Detect significant changes in metrics
    changepoints = struct();
    window = 5;
    threshold = 2;
    
    for i = 1:size(data, 2)
        series = data(:,i);
        diffs = abs(diff(movmean(series, window)));
        cp_idx = find(diffs > threshold * std(diffs));
        
        changepoints.(['metric_' num2str(i)]) = struct(...
            'indices', cp_idx,...
            'values', series(cp_idx)...
        );
    end
end 