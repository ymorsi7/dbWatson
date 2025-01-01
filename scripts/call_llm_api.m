function response = call_llm_api(prompt, config)
    try
        url = 'https://api.openai.com/v1/chat/completions';
        headers = {'Content-Type', 'application/json',...
                  'Authorization', ['Bearer ' config.api_key]};
        
        data = struct(...
            'model', config.model,...
            'messages', {{struct('role', 'system', 'content', 'You are a database performance expert.'),...
                         struct('role', 'user', 'content', prompt)}},...
            'temperature', config.temperature...
        );
        
        options = weboptions('HeaderFields', headers, 'RequestMethod', 'post');
        response_raw = webwrite(url, jsonencode(data), options);
        response = jsondecode(response_raw).choices(1).message.content;
    catch e
        error('LLM API call failed: %s', e.message);
    end
end 