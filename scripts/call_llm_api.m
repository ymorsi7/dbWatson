function response = call_llm_api(prompt, config)
    % Validate API key
    if isempty(config.api_key)
        error('OpenAI API key not set. Use setenv(''OPENAI_API_KEY'', ''your-key-here'')');
    end
    
    % Prepare the request
    url = 'https://api.openai.com/v1/chat/completions';
    headers = {'Content-Type', 'application/json';
               'Authorization', ['Bearer ' config.api_key]};
    
    % Construct the message
    data = struct(...
        'model', config.model,...
        'messages', {{struct('role', 'user', 'content', prompt)}},...
        'temperature', config.temperature,...
        'max_tokens', 2048...
    );
    
    % Make the API call
    options = weboptions('HeaderFields', headers, 'RequestMethod', 'post');
    try
        raw_response = webwrite(url, jsonencode(data), options);
        response = jsondecode(raw_response);
        response = response.choices(1).message.content;
    catch e
        error('OpenAI API call failed: %s', e.message);
    end
end 