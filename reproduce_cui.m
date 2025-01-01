function reproduce_cui()
    while true
        fprintf('\n                << DBSherlock Experiments >>\n');
        fprintf('                1. Accuracy of Single Causal Models (Section 8.3)\n');
        fprintf('                2. DBSherlock Predicates versus PerfXplain (Section 8.4)\n');
        fprintf('                3. Effectiveness of Merged Causal Models (Section 8.5)\n');
        fprintf('                4. Effect of Incorporating Domain Knowledge (Section 8.6)\n');
        fprintf('                5. Explaining Compound Situations (Section 8.7)\n');
        fprintf('                6. Run all of the above (ETC: 4-5 hours)\n');
        fprintf('                7. LLM-Enhanced Analysis (New)\n');
        fprintf('                8. Run all including LLM analysis (ETC: 5-6 hours)\n\n');
        
        choice = input('Select an experiment to reproduce (1-8 or other input to exit): ');
        
        switch choice
            case 1
                perform_evaluation_single_causal_models();
            case 2
                perform_evaluation_perfxplain();
            case 3
                perform_evaluation_merged_causal_models();
            case 4
                perform_evaluation_domain_knowledge();
            case 5
                perform_evaluation_compound_situations();
            case 6
                run_all_original_experiments();
            case 7
                fprintf('\nRunning LLM-Enhanced Analysis...\n');
                [conf_llm, fscore_llm] = perform_evaluation_llm_enhanced('dbsherlock_dataset_tpcc_16w.mat');
                plot_llm_results(conf_llm, fscore_llm);
            case 8
                fprintf('\nRunning all experiments including LLM analysis...\n');
                run_all_original_experiments();
                [conf_llm, fscore_llm] = perform_evaluation_llm_enhanced('dbsherlock_dataset_tpcc_16w.mat');
                plot_combined_results(conf_llm, fscore_llm);
            otherwise
                fprintf('Exiting...\n');
                return;
        end
    end
end