function rules = extract_rules(filePath)
    % Extract rule-like statements from a given MATLAB file
    fid = fopen(filePath, 'r');
    rules = {};
    while ~feof(fid)
        line = fgetl(fid);
        if contains(line, 'if') || contains(line, 'rule')
            rules{end+1} = line; %#ok<AGROW>
        end
    end
    fclose(fid);
end
