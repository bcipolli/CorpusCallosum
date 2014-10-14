function [net,pats,data, ex] = r_main(net,pats,data,handle_exception)
%
    if ~exist('pats', 'var'), pats = []; end;
    if ~exist('data', 'var'), data = []; end;
    if ~exist('handle_exception', 'var'), handle_exception=false; end;

    ex = [];  % exception is empty

    try
        % Validate & set defaults
        [net] = r_massage_params(net);
        rand('seed',net.sets.rseed);

        % Create patterns for the given training paradigm
        if (isempty(pats))
            pats = r_pats(net);
        end;

        % If the network doesn't exist, then start net from scratch
        if (~isfield(net, 'w'))
            [net] = net.fn.init(net, pats);
        end;

        % Train the network
        fprintf('Training [autoencoder=%d] network with tsteps=%d, max_del=%d, ncc=%d, to tc=%4.2f\n', ...
                 (isfield(net.sets, 'autoencoder') && net.sets.autoencoder), ...
                 net.sets.tsteps, max(net.sets.D_CC_INIT(:)), net.sets.ncc, net.sets.train_criterion);

        if isempty(data)
          [net,data] = net.fn.train(net,pats.train);
        else
          [net,data] = net.fn.train(net,pats.train,data);
        end;


        % analyze
        [data]     = r_test(net,pats,data); %regular test
    %    [data.an]  = r_analyze(net, pats, data);

        % Save result
        if ~exist(net.sets.dirname), mkdir(net.sets.dirname); end;
        outfile = fullfile(net.sets.dirname, net.sets.matfile);
        fprintf('Saving to %s ...', outfile);
        save(outfile,'net','pats','data');
        fprintf(' done.\n');


    catch ex
        if ~handle_exception, rethrow(ex);
        else, return; end;
    end;

