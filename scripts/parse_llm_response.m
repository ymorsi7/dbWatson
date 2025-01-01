function parsed = parse_llm_response(response)
    try
        parsed = jsondecode(response);
        if ~isfield(parsed, 'patterns') || ~isfield(parsed, 'rules')
            parsed = struct('patterns', [], 'rules', [], 'confidence', []);
        end
    catch
        parsed = struct('patterns', [], 'rules', [], 'confidence', []);
        warning('Failed to parse LLM response');
    end
end 