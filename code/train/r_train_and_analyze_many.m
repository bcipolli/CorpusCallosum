function [nets, pats, datas] = r_train_and_analyze_many(net, n_nets)
%function r_train_many(net, n_nets)
%
% Loops over some # of networks to execute them.


    % Select # of networks to run
    if ~exist('n_nets','var')
      if isfield(net.sets,'n_nets'), n_nets = net.sets.n_nets;
      else                           n_nets = 10;
      end;
    end;

    % Get random seed, save default network settings
    min_rseed = net.sets.rseed;
    sets = net.sets;

    nets = cell(n_nets, 1);
    datas = cell(n_nets, 1);
    for si=(min_rseed-1+[1:n_nets])
        ii = si - min_rseed + 1;
        [nets{ii}, pats, datas{ii}] = r_train_and_analyze_one(sets, si);
    end;


function [net, pats, data] = r_train_and_analyze_one(sets, rseed, save_data)

    if ~exist('save_data', 'var'), save_data = true; end;
    changed = false;


    %% Make sure not to reuse networks!
    net.sets = sets;
    net.sets.rseed = rseed;
    net = r_massage_params(net);
    matfile = fullfile(net.sets.dirname, net.sets.matfile);

    %% Load from cache
    if exist(matfile, 'file')
        fprintf('Loading cached file %s...', matfile);
        load(matfile);
        fprintf(' done.\n');
        
        % Validate what we loaded
        guru_assert(exist('net',  'var'), 'net should be in matfile.');
        guru_assert(exist('pats', 'var'), 'pats should be in matfile.');
        guru_assert(exist('data', 'var'), 'pats should be in matfile.');
        if isfield(data, 'ex') && ~isempty(findstr('time to debug', guru_getfield(data.ex, 'message', [])))
            clear('data');
            fprintf('** RERUNNING inadvertently error-cached scenario.\n');
        end;
        % Fall through, to append any extra analyses
    end;

    %% Train, if needed
    if ~exist('data', 'var')
        changed = true;

        try
            [net, pats, data] = r_train_one(net, [], [], false);  % handle exception
        catch ex
            pats = [];
            data.ex = ex;
            fprintf('Error: %s\nCall stack:\n', ex.message);
            fprintf('\t%s\n', ex.stack.file);
        end;
    end;

    %% Analyze, if possible / needed
    if ~isfield(data, 'ex')
        if ~isfield(data, 'an')  % Always analyze training 
            [data.an] = r_analyze_training(net, pats, data);
            changed = true;
        end;
        if any(~isfield(data, {'sims', 'simstats', 'lagstats'})) % Always analyze similarities
            [data.sims, data.simstats, data.lagstats] = r_analyze_similarity(net, pats, data);
            changed = true;
        end;
        if changed && isfield(net.fn, 'analyze')
            try
                data = net.fn.analyze(net, pats, data);
            catch ex
                keyboard
                if ~strcmp(ex.identifier, 'MATLAB:UndefinedFunction')
                    throw(ex);
                end;
            end;
        end;
    end;

    %% Save the result
    if save_data && changed
        if ~exist(net.sets.dirname), mkdir(net.sets.dirname); end;
        cache_file = fullfile(net.sets.dirname, net.sets.matfile);
        fprintf('Saving to %s ...', cache_file);
        save(cache_file,'net','pats','data');
        fprintf(' done.\n');
    end;

    guru_assert(isfield(data, 'actcurve') || isfield(data, 'ex') , 'actcurve not in data!');
