classdef LLMExperimentParameter < ExperimentParameter
    properties
        use_llm_rules = true;
    end
    
    methods
        function obj = LLMExperimentParameter()
            obj = obj@ExperimentParameter();
        end
    end
end 