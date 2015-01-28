function [net, pats, data] = r_train_one(net, pats, data, save_data)
%
    if ~exist('pats', 'var'), pats = []; end;
    if ~exist('data', 'var'), data = []; end;
    if ~exist('save_data', 'var'), save_data = false; end;

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
    fprintf('Training [autoencoder=%d] network with seed=%d, tsteps=%d, max_del=%d, ncc=%d, T=%.1f to tc=%4.2f\n', ...
            (isfield(net.sets, 'autoencoder') && net.sets.autoencoder), ...
            net.sets.rseed, ...
            net.sets.tsteps, max(net.sets.D_CC_INIT(:)), net.sets.ncc, ...
            max(net.sets.T_INIT(:)), net.sets.train_criterion);

    if isempty(data)
      [net,data] = net.fn.train(net,pats.train);
    else
      [net,data] = net.fn.train(net,pats.train,data);
    end;


    % analyze
    [data]     = r_test(net,pats,data); %regular test

    % Save result
    if save_data
        if ~exist(net.sets.dirname), mkdir(net.sets.dirname); end;
        outfile = fullfile(net.sets.dirname, net.sets.matfile);
        fprintf('Saving to %s ...', outfile);
        save(outfile,'net','pats','data');
        fprintf(' done.\n');
    end;
