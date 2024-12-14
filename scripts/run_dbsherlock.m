function [explanation, metrics, patterns, correlations] = run_dbsherlock(data, abnormal_regions, normal_regions, attribute_types, param)
    % Enhanced output to support LLM analysis
    
    % Original DBSherlock analysis
    [causeRank, metrics, patterns] = analyze_performance(data, abnormal_regions, normal_regions, param);
    
    % Calculate additional statistical features
    correlations = calculate_metric_correlations(data);
    
    % Enhance the explanation with more details
    for i=1:size(causeRank,1)
        cause = causeRank{i,1};
        confidence = causeRank{i,2};
        precision = causeRank{i,3};
        f1_score = causeRank{i,4};
        recall = causeRank{i,5};
        
        % Add pattern information
        pattern_info = patterns{i};
        
        % Create enhanced explanation structure
        explanation{i} = struct(...
            'cause', cause, ...
            'confidence', confidence, ...
            'precision', precision, ...
            'f1_score', f1_score, ...
            'recall', recall, ...
            'patterns', pattern_info, ...
            'statistical_significance', calculate_significance(data, pattern_info), ...
            'temporal_features', extract_temporal_features(data, abnormal_regions) ...
        );
    end
end

function corr_matrix = calculate_metric_correlations(data)
    % Calculate correlation matrix between metrics
    metrics = data.data;
    corr_matrix = corrcoef(metrics);
end

function sig = calculate_significance(data, pattern)
    % Calculate statistical significance of patterns
    % Implementation details here
end

function features = extract_temporal_features(data, regions)
    % Extract temporal patterns and features
    % Implementation details here
end
