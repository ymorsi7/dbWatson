function [llm_confidence, llm_fscore] = get_llm_results(dataset, case_names)
    try
        % Initialize LLM parameters
        llm_param = ExperimentParameter();
        llm_param.use_llm_rules = true;
        
        % Run LLM evaluation
        [conf_llm, fscore_llm] = perform_evaluation_llm_enhanced(dataset, [], [], []);
        
        % Match results to case names if provided
        if nargin > 1
            llm_confidence = zeros(length(case_names), 1);
            llm_fscore = zeros(length(case_names), 1);
            for i = 1:length(case_names)
                llm_confidence(i) = conf_llm(i);
                llm_fscore(i) = fscore_llm(i);
            end
        else
            llm_confidence = conf_llm;
            llm_fscore = fscore_llm;
        end
    catch e
        warning('LLM evaluation failed: %s. Using zeros for comparison.', e.message);
        if nargin > 1
            llm_confidence = zeros(length(case_names), 1);
            llm_fscore = zeros(length(case_names), 1);
        else
            llm_confidence = zeros(10, 1);  % Default size
            llm_fscore = zeros(10, 1);
        end
    end
end 