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
    NUMERIC = 0;
    CATEGORICAL = 1;
    
    % Generate predicates
    predicates = {};
    if exp_param.use_llm_rules && ~isempty(exp_param.current_rules)
        predicates = exp_param.current_rules;
    else
        % Process data and generate predicates
        for i = 3:length(field_names)  % Skip first two columns
            values = data(:, i);
            if isnumeric(values)
                [partitions, boundaries] = generate_partitions(values, abnormalIdx, normalIdx);
                predicates = add_numeric_predicates(predicates, field_names{i}, partitions, boundaries, i);
            else
                predicates = add_categorical_predicates(predicates, field_names{i}, values, abnormalIdx, normalIdx, i);
            end
        end
    end
    
    % Load existing causal models
    causalModels = loadCausalModels_Combiner();
    
    % Initialize explanation structure
    explanation = cell(size(causalModels, 2), 5);  % [cause, confidence, precision, f1_score, recall]
    
    % Evaluate predicates against each causal model
    for i = 1:size(causalModels, 2)
        if isempty(causalModels{i}) || ~isfield(causalModels{i}, 'predicates')
            continue;
        end
        
        model_predicates = causalModels{i}.predicates;
        matched_predicates = 0;
        total_predicates = size(predicates, 1);
        
        % Compare predicates
        for j = 1:size(predicates, 1)
            for k = 1:size(model_predicates, 1)
                if strcmp(predicates{j,2}, model_predicates{k,2})
                    matched_predicates = matched_predicates + 1;
                    break;
                end
            end
        end
        
        % Calculate metrics
        if total_predicates > 0 && size(model_predicates, 1) > 0
            precision = matched_predicates / total_predicates;
            recall = matched_predicates / size(model_predicates, 1);
            if (precision + recall) > 0
                f1_score = 2 * (precision * recall) / (precision + recall);
            else
                f1_score = 0;
            end
            confidence = f1_score;  % Use F1-score as confidence
            
            % Store results
            explanation{i,1} = causalModels{i}.cause;
            explanation{i,2} = confidence * 100;  % Convert to percentage
            explanation{i,3} = precision * 100;
            explanation{i,4} = f1_score * 100;
            explanation{i,5} = recall * 100;
        end
    end
    
    % Remove empty rows and sort by confidence
    explanation = explanation(~cellfun(@isempty, explanation(:,1)), :);
    if ~isempty(explanation)
        [~, sortIdx] = sort(cell2mat(explanation(:,2)), 'descend');
        explanation = explanation(sortIdx, :);
    end
    
    % Create and save model if requested
    if exp_param.create_model
        model = struct('predicates', predicates, 'cause', exp_param.cause_string);
        if ~isempty(modelName)
            save(fullfile(model_directory, [modelName '.mat']), 'model');
        end
    else
        model = [];
    end
end

% Helper functions
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
