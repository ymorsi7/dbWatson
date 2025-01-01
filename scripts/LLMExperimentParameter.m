classdef LLMExperimentParameter < ExperimentParameter
    properties
        use_llm_rules = true;
        model_name = 'gpt-4-turbo-preview';
        temperature = 0.7;
        max_tokens = 2048;
    end
    
    methods
        function obj = LLMExperimentParameter()
            obj = obj@ExperimentParameter();
            obj.num_discrete = 5;
            obj.diff_threshold = 0.1;
            obj.abnormal_multiplier = 1.5;
            obj.create_model = true;
        end
    end
end 