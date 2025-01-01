function correlations = analyze_correlations(data)
    correlations = struct();
    correlations.matrix = corrcoef(data);
    correlations.strong_pairs = find_strong_correlations(correlations.matrix, 0.7);
end

function strong_pairs = find_strong_correlations(corr_matrix, threshold)
    [rows, cols] = find(abs(corr_matrix) > threshold & corr_matrix ~= 1);
    strong_pairs = [rows, cols];
end 