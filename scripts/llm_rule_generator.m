function [rules, predicates] = llm_rule_generator(dataset, abnormalIdx, normalIdx, exp_param)
    % Initialize outputs
    rules = {};
    predicates = {};
    
    % Validate inputs
    if isempty(dataset) || isempty(abnormalIdx) || isempty(normalIdx)
        warning('Invalid input parameters');
        return;
    end
    
    % Extract field names and data
    field_names = dataset.field_names;
    data = dataset.data;
    
    % Process each field (skipping first two columns)
    for i = 3:length(field_names)
        values = data(:, i);
        field_name = field_names{i};
        
        % Get abnormal and normal values
        abnormal_values = values(abnormalIdx);
        normal_values = values(normalIdx);
        
        % Skip empty or invalid fields
        if isempty(abnormal_values) || isempty(normal_values)
            continue;
        end
        
        % Generate rules based on data type
        if isnumeric(values)
            % Numeric field analysis
            abnormal_mean = mean(abnormal_values);
            abnormal_std = std(abnormal_values);
            normal_mean = mean(normal_values);
            
            % Add rule based on significant deviation
            if abs(abnormal_mean - normal_mean) > abnormal_std
                predicates{end+1, 1} = i;
                if abnormal_mean > normal_mean
                    predicates{end, 2} = sprintf('%s > %.6f', field_name, normal_mean + abnormal_std);
                else
                    predicates{end, 2} = sprintf('%s < %.6f', field_name, normal_mean - abnormal_std);
                end
                predicates{end, 3} = 0; % NUMERIC
                rules{end+1} = predicates{end, 2};
            end
        else
            % Categorical field analysis
            unique_abnormal = unique(abnormal_values);
            if ~isempty(unique_abnormal)
                predicates{end+1, 1} = i;
                predicates{end, 2} = sprintf('%s in {%s}', field_name, strjoin(string(unique_abnormal), ','));
                predicates{end, 3} = 1; % CATEGORICAL
                rules{end+1} = predicates{end, 2};
            end
        end
    end
end