function changepoints = find_changepoints(data)
    % Detect significant changes in the time series
    changepoints = cell(1, size(data, 2));
    
    for i = 1:size(data, 2)
        series = data(:,i);
        diffs = abs(diff(series));
        threshold = mean(diffs) + 2*std(diffs);
        cp = find(diffs > threshold)';
        changepoints{i} = cp;
    end
end 