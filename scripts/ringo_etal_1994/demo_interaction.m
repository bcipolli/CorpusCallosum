function demo_interaction(figs, save_figs, use_legend)
    if ~exist('figs','var'), figs=[]; end;
    if ~exist('use_legend','var'), use_legend = false; end;
    if ~exist('save_figs','var'), save_figs = true; end;
    
    brainsz = 10.^(0:0.1:3);
    lat = sqrt(log(brainsz)); lat = 100*lat ./ max(lat);
    comm = exp(-0.5*log(brainsz)); comm = 100*comm ./ max(comm);
    fhs = [];
    
    % Figure 1: brain size vs. lateralization
    if (ismember(1, figs) || isempty(figs))
        fhs(end+1) = figure('Position', [ 360    97   421   581]); set(gca, 'FontSize', 14);
        semilogx(brainsz, lat, 'b', 'LineWidth', 5);
        %xlabel('brain size (g)');
%        ylabel('percent');
        set(gca, 'xtick', [], 'ytick', []);  % yaxis unlabeled
        if use_legend, legend({'Lateralization'}, 'Location', 'NorthWest'); end;   
    end;

    % Figure 2: brain size vs. interhemispheric communication
    if (ismember(2, figs) || isempty(figs))
        fhs(end+1) = figure('Position', [ 360    97   421   581]); set(gca, 'FontSize', 14);
        semilogx(brainsz, comm, 'r', 'LineWidth', 5);
        %xlabel('brain size (g)');
%        ylabel('percent');
        set(gca, 'xtick', [], 'ytick', []);  % yaxis unlabeled
        if use_legend, legend({sprintf('Interhemispheric\ncommunication')}, 'Location', 'NorthWest'); end;   
    end;
    
    % Figure 3: brain size vs. interhemispheric communication
    if (ismember(2, figs) || isempty(figs))
        fhs(end+1) = figure('Position', [ 360    97   421   581]); set(gca, 'FontSize', 14);
        semilogx(brainsz, comm, 'r', 'LineWidth', 5);
        hold on;
        semilogx(brainsz, lat, 'b', 'LineWidth', 5);
        %xlabel('brain size (g)');
%        ylabel('percent');
        set(gca, 'xtick', [], 'ytick', []);  % yaxis unlabeled
        if use_legend, legend({sprintf('Interhemispheric\ncommunication'), 'Lateralization'}, 'Location', 'NorthWest'); end;
    end;
    
    if save_figs
        addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));
        for fi=1:length(fhs)
            export_fig(fhs(fi), sprintf('%d.png', fi), '-transparent') 
        end;
    end;
    