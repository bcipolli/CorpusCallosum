function [fh] = expt4_figures(force)
%
%
    global g_sets_cache

    if ~exist('r_plot_ringo_figures','file'), addpath(genpath(fullfile(fileparts(which(mfilename)), '..','..','code'))); end;

    if ~exist('force', 'var'), force = false; end;
    if ~exist('cache_file', 'var'), cache_file = fullfile(guru_getOutPath('cache'), guru_fileparts(which(mfilename), 'dir'), sprintf('%s_cache.mat', mfilename)); end;
    if ~exist('plots', 'var'), plots = 0:10; end;

    fh = [];

    % Plots
    %
    if ~exist(cache_file, 'file') || force,
        cache_dir = fullfile(fileparts(cache_file), 'expt4_all_h15');
        [~, ~, folders] = collect_data_looped(cache_dir, cache_file);
        guru_assert(length(folders) == 8, sprintf('8 folders should be found; %d were found within %s', length(folders), cache_dir));
        make_cache_file(folders, cache_file);
    end;
    load_cache_file(cache_file);


    %% Preliminary tests
    datasets = {'asymmetric_symmetric', 'asymmetric_asymmetric', 'symmetric_asymmetric', 'symmetric_symmetric'};
    ncc      = g_sets_cache{1}(1).ncc;

    %% Show the effect of noise within a single dataset
    for d1=1:length(datasets)
        noise_dir   = sprintf('%s_noise_n%d',  datasets{d1}, ncc);
        nonoise_dir = sprintf('%s_nonoise_n%d',datasets{d1}, ncc);
        r_plot_ringo_figures(nonoise_dir, noise_dir, [0.4], cache_file);

        fprintf('%s\n', datasets{d1});
        for fignum=[0.6 0.8 1.4 1.6 2.2 3.2 3.3]
            %continue;
            r_plot_ringo_figures(nonoise_dir, noise_dir, fignum, cache_file);
            %[~,~,oh] = legend();
            %title(sprintf('Effects of noise (%s, ncc=%d; %s)', plot_escape(datasets{d1}), ncc, get(get(gca,'Title'), 'String')));
            set(gcf, 'Name', sprintf('%s-%s', datasets{d1}, guru_iff(fignum == 3.2, 'intra', 'inter')));
            set(gcf, 'Position', [440   189   815   589]);
        end;
        %keyboard
    end;
    %return;

    %keyboard
%
%     %% Show the effect of #cc within a dataset
%     for d1=1:length(datasets)
%         ncc0_dir = sprintf('%s_nonoise_n0',datasets{d1});
%         ncc2_dir = sprintf('%s_nonoise_n2',datasets{d1});
%
%         for fignum=[0.4]
%             r_plot_ringo_figures(ncc0_dir, ncc2_dir, fignum);
%             [~,~,oh] = legend();
%             title(sprintf('Effect of #cc (within a dataset) (%s, nonoise)', plot_escape(datasets{d1})));
%             legend(oh, {'Intact (ncc=0)', 'Lesioned (ncc=0)', 'Intact (ncc=2)', 'Lesioned (ncc=2)'});
%         end;
%     end;


    %% Compare different datasets, without noise
    for d1=1:length(datasets)
        d1_dir = sprintf('%s_nonoise_n%d',datasets{d1}, ncc);
        for d2=d1+1:length(datasets)
            d2_dir = sprintf('%s_nonoise_n%d',datasets{d2}, ncc);

            fh = figure('Position', [ 209         154        1086         630]);
            set(gcf, 'Name', sprintf('nonoise_%s__%s', datasets{d1}, datasets{d2}));
            figs = [0.6 0.8];
            for fi=1:2
                ca = subplot(1,2,fi);
                r_plot_ringo_figures(d1_dir, d2_dir, figs(fi));
                set(gcf, 'Position', [311    50   923   734]);
                [~,~,oh] = legend();
                %title(sprintf('Compare across datasets (no noise, ncc=%d)', ncc));
                legend(oh, {sprintf('Intact (%s)',   plot_escape(datasets{d1})), ...
                            sprintf('Lesioned (%s)', plot_escape(datasets{d1})), ...
                            sprintf('Intact (%s)',   plot_escape(datasets{d2})), ...
                            sprintf('Lesioned (%s)', plot_escape(datasets{d2}))});

                fh2 = gcf;
                mfe_copyaxes(gca, ca, true);
                close(fh2);
            end;
        end;
    end;
%keyboard;

    %% Compare different datasets, with noise
    for d1=1:length(datasets)
        d1_dir = sprintf('%s_noise_n%d',datasets{d1}, ncc);
        for d2=d1+1:length(datasets)
            d2_dir = sprintf('%s_noise_n%d',datasets{d2}, ncc);


            fh = figure('Position', [ 209         154        1086         630]);
            set(gcf, 'Name', sprintf('noise_%s__%s', datasets{d1}, datasets{d2}));
            figs = [0.6 0.8];
            for fi=1:2
                ca = subplot(1,2,fi);
                r_plot_ringo_figures(d1_dir, d2_dir, figs(fi));
                set(gcf, 'Position', [311    50   923   734]);
                [~,~,oh] = legend();
                legend(oh, {sprintf('Intact (%s)',   plot_escape(datasets{d1})), ...
                            sprintf('Lesioned (%s)', plot_escape(datasets{d1})), ...
                            sprintf('Intact (%s)',   plot_escape(datasets{d2})), ...
                            sprintf('Lesioned (%s)', plot_escape(datasets{d2}))});

                fh2 = gcf;
                mfe_copyaxes(gca, ca, true);
                close(fh2);
            end;
        end;
    end;
