function combined = combine_patterns(base_pattern, learned_pattern)
    % Combine base rules with learned patterns
    combined = struct();
    
    % Merge statistical patterns
    if isfield(base_pattern, 'statistical') && isfield(learned_pattern, 'statistical')
        combined.statistical = merge_statistical(base_pattern.statistical, learned_pattern.statistical);
    end
    
    % Merge temporal patterns
    if isfield(base_pattern, 'temporal') && isfield(learned_pattern, 'temporal')
        combined.temporal = merge_temporal(base_pattern.temporal, learned_pattern.temporal);
    end
    
    % Merge correlation patterns
    if isfield(base_pattern, 'correlations') && isfield(learned_pattern, 'correlations')
        combined.correlations = merge_correlations(base_pattern.correlations, learned_pattern.correlations);
    end
end

function merged = merge_statistical(base, learned)
    merged = base;
    fields = fieldnames(learned);
    for i = 1:length(fields)
        if ~isfield(merged, fields{i})
            merged.(fields{i}) = learned.(fields{i});
        end
    end
end

function merged = merge_temporal(base, learned)
    merged = base;
    if isfield(learned, 'new_trends')
        merged.trends = [base.trends; learned.new_trends];
    end
    if isfield(learned, 'new_seasonality')
        merged.seasonality = [base.seasonality; learned.new_seasonality];
    end
end

function merged = merge_correlations(base, learned)
    merged = base;
    if isfield(learned, 'new_correlations')
        merged.correlations = [base.correlations; learned.new_correlations];
    end
end 