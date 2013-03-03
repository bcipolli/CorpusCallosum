function [data,ts] = get_cache_data(dirnames, cache_file)
%
    global g_data_cache g_dir_cache;
    
    if ~exist('guru_file_parts','file'), addpath(genpath('code')); end;
    if ~exist('cache_file','var'), 
        cache_file='cache_file.mat'; 
        force_load = false;
    else
        force_load = isempty(cache_file);
    end;
    if ~strcmp('.mat', guru_fileparts(cache_file, 'ext'))
        cache_file = [cache_file '.mat'];
    end;
    
    % first time, didn't exist
    if exist(cache_file,'file')
      %tmp = load(cache_file);
      %g_data_cache = tmp.g_data_cache;
      load(cache_file);
    elseif isnumeric(g_dir_cache), 

      g_dir_cache={}; 
      g_data_cache={}; 
    end;
    
    if ischar(dirnames), dirnames = {dirnames}; end;

    % Purge old dataset from cache
    if force_load
        [~,idx] = ismember(dirnames, g_dir_cache);
        goodidx = setdiff(1:length(g_dir_cache),idx);
        g_data_cache = g_data_cache(goodidx);
        g_dir_cache  = g_dir_cache(goodidx);
    end;

    % Add missing dataset(s) to (giant) cache
    for di=1:length(dirnames)
      dn = dirnames{di};
      if ~exist(dn), dn = fullfile('data', dirnames{di}); end;
      if ~exist(dn), dn = fullfile('runs', dirnames{di}); end;
      
        if ~ismember(dirnames{di}, g_dir_cache)
            g_data_cache{end+1} = collect_data(dn);
            g_dir_cache{end+1}  = dirnames{di}; 
        end;
    end;

    % Select the current datasets
    [~,idx] = ismember(dirnames, g_dir_cache);

    data = g_data_cache(idx);
    ts = g_data_cache{idx(1)}.ts;
