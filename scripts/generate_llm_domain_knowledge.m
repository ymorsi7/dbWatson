function [domain_knowledge] = generate_llm_domain_knowledge(data)
    % Get base domain knowledge
    base_knowledge = generate_domain_knowledge(data);
    
    % Enhance with LLM-generated insights
    llm_knowledge = learn_domain_relationships(data);
    
    % Combine and validate knowledge
    domain_knowledge = merge_domain_knowledge(base_knowledge, llm_knowledge);
end

function llm_knowledge = learn_domain_relationships(data)
    metrics = data.test_datasets{1,1}.field_names;
    patterns = analyze_metric_patterns(data);
    
    % Generate LLM prompt for relationship discovery
    prompt = generate_relationship_prompt(metrics, patterns);
    
    % Get and parse LLM response
    relationships = get_llm_relationships(prompt);
    
    % Validate and format relationships
    llm_knowledge = validate_relationships(relationships, metrics);
end 