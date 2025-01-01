function response = call_llm_api(prompt, config)
    try
        % Prepare the API request
        url = 'https://api.openai.com/v1/chat/completions';
        headers = [
            matlab.net.http.HeaderField('Content-Type', 'application/json')
            matlab.net.http.HeaderField('Authorization', ['Bearer ' config.api_key])
        ];
        
        body = struct(...
            'model', config.model,...
            'messages', {{struct('role', 'user', 'content', prompt)}},...
            'temperature', config.temperature...
        );
        
        request = matlab.net.http.RequestMessage('post', headers, body);
        response = send(request, url);
        
        if response.StatusCode == 200
            content = response.Body.Data.choices(1).message.content;
        else
            error('API call failed with status code: %d', response.StatusCode);
        end
    catch e
        warning('API call failed: %s', e.message);
        content = '{"rules": {}, "predicates": {}}';
    end
    
    response = content;
end 