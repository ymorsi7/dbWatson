% After getting original results
[llm_confidence, llm_fscore] = get_llm_results(dataset_name, causes);

% When plotting
bar_data = [original_results llm_results];
bar(bar_data, 'grouped');
legend('Original DBSherlock', 'DBWatson (LLM)', 'Location', 'southoutside'); 