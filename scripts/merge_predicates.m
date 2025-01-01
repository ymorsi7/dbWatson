function merged = merge_predicates(base_predicates, llm_predicates)
    if isempty(base_predicates)
        merged = llm_predicates;
        return;
    end
    
    if isempty(llm_predicates)
        merged = base_predicates;
        return;
    end
    
    merged = struct();
    base_fields = fieldnames(base_predicates);
    llm_fields = fieldnames(llm_predicates);
    
    for i = 1:length(base_fields)
        field = base_fields{i};
        merged.(field) = base_predicates.(field);
    end
    
    for i = 1:length(llm_fields)
        field = llm_fields{i};
        if isfield(merged, field)
            merged.(field) = [merged.(field); llm_predicates.(field)];
        else
            merged.(field) = llm_predicates.(field);
        end
    end
end 