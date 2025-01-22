function improvedRule = send_to_llm(ruleContext)
    % Send a rule to OpenAI's LLM for optimization
    url = 'https://api.openai.com/v1/chat/completions';
    apiKey = 'your-api-key';

    headers = [
        httpHeaderField('Content-Type', 'application/json');
        httpHeaderField('Authorization', ['Bearer ', apiKey])
    ];

    data = struct();
    data.model = 'gpt-4';
    data.messages = struct( ...
        'role', {'system', 'user'}, ...
        'content', { ...
            'You are an expert in MATLAB debugging and rule optimization.', ...
            ['Optimize this rule: ', ruleContext] ...
        } ...
    );

    response = webwrite(url, jsonencode(data), headers);
    improvedRule = response.choices(1).message.content;
end
