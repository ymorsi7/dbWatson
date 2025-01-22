classdef ExperimentParameter
    properties
        num_discrete = 500;
        diff_threshold = 0.2;
        abnormal_multiplier = 10;
        create_model = false;
        cause_string = '';
        model_name = '';
        domain_knowledge = [];
        correct_filter_list = [];
        introduce_lag = false;
        use_llm_rules = false;
    end
    
    methods
        function obj = ExperimentParameter()
        end
    end
end