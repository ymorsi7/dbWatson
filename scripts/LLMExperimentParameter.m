classdef LLMExperimentParameter
    properties
        use_llm_rules = false;
        create_model = false;
        model_name = '';
        num_discrete = 5;
        diff_threshold = 0.1;
        abnormal_multiplier = 1.5;
    end
    
    methods
        function obj = LLMExperimentParameter()
            % Constructor with default values
        end
    end
end 