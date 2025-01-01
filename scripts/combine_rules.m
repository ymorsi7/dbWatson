function enhanced_rules = combine_rules(template_rules, learned_patterns)
    enhanced_rules = struct();
    fields = fieldnames(template_rules);
    
    for i = 1:length(fields)
        field = fields{i};
        if isfield(learned_patterns, field)
            enhanced_rules.(field) = struct(...
                'metrics', template_rules.(field).metrics,...
                'pattern', combine_patterns(template_rules.(field).pattern, learned_patterns.(field).pattern),...
                'confidence', max(template_rules.(field).confidence, learned_patterns.(field).confidence)...
            );
        else
            enhanced_rules.(field) = template_rules.(field);
        end
    end
    
    learned_fields = fieldnames(learned_patterns);
    for i = 1:length(learned_fields)
        field = learned_fields{i};
        if ~isfield(enhanced_rules, field)
            enhanced_rules.(field) = learned_patterns.(field);
        end
    end
end 