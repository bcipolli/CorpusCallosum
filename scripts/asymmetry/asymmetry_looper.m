function [nets, pats, datas, figs] = asymmetry_looper(net, nexamples, nccs, delays, Ts, loop_figs, summary_figs)

    if ~exist('nexamples', 'var'), nexamples = 10; end;
    if ~exist('nccs', 'var'), nccs = [net.sets.ncc]; end;
    if ~exist('delays', 'var'), delays = unique(net.sets.D_CC_INIT); end;
    if ~exist('Ts', 'var'), Ts = unique(net.sets.T_INIT) / net.sets.dt; end;
    if ~exist('loop_figs', 'var'), loop_figs = []; end;
    if ~exist('summary_figs', 'var'), summary_figs = [1 2]; end;
    

    nets = cell(length(nccs), length(delays), length(Ts)); 
    datas = cell(size(nets));
    sims = cell(size(nets));
    simstats = cell(size(nets));

    rseed = net.sets.rseed;
    
    for mi=1:nexamples, for ni = 1:length(nccs), for di=1:length(delays), for ti=1:length(Ts)
        if mi==1
            nets{ni, di, ti} = cell(nexamples, 1);
            datas{ni, di, ti} = cell(nexamples, 1);
        end;

        % set params
        net.sets.ncc = nccs(ni);
        net.sets.D_CC_INIT(:) = delays(di);
        net.sets.T_INIT(:) = Ts(ti) * net.sets.dt;
        net.sets.T_LIM(:) = Ts(ti) * net.sets.dt;
        net.sets.rseed = net.sets.rseed + (mi-1);
        
        % Train the network
        [nets{ni, di, ti}{mi}, pats, datas{ni, di, ti}{mi}] = r_looper(net, 1); % run 25 network instances

        % Gather any missing data
        if mi==nexamples
            for xi=1:length(datas{ni, di, ti})
                if ~isfield(datas{ni, di, ti}{xi}, 'an') || ~isfield(datas{ni, di, ti}{xi}.an, 'sim')
                    net = nets{ni, di, ti}{xi};
                    data = datas{ni, di, ti}{xi};

                    % Will propagate data to cell array.
                    fprintf('Computing similarity...')
                    [data.an.sim, data.an.simstats] = r_compute_similarity(net, pats);
                    datas{ni, di, ti}{xi} = data;

                    % Hack to make things work A LOT FASTER
                    outfile = fullfile(net.sets.dirname, net.sets.matfile);
                    fprintf(' re-saving to %s ...', outfile);
                    save(outfile,'net','pats','data');
                    fprintf(' done.\n');
                end;
            end;

            % Combine the results
            %anz      = cellfun(@(obj) guru_getfield(obj, 'an', struct()), datas{ni, di, ti}, 'UniformOutput', false);
            anz                  = cellfun(@(d) d.an, datas{ni, di, ti}, 'UniformOutput', false);
            sims{ni, di, ti}     = cellfun(@(an) an.sim, anz, 'UniformOutput', false);
            simstats{ni, di, ti} = cellfun(@(an) an.simstats, anz, 'UniformOutput', false);
            simstats{ni, di, ti} = mean(cat(5, simstats{ni, di, ti}{:}), 5);
            clear('anz');

            % Plot results
            if ~isempty(loop_figs)
                r_analyze_similarity(nets{ni, di, ti}, sims{ni, di, ti}, simstats{ni, di, ti}, loop_figs);
            end;
        end;
    end; end; end; end;

    if ~isempty(summary_figs)
        r_analyze_similarity_surfaces(nets, sims, simstats, summary_figs);
    end;