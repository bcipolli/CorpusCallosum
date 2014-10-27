function [nets, pats, datas] = r_looper(net, n_nets)
%function r_looper(net, n_nets)
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
        [nets{ii}, pats, datas{ii}] = r_dummy(sets, si);
    end;


function [net, pats, data] = r_dummy(sets, rseed)

   % Make sure not to reuse networks!
   net.sets = sets;
   net.sets.rseed = rseed;

    %
    net = r_massage_params(net);
    matfile = fullfile(net.sets.dirname, net.sets.matfile);
    if exist(matfile, 'file')
        fprintf('Skipping %s...', matfile);
        load(matfile);
        if false && (~isfield(data, 'an') || ~isfield(data.an, 'sim'))
            guru_assert(false, 'an and an.sim were not in data.  WHY?');
            [data.an] = r_analyze(net, pats, data);
            save(matfile, 'net', 'pats', 'data');
        end;
        if true || isfield(data, 'actcurve')
            fprintf('\n');
            return;
        end;
        fprintf(' or not; no actcurve!  Retraining...\n');
    end;

    %
    if ~exist(net.sets.dirname,'dir'), mkdir(net.sets.dirname); end;
    [net,pats,data,ex]          = r_main(net, [], [], guru_getfield(net.sets, 'debug', true));  % handle exception
    if isempty(ex)
        [data.an]                = r_analyze(net, pats, data);
        %unix(['mv ' net.sets.matfile ' ./' net.sets.dirname]);
    else
        data.ex = ex;
        fprintf('Error: %s\nCall stack:\n', ex.message);
        fprintf('\t%s\n', ex.stack.file);
    end;

    guru_assert(isfield(data, 'actcurve') || isfield(data, 'ex') , 'actcurve not in data!');
