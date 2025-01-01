function parsed_response = parse_llm_response(llm_response)
    try
        parsed_response = jsondecode(llm_response);
    catch
        warning('Failed to parse LLM response, using default structure');
        parsed_response = struct(...
            'pattern', '',...
            'confidence', 0.5,...
            'metrics', {}...
        );
    end
end 