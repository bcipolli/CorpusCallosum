function r_analyze_similarity_surfaces(nets, sims, simstats, figs)


    if ~iscell(nets), nets = { nets }; end;
    if ~exist('figs', 'var'), figs = [1:3]; end;

    dims = {'ncc', 'delays', 'Ts'};
    dims_looped = size(nets) > 1;
    ndims_looped = sum(dims_looped);

    switch ndims_looped
        case 1, r_analyze_similarity_surfaces_1D(nets, sims, simstats, figs, dims{dims_looped});
        case 2, fprintf('2D looping movie NYI\n');%r_analyze_similarity_surfaces_1D(nets, sims, simstats, figs);
        otherwise, error('NYI');
    end;


function vals = compute_common_vals(nets, sims)

    sim = sims{1}{1};

    vals.pat_types = sim.pat_types;
    vals.npattypes = length(vals.pat_types);

    % Only do one hemi (not rh/lh separately)
    vals.locs      = cellfun(@(loc) loc(4:end), sim.hemi_locs(1:end/2), 'UniformOutput', false);
    vals.nlocs     = length(vals.locs);
    vals.tsteps    = sim.tsteps;
    vals.nsims     = length(sim.rh_output(1).patsim);

    vals.ncc    = cellfun(@(nets) nets{1}.sets.ncc,              nets(:,1,1));
    vals.delays = cellfun(@(nets) max(nets{1}.sets.D_CC_LIM(:)), nets(1,:,1));
    vals.Ts     = cellfun(@(nets) max(nets{1}.sets.T_LIM(:)),    nets(:,1,1));



function r_analyze_similarity_surfaces_1D(nets, sims, simstats, figs, dim)
% When we vary on just one dimension, show as a surface plot vs. time

    vals = compute_common_vals(nets, sims);
    yvals = sort(vals.(dim));

    %% Figure 1: mean difference from output similarity
    if ismember(1, figs)
        for pti=1:vals.npattypes
            f1h = figure('Position', [ 72         -21        1200         700]);

            data = zeros(vals.nlocs, length(vals.(dim)), vals.tsteps);

            for li=2:vals.nlocs+1 % skip input
                subplot(2,2,li-1);%1, nlocs, li);
                set(gca, 'FontSize', 16);

                if li <= vals.nlocs
                    for xi=1:length(vals.(dim))
                        data(li, xi, :) = abs(squeeze(simstats{xi}(:, li, pti, 5))); %eliminate the sign for cleaner plotting
                    end;
                    surf(1:vals.tsteps, vals.(dim), squeeze(data(li, :, :)));

                    switch vals.locs{li}
                        case 'cc', tit='inter-';
                        case 'ih', tit='intra-';
                        otherwise, tit = vals.locs{li};
                    end;
                    title(strrep(tit, '_', '\_'));
                else
                    alphas = cellfun(@(nets) nets{1}.sets.ncc / nets{1}.sets.nhidden_per, nets);
                    alphas = repmat(alphas(:), [1 vals.tsteps]);
                    cc_data = squeeze(data(2, :, :)); cc_data(isnan(cc_data)) = 0;
                    ih_data = squeeze(data(3, :, :)); ih_data(isnan(ih_data)) = 0;
                    surf_data = alphas .* cc_data + (1-alphas) .* ih_data;
                    surf(1:vals.tsteps, yvals, surf_data);
                    title('all hidden');
                end;
                set(gca, 'xlim', [1 vals.tsteps], 'ylim', [min(yvals), max(yvals)], 'zlim', sort([0 1]));
                set(gca, 'ytick', yvals);
                view([40.5 32]);

                xlabel('tsteps'); zlabel('asymmetry');
                switch (dim)
                    case 'ncc', ylabel('# inter- units');
                    otherwise, ylabel(dim);
                end;
            end;
        end;
    end;
