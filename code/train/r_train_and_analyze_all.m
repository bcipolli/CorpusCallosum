function [nets, pats, datas, figs] = r_train_and_analyze_all(template_net, nexamples, ...
                                                             nccs, delays, Ts, ...
                                                             loop_figs, summary_figs, ...
                                                             results_dir, figures_output_dir, figures_output_extensions)
%

    %% Initialize environment and directories.
    if ~exist('nexamples', 'var'), nexamples = 10; end;
    if ~exist('nccs', 'var'), nccs = [template_net.sets.ncc]; end;
    if ~exist('delays', 'var'), delays = unique(template_net.sets.D_CC_INIT); end;
    if ~exist('Ts', 'var'), Ts = unique(template_net.sets.T_INIT) / template_net.sets.dt; end;
    if ~exist('loop_figs', 'var'), loop_figs = []; end;
    if ~exist('summary_figs', 'var'), summary_figs = [0 1 2]; end;
    if ~exist('results_dir', 'var'), results_dir = fullfile(guru_getOutPath('plot'), 'current'); end;
    if ~exist('figures_output_extensions', 'var'), figures_output_extensions = {'png'}; end;
    if ~exist('figures_output_dir', 'var'),
        abc = dbstack;
        script_name = abc(end).name;
        figures_output_dir = fullfile(results_dir, script_name);
    end;

    if ~exist(results_dir, 'dir'), mkdir(results_dir); end;
    if ~exist(figures_output_dir, 'dir'), mkdir(figures_output_dir); end;


    %% Train in parallel, gather data sequentially
    parfor mi=1:nexamples, for ni = 1:length(nccs), for di=1:length(delays), for ti=1:length(Ts)
        % Train the network
        net = set_net_params(template_net, nccs(ni), delays(di), Ts(ti), mi);
        r_train_many(net, 1);

        %% Gather any missing data
        %if ~isfield(data, 'an') || ~isfield(data.an, 'sim') || size(data.an.simstats, 4) ~= 9
        %    [net, data] = r_mark_missing_data(net, pats, data);
        %end;
    end; end; end; end;

    % Collect the data
    nets = cell(length(nccs), length(delays), length(Ts));
    datas = cell(size(nets));
    sims = cell(size(nets));
    simstats = cell(size(nets));
    niters = cell(size(nets));

    for ni = 1:length(nccs), for di=1:length(delays), for ti=1:length(Ts)
        net = set_net_params(template_net, nccs(ni), delays(di), Ts(ti));
        [nets{ni, di, ti}, pats, datas{ni, di, ti}] = r_train_many(net, nexamples);
    end; end; end;


    %% Analyze the networks and massage the results
    for ci=1:numel(nets)
        % Combine the results
        [sims{ci}, simstats{ci}, niters{ci}, idx] = r_group_analyze(nets{ci}{1}.sets, datas{ci});

        % Filter the results to only good results
        nets{ci} = nets{ci}(idx.built);
        datas{ci} = datas{ci}(idx.built);

        % Report some results
        r_plot_similarity(nets{ci}, sims{ci}, simstats{ci}, loop_figs);
    end;

    % Plot some summary figures
    r_plot_niters(nets, sims, niters, nexamples, summary_figs);
    %r_plot_interhemispheric_surfaces(nets, datas, summary_figs);
    r_plot_similarity_surfaces(nets, sims, simstats, summary_figs);

    guru_saveall_figures( ...
        figures_output_dir, ...
        figures_output_extensions, ...
        false, ...  % don''t overwrite
        true);      % close figures after save


function net = set_net_params(template_net, ncc, delay, T, mi)
    % set params
    net = template_net;
    net.sets.ncc = ncc;
    net.sets.D_CC_INIT(:) = delay;
    net.sets.T_INIT(:) = T * net.sets.dt;
    net.sets.T_LIM(:) = T * net.sets.dt;
    net.sets = guru_rmfield(net.sets, {'D_LIM', 'matfile'});
    %net.sets.debug = false;

    if exist('mi', 'var')
        net.sets.rseed = template_net.sets.rseed + (mi-1);
    end;


function [sims, simstats, idx] = r_group_analyze(sets, datas)
% built: was built (?)
% trained: finished training without errors.
% good: built & trained.

    idx.built   = cellfun(@(d) ~isfield(d, 'ex') && isfield(d, 'actcurve'), datas);
    idx.trained = cellfun(@(d) isfield(d, 'good_update') && (length(d.good_update) < sets.niters || nnz(~d.good_update) == 0), datas);
    idx.good    = idx.built & idx.trained;

    anz          = cellfun(@(d) d.an, datas(idx.good), 'UniformOutput', false);
    sims         = cellfun(@(an) an.sim, anz, 'UniformOutput', false);
    simstats_tmp = cellfun(@(an) an.simstats, anz, 'UniformOutput', false);
    simstats     = mean(cat(5, simstats_tmp{:}), 5);


function r_plot_niters(nets, sims, niters, nexamples)
    dims = {'delays', 'ncc', 'Ts'};
    dims_verbose = {'Delay', '# Connections', 'Time Constant'};

    vals = r_compute_common_vals(nets, sims);
    guru_assert(~isempty(vals), 'SOME simulations should be good!');

    dim_idx = cellfun( @(dim) length(unique(vals.(dim))) > 1, dims);
    ndims_varied = sum(dim_idx);
    guru_assert(ndims_varied > 0, 'SOME simulations should remain!');
    guru_assert(ndims_varied <= 2, 'Can''t handle more than 2 dims currently!');

    pct_completed_models = cellfun(@(n) 100*length(n) / nexamples, niters);
    guru_assert(pct_completed_models > 0, 'SOME simulations should be OK!');

    % Number of iterations
    figure;
    switch ndims_varied % # non-singular values (i.e. was iterated)
        case 1
            dim = dims{dim_idx};
            errorbar(vals.(dim), cellfun(@(n) nanmean(n), niters), cellfun(@(n) nanstd(n), niters));
            xlabel(dims{dim_idx}); ylabel('# iterations');
        case 2
            surf(vals.(dims{1}), vals.(dims{2}), cellfun(@(n) nanmean(n), niters));
            xlabel(dims_verbose{1}); ylabel(dims_verbose{2}); zlabel('% models');

        otherwise, error('NYI');
    end;
    set(gca, 'FontSize', 16);
    title('# iterations.');
    set(gcf, 'name', 'niters');

    % Number of trained models
    figure;
    switch ndims_varied % # non-singular values (i.e. was iterated)
        case 1
            dim = dims{dim_idx};
            bar(vals.(dim), pct_completed_models);
            xlabel(dim); ylabel('% models');
            set(gca, 'ylim', [0 100]);
        case 2
            surf(vals.(dims{1}), vals.(dims{2}), pct_completed_models);
            xlabel(dims_verbose{1}); ylabel(dims_verbose{2}); zlabel('% models');
            set(gca, 'zlim', [0 100]);

        otherwise, error('NYI');
    end;
    set(gca, 'FontSize', 16);
    title('% models trained.');
    set(gcf, 'name', 'ntrained');



function r_report_training(nets, niters)
    fprintf('Training iters (%2d del, %2d ncc): %.1f +/- %.1f\n', max(nets{1}.sets.D_CC_INIT(:)),nets{1}.sets.ncc, nanmean(niters), nanstd(niters));


function [net, data] = r_mark_missing_data(net, pats, data)
    guru_assert(isfield(data, 'actcurve'), 'actcurve not in data!');

    % Will propagate data to cell array.
    fprintf('Computing similarity...')
    [data.an.sim, data.an.simstats] = r_compute_similarity(net, pats);

    % Hack to make things work A LOT FASTER
    outfile = fullfile(net.sets.dirname, net.sets.matfile);
    fprintf(' re-saving to %s ...', outfile);
    save(outfile, 'net', 'pats', 'data');
    fprintf(' done.\n');

