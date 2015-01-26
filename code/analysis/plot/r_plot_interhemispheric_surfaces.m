function r_plot_interhemispheric_surfaces(nets, datas, vals, figs)
%  for each pairs, you'll get a comparison here.  get that ringo value, then plot as a surface.
%  since in this case we only have a single value, perhaps summing over the abs(differences) will ork.

%    cellfun  mean(mean(data.E_pat())) - mean(mean(data.E_lesion))

    if ~exist('figs', 'var'), figs = {'interhemispheric_communication_surf'}; end;


    model_diff = @(m) mean(abs(m.lesion.avgerr(end, :) - m.nolesion.avgerr(end, :)));
    ih_comm_surf = cellfun(@(ms) mean(cellfun(model_diff, ms)), datas);

    % Plot a single figure, with two subplots
    fig = figure('Position', [0, 0, 1280 800]);
    set(gcf, 'name', 'interhemispheric_communication_surf');

    surf(vals.(vals.dims.ids{1}), vals.(vals.dims.ids{2}), ih_comm_surf);
    xlabel(vals.dims.names{1});
    ylabel(vals.dims.names{2});
    zlabel('IH communication (max: 1)');

    set(gca, 'FontSize', 16);
    title('Degree of interhemispheric communication.');
