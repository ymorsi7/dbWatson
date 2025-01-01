function merged = merge_predicates(original_predicates, llm_predicates)
    if isempty(original_predicates)
        merged = llm_predicates;
        return;
    end
    
    if isempty(llm_predicates)
        merged = original_predicates;
        return;
    end
    
    merged = [original_predicates; llm_predicates];
    merged = unique(merged, 'rows');
    merged = sortrows(merged, -4);  % Sort by confidence score
end 