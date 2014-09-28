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
        fprintf('Skipping %s\n', matfile);
        load(matfile);
        if false && (~isfield(data, 'an') || ~isfield(data.an, 'sim'))
keyboard
            [data.an] = r_analyze(net, pats, data);
            save(matfile, 'net', 'pats', 'data');
        end;
        return;
    end; % don't re-run

    %
    if ~exist(net.sets.dirname,'dir'), mkdir(net.sets.dirname); end;

    %try
     [net,pats,data]          = r_main(net);
     [data.an]                = r_analyze(net, pats, data);
     %unix(['mv ' net.sets.matfile ' ./' net.sets.dirname]);
   %catch err
   %  fprintf('Error: %s\nCall stack:\n', err.message);
   %  fprintf('\t%s\n', err.stack.file)
   %end;
