function r_analyze_similarity_surfaces(nets, sims, simstats, figs)


    if ~iscell(nets), nets = { nets }; end;
    if ~exist('figs', 'var'), figs = [1:3]; end;

    dims = {'ncc', 'delays', 'Ts'};
    dims_looped = size(nets) > 1;
    ndims_looped = sum(dims_looped);

    switch ndims_looped
        case 1, r_analyze_similarity_surfaces_1D(nets, sims, simstats, figs, dims{dims_looped});
        case 2, r_analyze_similarity_surfaces_1D(nets, sims, simstats, figs);
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

    %% Figure 1: mean difference from output similarity
    if ismember(1, figs)
        for pti=1:vals.npattypes
            f1h = figure('Position', [ 72         -21        1209         794]);

            data = zeros(vals.nlocs, length(vals.(dim)), vals.tsteps);

            for li=2:vals.nlocs+1
                subplot(2,2,li-1);%1, nlocs, li)
                set(gca, 'FontSize', 14);

                if li <= vals.nlocs
                    for xi=1:length(vals.(dim))
                        data(li, xi, :) = squeeze(simstats{xi}(:, li, pti, 5));
                    end;
                    surf(1:vals.tsteps, vals.(dim), squeeze(data(li, :, :)));
                    title(strrep(vals.locs{li}, '_', '\_'));
                else
                    alpha = nets{li}{1}.sets.ncc / nets{li}{1}.sets.nhidden_per;
                    surf(1:vals.tsteps, vals.(dim), squeeze(alpha * data(2, :, :) + (1-alpha) * data(3, :, :)))
                    title('intra, combined (avg)');
                end;
                view([40.5 32]);
                ylabel(dim); xlabel('tsteps'); zlabel('asymmetry');
            end;
        end;
    end;
