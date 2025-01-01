classdef LLMExperimentParameter < ExperimentParameter
    properties
        use_llm_rules = true;
        llm_config
    end
    
    methods
        function obj = LLMExperimentParameter()
            obj@ExperimentParameter();
            obj.create_model = true;
            
            api_key = getenv('OPENAI_API_KEY');
            if isempty(api_key)
                warning(['OpenAI API key not found in environment variables.\n', ...
                    'To set it, run this command in MATLAB before running experiments:\n', ...
                    'setenv(''OPENAI_API_KEY'', ''your-key-here'')\n\n', ...
                    'Continuing with LLM features disabled.']);
                obj.use_llm_rules = false;
                obj.llm_config = struct();
            else
                obj.llm_config = struct(...
                    'api_key', api_key,...
                    'model', 'gpt-4-turbo-preview',...
                    'temperature', 0.7...
                );
            end
        end
    end
end 