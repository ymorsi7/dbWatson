% Load data
data = load('data/sample_data.mat'); % Adjust to your dataset

% Apply new rules
threshold = 0.2; % Adjust threshold as needed
flaggedData = check_null_values(data, threshold);

% Plot filtered data
x = 1:size(data, 1); % Example x-axis
y = data(:, 1); % Example y-axis
plot(x(~flaggedData), y(~flaggedData)); % Plot only non-flagged data
title('Filtered Plot with Improved Rules');
xlabel('X-Axis');
ylabel('Y-Axis');
saveas(gcf, 'results/improved_plot.png');
