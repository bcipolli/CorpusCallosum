addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));

expt1_dir = fullfile(r_out_path('cache'), 'dissertation');
cache_file = fullfile(expt1_dir, 'expt1_cache.mat')



%% Noise dependence: 10 time-steps
for fi=r_plot_ringo_figures(fullfile(expt1_dir, 'expt1_nonoise_10'), fullfile(expt1_dir, 'expt1_noise_10_1'), [0.4 0.6 0.8 1.4 1.6 1.8 2.2], cache_file)
%    figure(fi);
%    title('Learning Trajectory (delay=10 time-steps)');
%    [~,~,oh] = legend();
%    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;
return


%% Noise dependence: 2 time-steps
for fi=r_plot_ringo_figures(fullfile(expt1_dir, 'nonoise_2'), fullfile(expt1_dir, 'noise_2_1'), [0.4 0.8], cache_file)
    figure(fi);
    title('Learning Trajectory (delay=2 time-steps)');
%    [~,~,oh] = legend();
%    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;

%% Time dependence: control

% % wrongly classified
for fi=r_plot_ringo_figures(fullfile(expt1_dir, 'expt1_nonoise_2'), fullfile(expt1_dir, 'expt1_nonoise_10'), [0.4 0.8], cache_file)
    figure(fi);
    [~,~,oh] = legend();
    title('Learning Trajectory (control)');
    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;

%% Time dependence: noise

% % wrongly classified
for fi=r_plot_ringo_figures(fullfile(expt1_dir, 'expt1_noise_2_1'), fullfile(expt1_dir, 'expt1_noise_10_2'), [0.4 0.8], cache_file)
    figure(fi);
    title('Learning Trajectory (noise)');
    [~,~,oh] = legend();
    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;


% Save off the cache file, for future fast access
if ~exist(cache_file, 'file')
    save_cache_data(cache_file);
end;