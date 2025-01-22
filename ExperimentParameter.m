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
        expand_normal_region = false;
        expand_normal_size = 0;
        lag_min = 0;
        lag_max = 0;
        find_lag = false;
    end
    
    methods
        function obj = ExperimentParameter()
        end
    end
end