function [rules, predicates] = parse_llm_rules(llm_response, field_names)
    % Parse the JSON response from LLM
    try
        parsed = jsondecode(llm_response);
        rules = parsed.rules;
        
        % Convert rules to predicates format
        predicates = cell(length(rules), 8);
        for i = 1:length(rules)
            rule = rules(i);
            for j = 1:length(rule.conditions)
                condition = rule.conditions{j};
                predicates{i,1} = i;  % predicate ID
                predicates{i,2} = condition.field;  % field name
                predicates{i,3} = 0;  % numeric type
                predicates{i,4} = rule.confidence;  % normalized difference
                predicates{i,5} = condition.threshold;  % lower bound
                predicates{i,6} = condition.threshold;  % upper bound
                predicates{i,7} = {};  % categories (empty for numeric)
                predicates{i,8} = sprintf('%s %s %.2f', ...
                    condition.field, ...
                    condition.operator, ...
                    condition.threshold);  % predicate name
            end
        end
    catch e
        warning('Failed to parse LLM response: %s', e.message);
        rules = struct('rules', []);
        predicates = cell(0, 8);
    end
end 