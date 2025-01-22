function flaggedData = apply_rules(data, threshold)
    % Apply improved rule logic to flag data
    flaggedData = sum(isnan(data), 2) > threshold * size(data, 2);
end
