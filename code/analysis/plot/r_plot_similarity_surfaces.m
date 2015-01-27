function r_plot_similarity_surfaces(nets, vals, simstats, figs)

    if ~iscell(nets), nets = { nets }; end;
    if ~exist('figs', 'var'), figs = [2]; end;

    switch vals.dims.nvaried
        case 0, warning('No valid networks were trained, so no plots can be made.'); return;
        case 1, r_plot_similarity_surfaces_1D(nets, vals, simstats, [], 9, figs); % 5=mean, 9=corr
        case 2, r_plot_similarity_surfaces_2D(nets, vals, simstats, 9, figs);
        otherwise, error('NYI');
    end;


function r_plot_similarity_surfaces_2D(nets, vals, simstats, data_plotted, figs)
    if ~exist('data_plotted', 'var'), data_plotted = 5; end;
    if ~exist('figs', 'var'), figs = []; end;

    for di=1:vals.dims.nvaried
        cur_dim_id = vals.dims.ids{di};
        cur_dim_vals = vals.(cur_dim_id);

        other_dim_id = setdiff(vals.dims.ids, {cur_dim_id});
        other_dim_id = other_dim_id{1};

        for xi=1:length(cur_dim_vals)

            value_idx = vals.(cur_dim_id) == cur_dim_vals(xi);

            % Gotta fake it.  NOTE that this may leave the third dimension
            %   as 2D... but we hope that it'll be ignored downstream!
            cur_vals = vals;
            cur_vals.(cur_dim_id) = unique(vals.(cur_dim_id)(value_idx));  % should be one
            cur_vals.(other_dim_id) = vals.(other_dim_id)(value_idx);  % should be many

            r_plot_similarity_surfaces_1D( ...
                nets(value_idx), ...
                cur_vals, ...
                simstats(value_idx), ...
                other_dim_id, ...
                data_plotted, ...
                figs)
        end;
    end;

    % We want to get a single number about asymmetry.
    %   Currently, we have a number at each timestep.
    %   Let's get a number at 1/3, 2/3, and 3/3 of the
    %   tSteps.
    times = linspace(0, vals.tsteps, 4);
    times = round(times(2:end));

    [locs] = r_get_locs(vals);
    col_ids = {'cc', 'ih', 'hu'};

    % Surfaces for intra, inter, and full.., for all 3 timesteps.  So a 3x3 grid.
    fh = figure('name', 'similarity_matrix', 'Position', [0, 0, 1800 1800]);

    for ti=1:length(times)
        dim1_id = vals.dims.ids{1};
        dim2_id = vals.dims.ids{2};

        dim1_vals = vals.(dim1_id)(:, 1);
        dim2_vals = vals.(dim2_id)(1, :);

        surf_data = nan(length(col_ids), length(dim1_vals), length(dim2_vals));

        for xi=1:length(dim2_vals)
            value_idx = vals.(cur_dim_id) == dim2_vals(xi);
            all_data = r_distill_data(simstats(value_idx), dim1_id, vals, 1, data_plotted, col_ids);
            surf_data(:, :, xi) = all_data(:, 1, :, times(ti));
        end;

        for li=1:length(col_ids)
            ploti = ti + length(times)*(li-1);
            subplot(length(col_ids), length(times), ploti);
            set(gca, 'FontSize', 16);

            loc_data = squeeze(surf_data(li, :, :));
            loc_name = locs.(col_ids{li}).name;

            surf(dim1_vals, dim2_vals, loc_data');
            xlabel(vals.dims.names{1});
            ylabel(vals.dims.names{2});
            zlabel('similarity');
            title(sprintf('%s similarity @ %d / %d steps', loc_name, times(ti), vals.tsteps));
        end;
    end;


function r_plot_similarity_surfaces_1D(nets, vals, simstats, dim_id, data_plotted, figs)
% When we vary on just one dimension, show as a surface plot vs. time

    if ~exist('data_plotted', 'var'), data_plotted = 5; end;
    if ~exist('figs', 'var'), figs = []; end;
    if ~exist('dim_id') || isempty(dim_id)
        guru_assert(vals.dims.nvaried == 1);
        dim_id = vals.dims.ids{1};
    end;
    dim_name = vals.dims.names{strcmp(vals.dims.ids, dim_id)};

    yvals = sort(vals.(dim_id));

    [locs] = r_get_locs(vals);
    col_ids = {'cc', 'ih', 'hu'};

    ncols = 3;
    nrows = length(locs.cc.idx);

    %% Figure 1: mean difference from output similarity
    for pti=1:vals.npattypes
        [data] = r_distill_data(simstats, dim_id, vals, pti, data_plotted);


        if ismember(1, figs)
            f1h = figure('name', 'f1h', 'Position', [ 0  0 1000*ncols  600*nrows]);
            for rowi=1:nrows
                for coli=1:ncols
                    ploti = coli + ncols*(rowi-1);
                    loc_data = squeeze(data(coli, rowi, :, :));
                    loc_name = locs.(col_ids{coli}).name;

                    subplot(nrows,ncols,ploti);
                    set(gca, 'FontSize', 16);

                    surf(1:vals.tsteps, vals.(dim_id), loc_data);
                    title(strrep(loc_name, '_', '\_'));

                    set(gca, 'xlim', [1 vals.tsteps], 'ylim', [min(yvals), max(yvals)], 'zlim', sort([0 1]));
                    set(gca, 'ytick', yvals);
                    view([40.5 32]);

                    xlabel('Time (steps)');
                    ylabel(dim_name);
                    zlabel('asymmetry');
                end;
            end;
        end;

        if ismember(2, figs)
            f2h = figure('name', 'f2h', 'Position', [ 0  0 600*ncols  600*nrows]);
            for rowi=1:nrows
                for coli=1:ncols
                    ploti = coli + ncols*(rowi-1);
                    loc_data = squeeze(data(coli, rowi, :, :));
                    loc_name = locs.(col_ids{coli}).name;

                    subplot(nrows,ncols,ploti);
                    set(gca, 'FontSize', 16);

                    % 7 unique colors. 1 is NaN, so start at 2
                    tsamps = round(linspace(2, vals.tsteps, 7));

                    plot(vals.(dim_id), loc_data(:, tsamps), 'LineWidth', 2);
                    title(strrep(loc_name, '_', '\_'));

                    xlabel(dim_name);
                    ylabel('asymmetry');
                    set(gca, 'xlim', [1 max(vals.(dim_id))*1.5]);
                    legend(guru_csprintf('%d', tsamps), 'Location', 'NorthEast');
                end;
            end;
        end;
    end;

    if exist('f1h', 'var'), set(f1h, 'Position', [ 0  0 500*ncols  600*nrows]), end;
    if exist('f2h', 'var'), set(f2h, 'Position', [ 0  0 600*ncols  600*nrows]), end;


function [locs] = r_get_locs(vals)
    locs.cc.name = 'inter-';
    locs.cc.idx = find(cellfun(@(a) ~isempty(a), regexp(vals.locs, 'cc$')));

    locs.ih.name = 'intra-';
    locs.ih.idx = find(cellfun(@(a) ~isempty(a), regexp(vals.locs, 'ih$')));

    locs.hu.name = 'hidden';
    locs.hu.idx = find(cellfun(@(a) ~isempty(a), regexp(vals.locs, 'hu$')));

    guru_assert(length(locs.cc.idx) == length(locs.ih.idx), '# cc locs must be the same as # ih locs'); %'

    if length(locs.hu.idx) ~= 0
        guru_assert(length(locs.cc.idx) == length(locs.hu.idx), '# cc locs must be the same as # hu locs'); %'
    else
        locs.hu.idx = [NaN NaN];
    end;


function [data] = r_distill_data(simstats, dim_id, vals, pattern_idx, data_plotted, col_ids)
    if ~exist('pattern_idx', 'var'), pattern_idx = 1; end;
    if ~exist('data_plotted', 'var'), data_plotted = 5; end;
    if ~exist('col_ids', 'var'), col_ids = {'cc', 'ih', 'hu'}; end;
    if ~exist('dim_id') || isempty(dim_id)
        guru_assert(vals.dims.nvaried == 1);
        dim_id = vals.dims.ids{1};
    end;

    [locs] = r_get_locs(vals);

    ncols = length(col_ids);
    nrows = length(locs.cc.idx);

    data = nan(length(col_ids), length(locs.cc.idx), length(vals.(dim_id)), vals.tsteps);

    for rowi=1:nrows
        for coli=1:ncols
            li = locs.(col_ids{coli}).idx(rowi);
            for xi=1:length(vals.(dim_id))
                if isempty(simstats{xi}), continue; end;
                data(coli, rowi, xi, :) = abs(squeeze(simstats{xi}(:, li, pattern_idx, data_plotted))); %eliminate the sign for cleaner plotting
            end;
        end;
    end;
