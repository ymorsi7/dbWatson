function [explanation, model] = run_dbsherlock(dataset, abnormalIdx, normalIdx, modelName, exp_param)
    % Initialize default values
    if nargin < 4 || isempty(modelName)
        modelName = '';
    end
    if nargin < 5
        exp_param = ExperimentParameter();
    end
    
    % Set default model directory
    model_directory = [pwd '/causal_models'];
    
    % Initialize variables
    data = dataset.data;
    field_names = dataset.field_names;
    if ~isa(exp_param, 'ExperimentParameter')
        error('exp_param must be an object of the class ExperimentParameter');
    end
    
    % Constants
    NORMAL_PARTITION = 1;
    ABNORMAL_PARTITION = 2;
    NUMERIC = 0;
    CATEGORICAL = 1;
    
    % Check if we should use LLM rules first
    if exp_param.use_llm_rules && isfield(exp_param, 'current_rules') && ~isempty(exp_param.current_rules)
        predicates = exp_param.current_rules;
        goto_evaluation = true;
    else
        goto_evaluation = false;
        % Generate predicates from data
        predicates = {};
        attribute_types = zeros(size(field_names, 2), 1);
        
        % Process data and generate predicates
        for i = 3:length(field_names)  % Skip first two columns
            values = data(:, i);
            if isnumeric(values)
                attribute_types(i) = NUMERIC;
            else
                attribute_types(i) = CATEGORICAL;
            end
            
            % Generate partitions and boundaries
            if attribute_types(i) == NUMERIC
                [partitions, boundaries] = generate_partitions(values, abnormalIdx, normalIdx);
                predicates = add_numeric_predicates(predicates, field_names{i}, partitions, boundaries, i);
            else
                predicates = add_categorical_predicates(predicates, field_names{i}, values, abnormalIdx, normalIdx, i);
            end
        end
    end
    
    % Rest of the function remains the same
    [reference lines 500-649 from scripts/run_dbsherlock.m]
end

% Helper functions moved outside main function
function [partitions, boundaries] = generate_partitions(values, abnormalIdx, normalIdx)
    % Implementation of partition generation
    partitions = ones(1, length(values));  % Default to NORMAL
    partitions(abnormalIdx) = 2;  % ABNORMAL
    boundaries = sort(unique(values));
end

function predicates = add_numeric_predicates(predicates, field_name, partitions, boundaries, idx)
    % Add numeric predicates
    if ~isempty(partitions) && sum(partitions == 2) > 0
        predicates{end+1, 1} = idx;
        predicates{end, 2} = sprintf('%s > %.6f', field_name, mean(boundaries));
        predicates{end, 3} = 0;  % NUMERIC
    end
end

function predicates = add_categorical_predicates(predicates, field_name, values, abnormalIdx, normalIdx, idx)
    % Add categorical predicates
    abnormal_values = unique(values(abnormalIdx));
    if ~isempty(abnormal_values)
        predicates{end+1, 1} = idx;
        predicates{end, 2} = sprintf('%s in {%s}', field_name, strjoin(string(abnormal_values), ','));
        predicates{end, 3} = 1;  % CATEGORICAL
    end
end
