clc; clear; close all;

%% Load the TrainingSamplesDCT_8.mat file
train_data = load('TrainingSamplesDCT_8_new.mat');
trainFG = train_data.TrainsampleDCT_FG;
trainBG = train_data.TrainsampleDCT_BG;

%% Shared Parameters
num_dimensions = 64;
err_convergence = 1e-3; % Relaxed threshold
max_iterations = 100; % Reduced maximum iterations

% Load images once
cheetah = im2double(imread('cheetah.bmp'));
groundtruth = im2double(imread('cheetah_mask.bmp'));
zig_zag = load('Zig-Zag Pattern.txt') + 1;

% Prior probabilities
PY_FG = size(trainFG, 1) / (size(trainFG, 1) + size(trainBG, 1));
PY_BG = size(trainBG, 1) / (size(trainFG, 1) + size(trainBG, 1));

% Dimensions to test as specified in the assignment
test_dimensions = [1, 2, 4, 8, 16, 24, 32, 64];
[m, n] = size(cheetah);

%% Part A: 5 Different Initializations with C=8
C = 8; % Number of mixtures for part A
num_runs = 5; % Number of different initializations

% Storage for all models
models_A = struct('FG', cell(1, num_runs), 'BG', cell(1, num_runs));

% Train multiple models with different initializations
for run = 1:num_runs
    fprintf('Part A - Training model set %d/%d\n', run, num_runs);
    rng(run); % Set different random seed for each run
    
    %% Train FG Model
    % Initialize parameters
    weights = abs(randn(1, C));
    weights_sum = sum(weights);
    
    % Initialize mixture parameters
    for c = 1:C
        random_index = randi([1, size(trainFG, 1)]);
        u(:, c) = trainFG(random_index, :)';
        d_temp = 0.5 + 0.5 * rand(num_dimensions, 1); % More stable initialization
        sigma(:, :, c) = diag(d_temp);
        ww(c) = weights(c) / weights_sum;
    end
    
    % EM Algorithm for FG
    n = 1;
    err_estimation = 2;
    
    while (err_estimation > err_convergence && n <= max_iterations)
        if mod(n, 10) == 0
            fprintf('FG Iteration %d, Error: %f\n', n, err_estimation);
        end
        
        %% E Step
        for i = 1:size(trainFG, 1)
            x_i = trainFG(i, :)';
            denom = 0;
            
            % Calculate denominator
            for iter1 = 1:C
                denom_temp = mvnpdf(x_i, u(:, iter1), sigma(:, :, iter1));
                denom = denom + (denom_temp * ww(iter1));
            end
            
            % Calculate responsibilities
            for j = 1:C
                h_temp = mvnpdf(x_i, u(:, j), sigma(:, :, j));
                h(i, j) = (h_temp * ww(j)) / max(denom, 1e-10);
                h(i, j) = max(h(i, j), 1e-10); % Numerical stability
            end
        end
        
        %% M Step
        for j = 1:C
            % Update means
            numerator1 = h(:, j) .* trainFG;
            denom2 = sum(h(:, j));
            u_new(:, j) = sum(numerator1, 1)' / denom2;
            
            % Update weights
            ww_new(j) = mean(h(:, j));
            ww_new(j) = max(ww_new(j), 1e-10);
            
            % Update covariances with better numerical stability
            diff_matrix = trainFG' - u(:, j);
            sigma_temp = (diff_matrix * diag(h(:, j)) * diff_matrix') / denom2;
            diag_terms = max(diag(sigma_temp), 1e-6);
            sigma_new(:, :, j) = diag(diag_terms);
        end
        
        % Normalize weights
        ww_new = ww_new / sum(ww_new);
        
        % Update parameters and compute error
        err_estimation = norm(u_new - u, 'fro') / norm(u, 'fro');
        u = u_new;
        ww = ww_new;
        sigma = sigma_new;
        n = n + 1;
    end
    
    % Store FG model
    models_A(run).FG.u = u;
    models_A(run).FG.sigma = sigma;
    models_A(run).FG.ww = ww;
    clear u sigma ww u_new sigma_new ww_new h;
    
    %% Train BG Model with same process
    % Initialize parameters
    weights = abs(randn(1, C));
    weights_sum = sum(weights);
    
    % Initialize mixture parameters
    for c = 1:C
        random_index = randi([1, size(trainBG, 1)]);
        u(:, c) = trainBG(random_index, :)';
        d_temp = 0.5 + 0.5 * rand(num_dimensions, 1);
        sigma(:, :, c) = diag(d_temp);
        ww(c) = weights(c) / weights_sum;
    end
    
    % EM Algorithm for BG
    n = 1;
    err_estimation = 2;
    
    while (err_estimation > err_convergence && n <= max_iterations)
        if mod(n, 10) == 0
            fprintf('BG Iteration %d, Error: %f\n', n, err_estimation);
        end
        
        % E Step
        for i = 1:size(trainBG, 1)
            x_i = trainBG(i, :)';
            denom = 0;
            
            for iter1 = 1:C
                denom_temp = mvnpdf(x_i, u(:, iter1), sigma(:, :, iter1));
                denom = denom + (denom_temp * ww(iter1));
            end
            
            for j = 1:C
                h_temp = mvnpdf(x_i, u(:, j), sigma(:, :, j));
                h(i, j) = (h_temp * ww(j)) / max(denom, 1e-10);
                h(i, j) = max(h(i, j), 1e-10);
            end
        end
        
        % M Step
        for j = 1:C
            numerator1 = h(:, j) .* trainBG;
            denom2 = sum(h(:, j));
            u_new(:, j) = sum(numerator1, 1)' / denom2;
            
            ww_new(j) = mean(h(:, j));
            ww_new(j) = max(ww_new(j), 1e-10);
            
            diff_matrix = trainBG' - u(:, j);
            sigma_temp = (diff_matrix * diag(h(:, j)) * diff_matrix') / denom2;
            diag_terms = max(diag(sigma_temp), 1e-6);
            sigma_new(:, :, j) = diag(diag_terms);
        end
        
        ww_new = ww_new / sum(ww_new);
        
        err_estimation = norm(u_new - u, 'fro') / norm(u, 'fro');
        u = u_new;
        ww = ww_new;
        sigma = sigma_new;
        n = n + 1;
    end
    
    % Store BG model
    models_A(run).BG.u = u;
    models_A(run).BG.sigma = sigma;
    models_A(run).BG.ww = ww;
    clear u sigma ww u_new sigma_new ww_new h;
end

%% Part A: Classification and Error Analysis
error_rates_A = zeros(num_runs^2, length(test_dimensions));

% Test all possible FG-BG model pairs
pair_idx = 1;
for fg_model = 1:num_runs
    for bg_model = 1:num_runs
        fprintf('Part A - Testing model pair %d/%d\n', pair_idx, num_runs^2);
        
        for d_idx = 1:length(test_dimensions)
            d = test_dimensions(d_idx);
            num_errors = 0;
            total_pixels = 0;
            
            % Process image
            for i = 1:m-7
                for j = 1:n-7
                    % Extract and transform patch
                    patch = cheetah(i:i+7, j:j+7);
                    patch_dct = dct2(patch);
                    x = zeros(64, 1);
                    for p = 1:8
                        for q = 1:8
                            x(zig_zag(p, q)) = patch_dct(p, q);
                        end
                    end
                    x = x(1:d);
                    
                    % Compute likelihoods
                    prob_fg = 0;
                    prob_bg = 0;
                    
                    % FG probability
                    for c = 1:C
                        prob_fg = prob_fg + models_A(fg_model).FG.ww(c) * ...
                            mvnpdf(x', models_A(fg_model).FG.u(1:d, c)', ...
                            models_A(fg_model).FG.sigma(1:d, 1:d, c));
                    end
                    
                    % BG probability
                    for c = 1:C
                        prob_bg = prob_bg + models_A(bg_model).BG.ww(c) * ...
                            mvnpdf(x', models_A(bg_model).BG.u(1:d, c)', ...
                            models_A(bg_model).BG.sigma(1:d, 1:d, c));
                    end
                    
                    % Classification
                    if log(prob_fg) + log(PY_FG) > log(prob_bg) + log(PY_BG)
                        classification = 1;
                    else
                        classification = 0;
                    end
                    
                    % Count errors
                    if classification ~= groundtruth(i, j)
                        num_errors = num_errors + 1;
                    end
                    total_pixels = total_pixels + 1;
                end
            end
            
            % Store error rate
            error_rates_A(pair_idx, d_idx) = num_errors / total_pixels;
        end
        pair_idx = pair_idx + 1;
    end
end

%% Part B: Different Numbers of Components
C_values = [1, 2, 4, 8, 16, 32];
models_B = struct('FG', cell(1, length(C_values)), 'BG', cell(1, length(C_values)));
error_rates_B = zeros(length(C_values), length(test_dimensions));

% Train models with different numbers of components
for c_idx = 1:length(C_values)
    C = C_values(c_idx);
    fprintf('Part B - Training models with C = %d\n', C);
    
    %% Train FG Model
    % Initialize parameters
    weights = abs(randn(1, C));
    weights_sum = sum(weights);
    
    % Initialize mixture parameters
    for c = 1:C
        random_index = randi([1, size(trainFG, 1)]);
        u(:, c) = trainFG(random_index, :)';
        d_temp = 0.5 + 0.5 * rand(num_dimensions, 1);
        sigma(:, :, c) = diag(d_temp);
        ww(c) = weights(c) / weights_sum;
    end
    
    % EM Algorithm (same as Part A)
    n = 1;
    err_estimation = 2;
    
    while (err_estimation > err_convergence && n <= max_iterations)
        % [Same EM code as in Part A]
        if mod(n, 10) == 0
            fprintf('FG Iteration %d, Error: %f\n', n, err_estimation);
        end
        
        % E Step
        for i = 1:size(trainFG, 1)
            x_i = trainFG(i, :)';
            denom = 0;
            
            for iter1 = 1:C
                denom_temp = mvnpdf(x_i, u(:, iter1), sigma(:, :, iter1));
                denom = denom + (denom_temp * ww(iter1));
            end
            
            for j = 1:C
                h_temp = mvnpdf(x_i, u(:, j), sigma(:, :, j));
                h(i, j) = (h_temp * ww(j)) / max(denom, 1e-10);
                h(i, j) = max(h(i, j), 1e-10);
            end
        end
        
        % M Step
        for j = 1:C
            numerator1 = h(:, j) .* trainFG;
            denom2 = sum(h(:, j));
            u_new(:, j) = sum(numerator1, 1)' / denom2;
            
            ww_new(j) = mean(h(:, j));
            ww_new(j) = max(ww_new(j), 1e-10);
            
            diff_matrix = trainFG' - u(:, j);
            sigma_temp = (diff_matrix * diag(h(:, j)) * diff_matrix') / denom2;
            diag_terms = max(diag(sigma_temp), 1e-6);
            sigma_new(:, :, j) = diag(diag_terms);
        end
        
        ww_new = ww_new / sum(ww_new);
        
        err_estimation = norm(u_new - u, 'fro') / norm(u, 'fro');
        u = u_new;
        ww = ww_new;
        sigma = sigma_new;
        n = n + 1;
    end
    
    % Store FG model
    models_B(c_idx).FG.u = u;
    models_B(c_idx).FG.sigma = sigma;
    models_B(c_idx).FG.ww = ww;
    clear u sigma ww u_new sigma_new ww_new h;
    
    %% Train BG Model
    % Initialize parameters
    weights = abs(randn(1, C));
    weights_sum = sum(weights);
    
    % Initialize mixture parameters for BG
    for c = 1:C
        random_index = randi([1, size(trainBG, 1)]);
        u(:, c) = trainBG(random_index, :)';
        d_temp = 0.5 + 0.5 * rand(num_dimensions, 1);
        sigma(:, :, c) = diag(d_temp);
        ww(c) = weights(c) / weights_sum;
    end
    
    % EM Algorithm for BG
    n = 1;
    err_estimation = 2;
    
    while (err_estimation > err_convergence && n <= max_iterations)
        if mod(n, 10) == 0
            fprintf('BG Iteration %d, Error: %f\n', n, err_estimation);
        end
        
        % E Step
        for i = 1:size(trainBG, 1)
            x_i = trainBG(i, :)';
            denom = 0;
            
            for iter1 = 1:C
                denom_temp = mvnpdf(x_i, u(:, iter1), sigma(:, :, iter1));
                denom = denom + (denom_temp * ww(iter1));
            end
            
            for j = 1:C
                h_temp = mvnpdf(x_i, u(:, j), sigma(:, :, j));
                h(i, j) = (h_temp * ww(j)) / max(denom, 1e-10);
                h(i, j) = max(h(i, j), 1e-10);
            end
        end
        
        % M Step
        for j = 1:C
            numerator1 = h(:, j) .* trainBG;
            denom2 = sum(h(:, j));
            u_new(:, j) = sum(numerator1, 1)' / denom2;
            
            ww_new(j) = mean(h(:, j));
            ww_new(j) = max(ww_new(j), 1e-10);
            
            diff_matrix = trainBG' - u(:, j);
            sigma_temp = (diff_matrix * diag(h(:, j)) * diff_matrix') / denom2;
            diag_terms = max(diag(sigma_temp), 1e-6);
            sigma_new(:, :, j) = diag(diag_terms);
        end
        
        ww_new = ww_new / sum(ww_new);
        
        err_estimation = norm(u_new - u, 'fro') / norm(u, 'fro');
        u = u_new;
        ww = ww_new;
        sigma = sigma_new;
        n = n + 1;
    end
    
    % Store BG model
    models_B(c_idx).BG.u = u;
    models_B(c_idx).BG.sigma = sigma;
    models_B(c_idx).BG.ww = ww;
    clear u sigma ww u_new sigma_new ww_new h;

end  % End of C_values loop

%% Testing for Part B
% Test classification performance for each C value
for c_idx = 1:length(C_values)
    C = C_values(c_idx);
    fprintf('Part B - Testing models with C = %d\n', C);
    
    for d_idx = 1:length(test_dimensions)
        d = test_dimensions(d_idx);
        num_errors = 0;
        total_pixels = 0;
        
        % Process image
        for i = 1:m-7
            for j = 1:n-7
                % Extract and transform patch
                patch = cheetah(i:i+7, j:j+7);
                patch_dct = dct2(patch);
                x = zeros(64, 1);
                for p = 1:8
                    for q = 1:8
                        x(zig_zag(p, q)) = patch_dct(p, q);
                    end
                end
                x = x(1:d);
                
                % Compute likelihoods
                prob_fg = 0;
                prob_bg = 0;
                
                % FG probability
                for c = 1:C
                    prob_fg = prob_fg + models_B(c_idx).FG.ww(c) * ...
                        mvnpdf(x', models_B(c_idx).FG.u(1:d, c)', ...
                        models_B(c_idx).FG.sigma(1:d, 1:d, c));
                end
                
                % BG probability
                for c = 1:C
                    prob_bg = prob_bg + models_B(c_idx).BG.ww(c) * ...
                        mvnpdf(x', models_B(c_idx).BG.u(1:d, c)', ...
                        models_B(c_idx).BG.sigma(1:d, 1:d, c));
                end
                
                % Classification
                if log(prob_fg) + log(PY_FG) > log(prob_bg) + log(PY_BG)
                    classification = 1;
                else
                    classification = 0;
                end
                
                % Count errors
                if classification ~= groundtruth(i, j)
                    num_errors = num_errors + 1;
                end
                total_pixels = total_pixels + 1;
            end
        end
        
        % Store error rate
        error_rates_B(c_idx, d_idx) = num_errors / total_pixels;
    end
end

%% Create Plots
% Part A: Plot all 25 classifier pairs
figure;
hold on;
colormap(jet(25));
colors = colormap;

for i = 1:num_runs^2
    plot(test_dimensions, error_rates_A(i, :), '-o', 'LineWidth', 1.5, 'Color', colors(i,:));
end

xlabel('Number of Dimensions');
ylabel('Probability of Error');
title('Part A: Initialization Effect (C=8)');
grid on;

% Create legend with FG-BG pair numbers
legend_str = cell(num_runs^2, 1);
for i = 1:num_runs^2
    fg_idx = ceil(i/num_runs);
    bg_idx = mod(i-1, num_runs) + 1;
    legend_str{i} = sprintf('FG%d-BG%d', fg_idx, bg_idx);
end
legend(legend_str, 'Location', 'eastoutside');

% Part B: Plot different numbers of components
figure;
hold on;
colors = lines(length(C_values));

for i = 1:length(C_values)
    plot(test_dimensions, error_rates_B(i, :), '-o', 'LineWidth', 2, 'Color', colors(i,:));
end

xlabel('Number of Dimensions');
ylabel('Probability of Error');
title('Part B: Effect of Number of Components');
grid on;

legend_str = arrayfun(@(x) sprintf('C = %d', x), C_values, 'UniformOutput', false);
legend(legend_str, 'Location', 'best');

% Save all results
save('em_classification_results.mat', 'models_A', 'models_B', 'error_rates_A', ...
    'error_rates_B', 'test_dimensions', 'C_values');

fprintf('\nAnalysis complete:\n');
fprintf('1. Part A: Tested 5 initializations (C=8) with 25 classifier pairs\n');
fprintf('2. Part B: Tested C values: {1,2,4,8,16,32}\n');
fprintf('3. Dimensions tested: {1,2,4,8,16,24,32,64}\n');
fprintf('4. Results and figures saved\n');