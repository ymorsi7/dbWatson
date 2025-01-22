function [rules, predicates] = llm_rule_generator(dataset, abnormalIdx, normalIdx, field_names, model_name)
    % Initialize outputs
    rules = {};
    predicates = {};
    
    % Constants matching run_dbsherlock.m
    NUMERIC = 0;
    CATEGORICAL = 1;
    
    try
        data = dataset.data;
        numAttr = size(data, 2);
        
        % Process each field (skip timestamp columns)
        for i = 3:numAttr
            field_name = field_names{i};
            values = data(:, i);
            
            % Get abnormal and normal values
            abnormal_values = values(abnormalIdx);
            normal_values = values(normalIdx);
            
            if isnumeric(values)
                % Numeric field analysis
                abnormal_mean = mean(abnormal_values);
                abnormal_std = std(abnormal_values);
                normal_mean = mean(normal_values);
                
                if abs(abnormal_mean - normal_mean) > abnormal_std
                    % Create predicate structure matching run_dbsherlock format
                    predicates{end+1, 1} = i;  % field index
                    predicates{end, 2} = sprintf('%s > %.6f', field_name, normal_mean + abnormal_std);  % predicate string
                    predicates{end, 3} = NUMERIC;  % type
                    predicates{end, 4} = abs(abnormal_mean - normal_mean) / normal_mean;  % normalized difference
                    predicates{end, 5} = normal_mean;  % lower bound
                    predicates{end, 6} = abnormal_mean;  % upper bound
                    predicates{end, 7} = [];  % categorical values (empty for numeric)
                    predicates{end, 8} = field_name;  % field name
                    predicates{end, 9} = mean(normal_values);  % normal average
                    predicates{end, 10} = mean(abnormal_values);  % abnormal average
                    
                    rules{end+1} = predicates{end, 2};
                end
            else
                % Categorical field analysis
                unique_abnormal = unique(abnormal_values);
                if ~isempty(unique_abnormal)
                    predicates{end+1, 1} = i;
                    predicates{end, 2} = sprintf('%s in {%s}', field_name, strjoin(string(unique_abnormal), ','));
                    predicates{end, 3} = CATEGORICAL;
                    predicates{end, 4} = 1.0;  % normalized difference for categorical
                    predicates{end, 5} = [];  % no bounds for categorical
                    predicates{end, 6} = [];
                    predicates{end, 7} = unique_abnormal;
                    predicates{end, 8} = field_name;
                    predicates{end, 9} = mode(normal_values);
                    predicates{end, 10} = mode(abnormal_values);
                    
                    rules{end+1} = predicates{end, 2};
                end
            end
        end
        
    catch e
        warning('LLM rule generation failed: %s', e.message);
        rethrow(e);
    end
end 