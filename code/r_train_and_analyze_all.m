function [nets, pats, datas, figs] = r_train_and_analyze_all(template_net, nexamples, nccs, delays, Ts, loop_figs, summary_figs, results_dir)
%

    if ~exist('nexamples', 'var'), nexamples = 10; end;
    if ~exist('nccs', 'var'), nccs = [template_net.sets.ncc]; end;
    if ~exist('delays', 'var'), delays = unique(template_net.sets.D_CC_INIT); end;
    if ~exist('Ts', 'var'), Ts = unique(template_net.sets.T_INIT) / template_net.sets.dt; end;
    if ~exist('loop_figs', 'var'), loop_figs = []; end;
    if ~exist('summary_figs', 'var'), summary_figs = [1 2]; end;
    if ~exist('results_dir', 'var'), results_dir = fullfile(r_out_path('plot'), 'current'); end;
    if ~exist(results_dir, 'dir'), mkdir(results_dir); end;

    nets = cell(length(nccs), length(delays), length(Ts));
    datas = cell(size(nets));
    sims = cell(size(nets));
    simstats = cell(size(nets));
    niters = cell(size(nets));

    rseed = template_net.sets.rseed;

    for mi=1:nexamples, for ni = 1:length(nccs), for di=1:length(delays), for ti=1:length(Ts)
        if mi==1
            nets{ni, di, ti} = cell(nexamples, 1);
            datas{ni, di, ti} = cell(nexamples, 1);
        end;

        % set params
        net = template_net;
        net.sets.ncc = nccs(ni);
        net.sets.D_CC_INIT(:) = delays(di);
        net.sets.T_INIT(:) = Ts(ti) * net.sets.dt;
        net.sets.T_LIM(:) = Ts(ti) * net.sets.dt;
        net.sets.rseed = rseed + (mi-1);
        net.sets = guru_rmfield(net.sets, {'D_LIM', 'matfile'});
        %net.sets.debug = false;

        % Train the network
        [nets{ni, di, ti}{mi}, pats, datas{ni, di, ti}{mi}] = r_train_many(net, 1);
        nets{ni, di, ti}{mi} = nets{ni, di, ti}{mi}{1};
        datas{ni, di, ti}{mi} = datas{ni, di, ti}{mi}{1};

        % Gather any missing data
        if false || ~isfield(datas{ni, di, ti}{mi}, 'an') || ~isfield(datas{ni, di, ti}{mi}.an, 'sim') || size(datas{ni, di, ti}{mi}.an.simstats, 4) ~= 9
            net = nets{ni, di, ti}{mi};
            data = datas{ni, di, ti}{mi};

            guru_assert(isfield(data, 'actcurve'), 'actcurve not in data!');

            % Will propagate data to cell array.
            fprintf('Computing similarity...')
            [data.an.sim, data.an.simstats] = r_compute_similarity(net, pats);
            datas{ni, di, ti}{mi} = data;

            % Hack to make things work A LOT FASTER
            outfile = fullfile(net.sets.dirname, net.sets.matfile);
            fprintf(' re-saving to %s ...', outfile);
            save(outfile,'net','pats','data');
            fprintf(' done.\n');
        end;

        if mi==nexamples
            % Combine the results
            [sims{ni, di, ti}, simstats{ni, di, ti}, niters{ni, di, ti}, built_idx] = r_analyze(nets{ni, di, ti}{1}.sets, datas{ni, di, ti});

            % Filter the results to only good results
            nets{ni, di, ti} = nets{ni, di, ti}(built_idx);
            datas{ni, di, ti} = datas{ni, di, ti}(built_idx);

            % Report some results
            r_plot_similarity(nets{ni, di, ti}, sims{ni, di, ti}, simstats{ni, di, ti}, loop_figs);

        end;
    end; end; end; end;

    if ~isempty(summary_figs)
        r_plot_niters(nets, sims, niters, nexamples);
    end;
    r_plot_similarity_surfaces(nets, sims, simstats, summary_figs);

    abc = dbstack;
    script_name = abc(end).name;
    guru_saveall_figures(fullfile(results_dir, script_name), {'png'}, false, true);


function [sims, simstats, niters, built_idx, trained_idx] = r_analyze(sets, datas)
    built_idx     = cellfun(@(d) ~isfield(d, 'ex') && isfield(d, 'actcurve'), datas);
    trained_idx  = cellfun(@(d) isfield(d, 'good_update') && (length(d.good_update) < sets.niters || nnz(~d.good_update) == 0), datas);
    good_idx = built_idx & trained_idx;

    anz          = cellfun(@(d) d.an, datas(good_idx), 'UniformOutput', false);
    sims         = cellfun(@(an) an.sim, anz, 'UniformOutput', false);
    simstats_tmp = cellfun(@(an) an.simstats, anz, 'UniformOutput', false);
    simstats     = mean(cat(5, simstats_tmp{:}), 5);

    niters       = cellfun(@(d) guru_getfield(d, 'niters', NaN), datas(good_idx));


function r_report_training(nets, niters)
    fprintf('Training iters (%2d del, %2d ncc): %.1f +/- %.1f\n', max(nets{1}.sets.D_CC_INIT(:)),nets{1}.sets.ncc, nanmean(niters), nanstd(niters));


function r_plot_niters(nets, sims, niters, nexamples)
    vals = r_compute_common_vals(nets, sims);
    if isempty(vals), return; end;

    dims = {'delays', 'ncc'};
    dim_idx = cellfun( @(dim) length(vals.(dim)) > 1, dims);%, []), , 'UniformOutput', false );

    pct_completed_models = cellfun(@(n) 100*length(n) / nexamples, niters);

    if all(pct_completed_models == 100.)
        return;
    elseif all(pct_completed_models == 0)
        fprintf('?');
        keyboard;
    end;

    % Number of iterations
    switch sum(dim_idx) % # non-singular values (i.e. was iterated)
        case 1
            dim = dims{dim_idx};
            figure;
            errorbar(vals.(dim), cellfun(@(n) nanmean(n), niters), cellfun(@(n) nanstd(n), niters));
            xlabel(dim); ylabel('# iterations');
        case 2
            figure;
            surf(vals.delays, vals.ncc, cellfun(@(n) nanmean(n), niters));

        case 0, ;
        otherwise, error('NYI');
    end;
    title('# iterations.');

    % Number of trained models
    switch sum(dim_idx) % # non-singular values (i.e. was iterated)
        case 1
            dim = dims{dim_idx};
            figure;
            bar(vals.(dim), pct_completed_models);
            xlabel(dim); ylabel('% models');
            set(gca, 'ylim', [0 100]);
        case 2
            figure;
            surf(vals.delays, vals.ncc, pct_completed_models);

        case 0, ;
        otherwise, error('NYI');
    end;
    title('# models trained.');

