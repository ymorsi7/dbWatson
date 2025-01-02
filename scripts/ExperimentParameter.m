classdef ExperimentParameter
	properties
		num_discrete = 500;
		diff_threshold = 0.2;
		abnormal_multiplier = 10;
		create_model = false;
		use_llm_rules = false;
		cause_string = '';
		model_name = '';
		expand_normal_region = false;
		expand_normal_size = 0;
		introduce_lag = false;
		find_lag = false;
		lag_min = 0;
		lag_max = 0;
		domain_knowledge = struct();
	end
	
	methods
		function obj = ExperimentParameter()
			% Constructor
		end
	end
end
