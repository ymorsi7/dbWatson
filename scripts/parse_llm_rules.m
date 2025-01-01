function [rules, predicates] = parse_llm_rules(llm_response, field_names)
    rules = struct();
    predicates = {};
    
    try
        parsed = jsondecode(llm_response);
        for i = 1:length(parsed.rules)
            rule = parsed.rules(i);
            rules(i).name = rule.name;
            rules(i).condition = rule.condition;
            rules(i).confidence = rule.confidence;
            
            predicates{end+1} = convert_rule_to_predicate(rule, field_names);
        end
    catch
        warning('Failed to parse LLM response, using fallback rules');
        rules = generate_fallback_rules(field_names);
        predicates = convert_rules_to_predicates(rules, field_names);
    end
end 