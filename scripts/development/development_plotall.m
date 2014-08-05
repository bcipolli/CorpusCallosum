addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));

cogsci_dir = fullfile(r_out_path('cache'), 'development');
cache_file = fullfile(cogsci_dir, 'development_cache.mat');

%% Noise dependence: 10 time-steps
for fi=ringo_figures(fullfile(cogsci_dir, 'nonoise_test_2000'), fullfile(cogsci_dir, 'noise_test_2000'), [0.4 1.2 2.2 3], cache_file)
    %figure(fi);
    %title('Learning Trajectory (delay=10 time-steps)');
%    [~,~,oh] = legend();
%    legend(oh, {'Intact (1 time-step)', 'Lesioned (1 time-step)', 'Intact (10 time-steps)', 'Lesioned (10 time-steps)'});
end;
return


% Save off the cache file, for future fast access
if ~exist(cache_file, 'file')
    save_cache_data(cache_file);
end;