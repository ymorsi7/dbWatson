function [mean_val, std_val, skew_val, kurt_val] = analyze_statistical_patterns(data)
    % Calculate basic statistical measures
    mean_val = mean(data.data);
    std_val = std(data.data);
    skew_val = skewness(data.data);
    kurt_val = kurtosis(data.data);
    
    % Calculate additional statistical metrics
    z_scores = zscore(data.data);
    outliers = abs(z_scores) > 3;
    
    % Return comprehensive statistical analysis
    statistical = struct(...
        'mean', mean_val,...
        'std', std_val,...
        'skewness', skew_val,...
        'kurtosis', kurt_val,...
        'outliers', sum(outliers),...
        'z_scores', z_scores...
    );
end 