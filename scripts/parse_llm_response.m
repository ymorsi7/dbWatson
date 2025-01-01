function parsed_patterns = parse_llm_response(llm_response)
    try
        parsed = jsondecode(llm_response);
        if isfield(parsed, 'patterns')
            parsed_patterns = parsed.patterns;
        else
            parsed_patterns = struct();
        end
        
        parsed_patterns.timestamp = datetime('now');
        parsed_patterns.source = 'llm';
        parsed_patterns.confidence = get_confidence_scores(parsed);
        parsed_patterns.rules = get_validated_rules(parsed);
        
    catch e
        warning('Failed to parse LLM response: %s', e.message);
        parsed_patterns = struct();
    end
end

function confidence = get_confidence_scores(parsed)
    if isfield(parsed, 'confidence')
        confidence = parsed.confidence;
    else
        confidence = struct('overall', 0.5);
    end
end

function rules = get_validated_rules(parsed)
    if isfield(parsed, 'rules')
        rules = parsed.rules;
    else
        rules = struct();
    end
end 