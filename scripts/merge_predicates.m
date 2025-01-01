function merged = merge_predicates(original_predicates, llm_predicates)
    % Initialize merged predicates array
    merged = original_predicates;
    
    % Add LLM-generated predicates with new IDs
    if ~isempty(llm_predicates)
        start_id = size(merged, 1) + 1;
        for i = 1:size(llm_predicates, 1)
            new_row = llm_predicates(i,:);
            new_row{1} = start_id + i - 1;  % Update predicate ID
            merged(end+1,:) = new_row;
        end
    end
end 