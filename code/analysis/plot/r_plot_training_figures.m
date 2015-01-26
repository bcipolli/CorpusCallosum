function [f] = r_plot_training_figures(nets, datas, vals, nexamples, figs)
    if ~exist('figs', 'var'), figs = {'lesion', 'niters'}; end;

    f = {};

    if ismember('lesion', figs), f{end+1} = r_plot_lesion(datas); end;
    if ismember(0, figs), f{end+1} = r_plot_niters(nets, datas, vals, nexamples); end;

    f = [f{:}];


function f = r_plot_lesion(data)
    f(end+1) = figure;
    hold on;
    plot(mean(data.lesion.avgerr,2));
    plot(mean(data.nolesion.avgerr,2));

    %out.E_lesion - out.E_pat(100:100:end,:,:)


function fig = r_plot_niters(nets, datas, vals, nexamples)
    guru_assert(vals.dims.nvaried <= 2, 'Can''t handle more than 2 dims currently!');

    niters       = cellfun(@(d) cell2mat(guru_getfield(d, 'niters', NaN)), datas, 'UniformOutput', false);
    pct_completed_models = cellfun(@(n) 100*length(n) / nexamples, niters);

    dim_ids = vals.dims.ids;
    dim_names = vals.dims.names;

    % Plot a single figure, with two subplots
    fig = figure('Position', [0, 0, 1280 800], 'name', 'niters_ntrained');

    % Number of iterations
    subplot(1, 2, 1);
    switch vals.dims.nvaried % # non-singular values (i.e. was iterated)
        case 1
            dim_id = dim_ids{1};
            errorbar(vals.(dim_id), cellfun(@(n) nanmean(n), niters), cellfun(@(n) nanstd(n), niters));
            xlabel(dim_names{1}); ylabel('# iterations');
        case 2
            surf(vals.(dim_ids{1}), vals.(dim_ids{2}), cellfun(@(n) nanmean(n), niters));
            xlabel(dim_names{1}); ylabel(dim_names{2}); zlabel('% models');

        otherwise, error('NYI');
    end;
    set(gca, 'FontSize', 16);
    title('# iterations.');

    % Number of trained models
    subplot(1, 2, 2);
    switch vals.dims.nvaried % # non-singular values (i.e. was iterated)
        case 1
            dim_id = dim_ids{1};
            bar(vals.(dim_id), pct_completed_models);
            xlabel(dim_names{1}); ylabel('# iterations');
            set(gca, 'ylim', [0 100]);
        case 2
            surf(vals.(dim_ids{1}), vals.(dim_ids{2}), pct_completed_models);
            xlabel(dim_names{1}); ylabel(dim_names{2}); zlabel('% models');
            set(gca, 'zlim', [0 100]);

        otherwise, error('NYI');
    end;
    set(gca, 'FontSize', 16);
    title('% models trained.');


