function combined_pattern = combine_patterns(template_pattern, learned_pattern)
    if isempty(template_pattern)
        combined_pattern = learned_pattern;
        return;
    end
    
    if isempty(learned_pattern)
        combined_pattern = template_pattern;
        return;
    end
    
    % Combine both patterns with an AND condition
    combined_pattern = sprintf('(%s) AND (%s)', template_pattern, learned_pattern);
end 