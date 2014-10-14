function [nets, pats, datas, figs] = asymmetry_looper(template_net, nexamples, nccs, delays, Ts, loop_figs, summary_figs)

    if ~exist('nexamples', 'var'), nexamples = 10; end;
    if ~exist('nccs', 'var'), nccs = [template_net.sets.ncc]; end;
    if ~exist('delays', 'var'), delays = unique(template_net.sets.D_CC_INIT); end;
    if ~exist('Ts', 'var'), Ts = unique(template_net.sets.T_INIT) / template_net.sets.dt; end;
    if ~exist('loop_figs', 'var'), loop_figs = []; end;
    if ~exist('summary_figs', 'var'), summary_figs = [1 2]; end;


    nets = cell(length(nccs), length(delays), length(Ts));
    datas = cell(size(nets));
    sims = cell(size(nets));
    simstats = cell(size(nets));

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
        [nets{ni, di, ti}{mi}, pats, datas{ni, di, ti}{mi}] = r_looper(net, 1); % run 25 network instances
        nets{ni, di, ti}{mi} = nets{ni, di, ti}{mi}{1};
        datas{ni, di, ti}{mi} = datas{ni, di, ti}{mi}{1};

        % Gather any missing data
        if false || ~isfield(datas{ni, di, ti}{mi}, 'an') || ~isfield(datas{ni, di, ti}{mi}.an, 'sim') || size(datas{ni, di, ti}{mi}.an.simstats, 4) ~= 9
            net = nets{ni, di, ti}{mi};
            data = datas{ni, di, ti}{mi};

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
            %anz      = cellfun(@(obj) guru_getfield(obj, 'an', struct()), datas{ni, di, ti}, 'UniformOutput', false);
            anz                  = cellfun(@(d) d.an, datas{ni, di, ti}, 'UniformOutput', false);
            sims{ni, di, ti}     = cellfun(@(an) an.sim, anz, 'UniformOutput', false);
            simstats_tmp = cellfun(@(an) an.simstats, anz, 'UniformOutput', false);
            simstats{ni, di, ti} = mean(cat(5, simstats_tmp{:}), 5);
            clear('anz');

            % Report some results
            r_analyze_training(nets{ni, di, ti}, datas{ni, di, ti});

            % Plot other results
            if ~isempty(loop_figs)
                r_analyze_similarity(nets{ni, di, ti}, sims{ni, di, ti}, simstats{ni, di, ti}, loop_figs);
            end;
        end;
    end; end; end; end;

    if ~isempty(summary_figs)
        r_analyze_similarity_surfaces(nets, sims, simstats, summary_figs);
    end;

    abc = dbstack;
    dir_name = 'results';
    script_name = abc(end).name;
    guru_saveall_figures(fullfile(dir_name, script_name), {'png'}, false, true);


function r_analyze_training(nets, datas)
    niters = cellfun(@(d) guru_getfield(d, 'niters', NaN), datas);
    fprintf('Training iters (%2d del, %2d ncc): %.1f +/- %.1f\n', max(nets{1}.sets.D_CC_INIT(:)),nets{1}.sets.ncc, nanmean(niters), nanstd(niters));
