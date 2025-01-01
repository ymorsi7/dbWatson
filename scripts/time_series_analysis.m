function trend = calculate_trend(data)
    % Simple linear trend analysis
    x = 1:size(data,1);
    trend = polyfit(x, mean(data,2), 1);
end

function seasonality = detect_seasonality(data)
    % Basic seasonality detection using FFT
    [f, P1] = periodogram(mean(data,2));
    [~, idx] = max(P1);
    seasonality = struct('period', 1/f(idx), 'power', P1(idx));
end

function points = find_changepoints(data)
    % Simple changepoint detection using mean shifts
    means = movmean(mean(data,2), 5);
    diffs = abs(diff(means));
    [~, points] = findpeaks(diffs, 'MinPeakHeight', 2*std(diffs));
end 