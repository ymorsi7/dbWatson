function anomalies = detect_anomalies(data)
    anomalies = struct();
    
    % Z-score based detection
    z_scores = zscore(data);
    anomalies.z_score_outliers = abs(z_scores) > 3;
    
    % IQR based detection
    q1 = prctile(data, 25);
    q3 = prctile(data, 75);
    iqr = q3 - q1;
    anomalies.iqr_outliers = (data < (q1 - 1.5*iqr)) | (data > (q3 + 1.5*iqr));
end 