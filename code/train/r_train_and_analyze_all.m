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
        [sims{ci}, simstats{ci}, idx] = r_group_analyze(nets{ci}{1}.sets, datas{ci});

        % Filter the results to only good results
        nets{ci} = nets{ci}(idx.built);
        datas{ci} = datas{ci}(idx.built);

        % Report some results
        r_plot_similarity(nets{ci}, sims{ci}, simstats{ci}, loop_figs);
    end;

    % compute
    vals = r_compute_common_vals(nets, sims, false);
    if isempty(vals), return; end;

    % Plot some summary figures
    r_plot_training_figures(nets, datas, vals, nexamples, summary_figs);
    r_plot_interhemispheric_surfaces(nets, datas, vals, summary_figs);
    r_plot_similarity_surfaces(nets, vals, simstats, summary_figs);

    guru_saveall_figures( ...
        figures_output_dir, ...
        figures_output_extensions, ...
        false, ...  % don''t overwrite
        true);      % close figures after save


function net = set_net_params(template_net, ncc, delay, T, mi)
    % Helper function to set net parameters; this complains if
    %   done in a parfor loop

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
