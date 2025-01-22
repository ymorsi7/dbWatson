function flaggedData = check_null_values(data, threshold)
    % Improved rule: Flag rows with excessive null values
    flaggedData = sum(isnan(data), 2) > threshold * size(data, 2);
end
