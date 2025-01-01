classdef LLMExperimentParameter < ExperimentParameter
    properties
        use_llm_rules = false;
        model_name = '';
    end
    
    methods
        function obj = LLMExperimentParameter()
            obj@ExperimentParameter();
        end
    end
end 