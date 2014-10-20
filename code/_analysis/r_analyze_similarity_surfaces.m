function r_analyze_similarity_surfaces(nets, sims, simstats, figs)


    if ~iscell(nets), nets = { nets }; end;
    if ~exist('figs', 'var'), figs = [1:3]; end;

    dims = {'ncc', 'delays', 'Ts'};
    dims_looped = size(nets) > 1;
    ndims_looped = sum(dims_looped);

    switch ndims_looped
        case 1, r_analyze_similarity_surfaces_1D(nets, sims, simstats, figs, dims{dims_looped}, 9); % 5=mean, 9=corr
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



function r_analyze_similarity_surfaces_1D(nets, sims, simstats, figs, dim, data_plotted)
% When we vary on just one dimension, show as a surface plot vs. time

    if ~exist('data_plotted', 'var'), data_plotted = 5; end;

    vals = compute_common_vals(nets, sims);
    yvals = sort(vals.(dim));
    cc_locs = find(cellfun(@(a) ~isempty(a), regexp(vals.locs, 'cc$')));
    ih_locs = find(cellfun(@(a) ~isempty(a), regexp(vals.locs, 'ih$')));
    hu_locs = find(cellfun(@(a) ~isempty(a), regexp(vals.locs, 'hu$')));
    guru_assert(length(cc_locs) == length(ih_locs), '# cc locs must be the same as # ih locs');

    if length(hu_locs) ~= 0
        guru_assert(length(cc_locs) == length(hu_locs), '# cc locs must be the same as # hu locs');
    else
        hu_locs = [NaN NaN];
    end;

    ncols = 3;%ceil((vals.nlocs - 1 + length(cc_locs))/2);
    nrows = length(cc_locs);

    %% Figure 1: mean difference from output similarity
    if ismember(1, figs)
        for pti=1:vals.npattypes
            f1h = figure('Position', [ 0         0        400*ncols         350*nrows]);

            data = zeros(vals.nlocs, length(vals.(dim)), vals.tsteps);

            for rowi=1:nrows
                for coli=1:ncols
                    ploti = coli + ncols*(rowi-1);
                    subplot(nrows,ncols,ploti);
                    set(gca, 'FontSize', 16);

                    if coli ~= 3 || ~isnan(hu_locs(rowi)) % just dump directly
                        switch coli
                            case 1, li = cc_locs(rowi);
                            case 2, li = ih_locs(rowi);
                            case 3, li = hu_locs(rowi);
                        end;

                        for xi=1:length(vals.(dim))
                            data(li, xi, :) = abs(squeeze(simstats{xi}(:, li, pti, data_plotted))); %eliminate the sign for cleaner plotting
                        end;
                        surf(1:vals.tsteps, vals.(dim), squeeze(data(li, :, :)));

                        switch vals.locs{li}
                            case 'cc', tit='inter-';
                            case 'ih', tit='intra-';
                            case 'hu', tit='hidden';
                            otherwise, tit = vals.locs{li};
                        end;
                        title(strrep(tit, '_', '\_'));

                    else % compute averages over cc & ih
                        alphas = cellfun(@(nets) nets{1}.sets.ncc / nets{1}.sets.nhidden_per, nets);
                        alphas = repmat(alphas(:), [1 vals.tsteps]);

                        cc_data = squeeze(data(cc_locs(rowi), :, :)); cc_data(isnan(cc_data)) = 0;
                        ih_data = squeeze(data(ih_locs(rowi), :, :)); ih_data(isnan(ih_data)) = 0;

                        if strcmp(vals.locs{cc_locs(rowi)}, 'cc')
                            loc_title = 'all hidden';
                        else
                            loc_title = sprintf('all (%s) hidden', vals.locs{cc_locs(rowi)}(1:end-length('_cc')));
                        end;

                        surf_data = alphas .* cc_data + (1-alphas) .* ih_data;
                        surf(1:vals.tsteps, yvals, surf_data);
                        title(loc_title);
                    end;
                    set(gca, 'xlim', [1 vals.tsteps], 'ylim', [min(yvals), max(yvals)], 'zlim', sort([0 1]));
                    set(gca, 'ytick', yvals);
                    view([40.5 32]);

                    xlabel('tsteps'); zlabel('asymmetry');
                    switch (dim)
                        case 'ncc', ylabel(sprintf('cc units'));
                        otherwise, ylabel(dim);
                    end;
                end;
            end;
        end;
    end;