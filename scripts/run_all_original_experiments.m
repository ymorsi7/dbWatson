function run_all_original_experiments()
    dataset_name = 'dbsherlock_dataset_tpcc_16w.mat';
    
    % Run all original experiments with LLM comparison
    perform_evaluation_single_causal_models(dataset_name);
    perform_evaluation_perfxplain(dataset_name);
    perform_evaluation_merged_causal_models(dataset_name);
    perform_evaluation_domain_knowledge(dataset_name);
    perform_evaluation_compound_situations(dataset_name);
    
    fprintf('All experiments completed with LLM comparisons.\n');
end 