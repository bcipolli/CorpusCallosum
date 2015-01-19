function r_analyze_similarity_surfaces(nets, sims, simstats, figs)


    if ~iscell(nets), nets = { nets }; end;
    if ~exist('figs', 'var'), figs = [2]; end;
    figs = 2;

    dims = {'ncc', 'delays', 'Ts'};
    dims_looped = size(nets) > 1;
    ndims_looped = sum(dims_looped);

    switch ndims_looped
        case 0, warning('No valid networks were trained, so no plots can be made.'); return;
        case 1, r_analyze_similarity_surfaces_1D(nets, sims, simstats, figs, dims{dims_looped}, 9); % 5=mean, 9=corr
        case 2, fprintf('2D looping movie NYI\n');%r_analyze_similarity_surfaces_1D(nets, sims, simstats, figs);
        otherwise, error('NYI');
    end;


function r_analyze_similarity_surfaces_1D(nets, sims, simstats, figs, dim, data_plotted)
% When we vary on just one dimension, show as a surface plot vs. time

    if ~exist('data_plotted', 'var'), data_plotted = 5; end;

    vals = r_compute_common_vals(nets, sims);
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
    for pti=1:vals.npattypes
        if ismember(1, figs)
            f1h = figure('Position', [ 0         0        400*ncols         350*nrows]);
        end;
        if ismember(2, figs)
            f2h = figure('Position', [ 0         0        500*ncols         350*nrows]);
        end;

        data = nan(vals.nlocs, length(vals.(dim)), vals.tsteps);

        for rowi=1:nrows
            for coli=1:ncols
                guru_assert(coli ~= 3 || ~isnan(hu_locs(rowi))); % just dump directly

                ploti = coli + ncols*(rowi-1);

                switch coli
                    case 1, li = cc_locs(rowi);
                    case 2, li = ih_locs(rowi);
                    case 3, li = hu_locs(rowi);
                end;

                for xi=1:length(vals.(dim))
                    if isempty(simstats{xi}), continue; end;
                    data(li, xi, :) = abs(squeeze(simstats{xi}(:, li, pti, data_plotted))); %eliminate the sign for cleaner plotting
                end;

                if ismember(1, figs)
                    figure(f1h);
                    subplot(nrows,ncols,ploti);
                    set(gca, 'FontSize', 16);

                    surf(1:vals.tsteps, vals.(dim), squeeze(data(li, :, :)));

                    switch vals.locs{li}
                        case 'cc', tit='inter-';
                        case 'ih', tit='intra-';
                        case 'hu', tit='hidden';
                        otherwise, tit = vals.locs{li};
                    end;
                    title(strrep(tit, '_', '\_'));

                    set(gca, 'xlim', [1 vals.tsteps], 'ylim', [min(yvals), max(yvals)], 'zlim', sort([0 1]));
                    set(gca, 'ytick', yvals);
                    view([40.5 32]);

                    xlabel('tsteps'); zlabel('asymmetry');
                    switch (dim)
                        case 'ncc', ylabel(sprintf('cc units'));
                        otherwise, ylabel(dim);
                    end;
                end;

                if ismember(2, figs)
                    figure(f2h);
                    subplot(nrows,ncols,ploti);
                    set(gca, 'FontSize', 16);

                    % 7 unique colors. 1 is NaN, so start at 2
                    tsamps = round(linspace(2, vals.tsteps, 7));

                    plot(vals.(dim), squeeze(data(li, :, tsamps)), 'LineWidth', 2);

                    switch vals.locs{li}
                        case 'cc', tit='inter-';
                        case 'ih', tit='intra-';
                        case 'hu', tit='hidden';
                        otherwise, tit = vals.locs{li};
                    end;
                    title(strrep(tit, '_', '\_'));

                    xlabel(dim); ylabel('asymmetry');
                    set(gca, 'xlim', [1 max(vals.(dim))*1.5]);
                    legend(guru_csprintf('%d', tsamps), 'Location', 'NorthEast');
                end;

            end;
        end;
    end;
