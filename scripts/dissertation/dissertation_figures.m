clear all global
addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));

%out_path = '/Users/bcipolli/Dropbox/_dissertation/dissertation/chapter5/figs';

%% Ringo_results
%demo_ringo_fig_diff; set(gcf, 'Name', 'Ringo_results');


%% Experiment 1

expt1_dir = fullfile(r_out_path('cache'), guru_fileparts(which(mfilename), 'dir'));
cache_file = fullfile(expt1_dir, 'expt1_cache.mat');
expt1_noise_dir = fullfile(expt1_dir, 'expt1_noise_10_1');
expt1_extra_noise_dir = fullfile(expt1_dir, 'expt1_noise_10_2');
expt1_nonoise_dir = fullfile(expt1_dir, 'expt1_nonoise_10');


ringo_figures(expt1_nonoise_dir, expt1_noise_dir, [3.1], cache_file); set(gcf, 'Name', 'similarity');

%
%ringo_figures(expt1_nonoise_dir, expt1_noise_dir, [0.3], cache_file); set(gcf, 'Name', 'ringo_expt1_classification_error');
%ringo_figures(expt1_nonoise_dir, expt1_noise_dir, [0.4], cache_file); set(gcf, 'Name', 'ringo_expt1_sumsquared_error');

%
composite_figure = figure('Name', 'expt1_inter_matters', 'Position', [84          97        1271         687]);
ax = subplot(2,3,1); ringo_figures(expt1_nonoise_dir, expt1_noise_dir, [0.4], cache_file); title(''); xlabel(''); mfe_copyaxes(gca, ax, true); close(gcf);
ax = subplot(2,3,2); ringo_figures(expt1_nonoise_dir, expt1_noise_dir, [0.6], cache_file); title(''); xlabel(''); ylabel(''); mfe_copyaxes(gca, ax, true); close(gcf);
ax = subplot(2,3,3); ringo_figures(expt1_nonoise_dir, expt1_noise_dir, [0.8], cache_file); title(''); xlabel(''); ylabel(''); mfe_copyaxes(gca, ax, true); close(gcf);
ax = subplot(2,3,4); ringo_figures(expt1_nonoise_dir, expt1_noise_dir, [1.4], cache_file); title(''); mfe_copyaxes(gca, ax, true); close(gcf);
ax = subplot(2,3,5); ringo_figures(expt1_nonoise_dir, expt1_noise_dir, [1.6], cache_file); title(''); ylabel('');  mfe_copyaxes(gca, ax, true); close(gcf);
ax = subplot(2,3,6); ringo_figures(expt1_nonoise_dir, expt1_noise_dir, [1.8], cache_file); title(''); ylabel('');  mfe_copyaxes(gca, ax, true); close(gcf);
axes('position',[0,0,1,1],'visible','off');
text(0.24, 0.5, 'All patterns',              'HorizontalAlignment', 'Center', 'FontSize', 18);
text(0.52, 0.5, 'Intrahemispheric patterns', 'HorizontalAlignment', 'Center', 'FontSize', 18);
text(0.81, 0.5, 'Interhemispheric patterns', 'HorizontalAlignment', 'Center', 'FontSize', 18);
text(0.03, 0.25, sprintf('Lesion-Induced\nError'), 'HorizontalAlignment', 'Center', 'FontSize', 28, 'Rotation', 90)
text(0.03, 0.75, sprintf('Raw\nError'),       'HorizontalAlignment', 'Center', 'FontSize', 28, 'Rotation', 90)



% Save cache file
if ~exist(cache_file, 'file')
    save_cache_data(cache_file);
end;

%% Experiment 2


%% Experiment 3


%% Experiment 4

%% Save all figures
if exist('out_path', 'var') && ~isempty(out_path)
    while ~isempty(findobj('type','figure'))
        if ~get(gcf, 'Name'), continue; end;
        export_fig(gcf, fullfile(out_path, sprintf('%s.png', get(gcf, 'Name'))), '-transparent');
        close(gcf);
    end;
end;
