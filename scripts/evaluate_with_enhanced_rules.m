function [confidence, fscore] = evaluate_with_enhanced_rules(data, enhanced_rules, llm_param)
    num_cases = size(data.test_datasets, 1);
    confidence = zeros(num_cases, 1);
    fscore = zeros(num_cases, 1);
    
    for i = 1:num_cases
        try
            test_data = data.test_datasets{i};
            abnormal_regions = data.abnormal_regions{i};
            normal_regions = data.normal_regions{i};
            
            explanation = run_dbsherlock(test_data, abnormal_regions, normal_regions, [], llm_param);
            
            if ~isempty(explanation) && size(explanation, 1) >= 1
                confidence(i) = explanation{1, 2};  % confidence score
                fscore(i) = explanation{1, 4};      % f1-measure
            else
                warning('Empty or invalid explanation for case %d', i);
            end
        catch e
            warning('Failed to evaluate case %d: %s', i, e.message);
        end
    end
end 