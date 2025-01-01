function correlations = calculate_correlations(data, abnormalIdx, normalIdx)
    % Calculate correlations for both normal and abnormal regions
    abnormal_data = data(abnormalIdx, :);
    normal_data = data(normalIdx, :);
    
    correlations = struct(...
        'abnormal', corrcoef(abnormal_data),...
        'normal', corrcoef(normal_data),...
        'difference', corrcoef(abnormal_data) - corrcoef(normal_data)...
    );
    
    [~, p_values] = corrcoef(data);
    correlations.significance = p_values < 0.05;
end 