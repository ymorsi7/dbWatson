function [rules, predicates] = llm_rule_generator(dataset, abnormalIdx, normalIdx, field_names, model_name)
    % Check if OPENAI_API_KEY is set
    if isempty(getenv('OPENAI_API_KEY'))
        error('OPENAI_API_KEY environment variable is not set. Please set it using: setenv(''OPENAI_API_KEY'', ''your-key-here'')');
    end
    
    % Initialize outputs
    rules = struct('rules', []);
    predicates = cell(0, 8);
    
    try
        % Extract metrics and patterns
        [metrics, valid_field_names] = extract_metrics(dataset.data, field_names);
        patterns = extract_patterns(dataset.data, abnormalIdx, normalIdx);
        
        % Generate and send prompt to OpenAI
        prompt = generate_prompt(metrics, patterns, model_name, field_names, valid_field_names);
        response = call_openai(prompt);
        
        % Parse response into predicates format
        [rules, predicates] = parse_llm_rules(response, field_names);
    catch e
        warning('LLM rule generation failed: %s', e.message);
        rethrow(e);
    end
end

function [metrics, valid_field_names] = extract_metrics(data, field_names)
    metrics = struct();
    valid_field_names = cell(size(field_names));
    
    for i = 1:length(field_names)
        % Convert field name to valid MATLAB identifier
        valid_name = matlab.lang.makeValidName(field_names{i});
        valid_field_names{i} = valid_name;
        
        metrics.(valid_name) = struct(...
            'mean', mean(data(:,i)),...
            'std', std(data(:,i)));
    end
end

function patterns = extract_patterns(data, abnormalIdx, normalIdx)
    abnormal_data = data(abnormalIdx, :);
    normal_data = data(normalIdx, :);
    patterns = struct(...
        'abnormal_mean', mean(abnormal_data),...
        'normal_mean', mean(normal_data),...
        'abnormal_std', std(abnormal_data),...
        'normal_std', std(normal_data));
end

function prompt = generate_prompt(metrics, patterns, model_name, original_field_names, valid_field_names)
    % Create a mapping explanation for the LLM
    field_mapping = '';
    for i = 1:length(original_field_names)
        if ~strcmp(original_field_names{i}, valid_field_names{i})
            field_mapping = sprintf('%s\n"%s" is referred to as "%s" in the metrics', ...
                field_mapping, original_field_names{i}, valid_field_names{i});
        end
    end
    
    prompt = sprintf('Analyze metrics for %s:\n%s\nPatterns:\n%s\nField name mappings:%s\n\nPlease use the original field names in your response.', ...
        model_name, jsonencode(metrics), jsonencode(patterns), field_mapping);
end

function response = call_openai(prompt)
    try
        % Properly format headers as Mx2 cell array
        headers = {
            'Authorization', ['Bearer ' getenv('OPENAI_API_KEY')]
            'Content-Type', 'application/json'
        };
        
        options = weboptions('HeaderFields', headers, 'MediaType', 'application/json');
        
        % Format the request body according to OpenAI's API specification
        data = struct();
        data.model = 'gpt-4-turbo-preview';
        data.messages = [{...
            'role', 'system', ...
            'content', 'You are an AI assistant analyzing database metrics and patterns. Provide clear, concise rules that explain anomalies in the data.'
        }; {
            'role', 'user', ...
            'content', prompt
        }];
        data.temperature = 0.7;
        data.max_tokens = 1000;
        
        % Convert the data to JSON string manually to ensure proper formatting
        json_str = jsonencode(data);
        
        % Make the API call
        response = webwrite('https://api.openai.com/v1/chat/completions', json_str, options);
        
        % Extract the response content
        if isfield(response, 'choices') && ~isempty(response.choices) && isfield(response.choices(1), 'message')
            response = response.choices(1).message.content;
        else
            error('Unexpected API response format');
        end
    catch e
        if contains(e.message, 'SSL')
            % If SSL error, try with certificate verification disabled
            warning('SSL verification failed. Attempting with verification disabled...');
            options = weboptions('HeaderFields', headers, 'CertificateFilename', '', 'MediaType', 'application/json');
            
            response = webwrite('https://api.openai.com/v1/chat/completions', json_str, options);
            if isfield(response, 'choices') && ~isempty(response.choices) && isfield(response.choices(1), 'message')
                response = response.choices(1).message.content;
            else
                error('Unexpected API response format');
            end
        else
            rethrow(e);
        end
    end
end

function [rules, predicates] = parse_llm_rules(response, field_names)
    % Initialize outputs
    rules = struct('rules', []);
    predicates = cell(0, 8);
    
    try
        % Split response into lines
        lines = strsplit(response, '\n');
        
        % Process each line as a potential rule
        rule_count = 0;
        for i = 1:length(lines)
            line = strtrim(lines{i});
            if isempty(line)
                continue;
            end
            
            % Try to extract rule components
            try
                [field, operator, value] = parse_rule_line(line, field_names);
                if ~isempty(field)
                    rule_count = rule_count + 1;
                    rules.rules(rule_count).field = field;
                    rules.rules(rule_count).operator = operator;
                    rules.rules(rule_count).value = value;
                    
                    % Add to predicates cell array
                    predicates(end+1,:) = {field, operator, value, '', '', '', '', ''};
                end
            catch
                warning('Failed to parse rule: %s', line);
            end
        end
    catch e
        warning('Failed to parse LLM response: %s', e.message);
    end
end

function [field, operator, value] = parse_rule_line(line, field_names)
    % Initialize outputs
    field = '';
    operator = '';
    value = '';
    
    % Common operators to look for
    operators = {'>', '<', '>=', '<=', '=', '~='};
    
    % Find which field name is mentioned in the line
    field_idx = find(cellfun(@(x) contains(lower(line), lower(x)), field_names), 1);
    if isempty(field_idx)
        return;
    end
    field = field_names{field_idx};
    
    % Find which operator is used
    for op = operators
        if contains(line, op{1})
            operator = op{1};
            break;
        end
    end
    if isempty(operator)
        return;
    end
    
    % Extract the value
    parts = strsplit(line, operator);
    if length(parts) >= 2
        value_str = strtrim(parts{2});
        % Try to convert to number if possible
        value = str2double(value_str);
        if isnan(value)
            value = value_str;
        end
    end
end