function predicate = convert_rule_to_predicate(rule, field_names)
    predicate = {1, ...                    % has_predicate
                0, ...                     % in_conflict
                0, ...                     % type (numeric)
                rule.confidence, ...       % confidence score
                rule.threshold_low, ...    % lower bound
                rule.threshold_high, ...   % upper bound
                {}, ...                    % categorical values
                rule.name};               % predicate name
end

function predicates = convert_rules_to_predicates(rules, field_names)
    predicates = {};
    for i = 1:length(rules)
        predicates{end+1} = convert_rule_to_predicate(rules(i), field_names);
    end
end 