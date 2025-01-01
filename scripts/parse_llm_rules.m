function [rules, predicates] = parse_llm_rules(llm_response, field_names)
    try
        % Parse JSON response
        parsed = jsondecode(llm_response);
        
        % Extract rules
        if isfield(parsed, 'rules')
            rules = parsed.rules;
        else
            rules = struct();
        end
        
        % Extract predicates
        if isfield(parsed, 'predicates')
            predicates = parsed.predicates;
        else
            predicates = struct();
        end
        
        % Validate rules against field names
        rules = validate_rules(rules, field_names);
        predicates = validate_predicates(predicates, field_names);
        
    catch e
        warning('Failed to parse LLM rules: %s', e.message);
        rules = struct();
        predicates = struct();
    end
end

function rules = validate_rules(rules, field_names)
    fields = fieldnames(rules);
    for i = 1:length(fields)
        if ~ismember(fields{i}, field_names)
            rules = rmfield(rules, fields{i});
        end
    end
end

function predicates = validate_predicates(predicates, field_names)
    if ~isstruct(predicates)
        predicates = struct();
    end
    
    fields = fieldnames(predicates);
    for i = 1:length(fields)
        if ~ismember(fields{i}, field_names)
            predicates = rmfield(predicates, fields{i});
        end
    end
end 