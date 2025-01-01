function seasonality = detect_seasonality(data)
    % Simple seasonality detection using autocorrelation
    seasonality = zeros(1, size(data, 2));
    
    for i = 1:size(data, 2)
        [acf, ~] = xcorr(data(:,i) - mean(data(:,i)), 'coeff');
        acf = acf(length(data(:,i)):end);
        [~, locs] = findpeaks(acf);
        if ~isempty(locs)
            seasonality(i) = locs(1); % Return first peak as seasonality period
        end
    end
end 