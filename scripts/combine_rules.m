function combined_rules = combine_rules(template_rules, historical_patterns)
    combined_rules = struct();
    
    % Merge template rules
    field_names = fieldnames(template_rules);
    for i = 1:length(field_names)
        combined_rules.(field_names{i}) = template_rules.(field_names{i});
    end
    
    % Add historical patterns
    if isfield(historical_patterns, 'llm_insights')
        insights = historical_patterns.llm_insights;
        field_names = fieldnames(insights);
        for i = 1:length(field_names)
            combined_rules.(['learned_' field_names{i}]) = insights.(field_names{i});
        end
    end
end 