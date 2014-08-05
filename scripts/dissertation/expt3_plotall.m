clear all global
addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));

expt3_dir = fullfile(r_out_path('cache'), 'dissertation');
cache_file = fullfile(expt3_dir, 'expt3_cache.mat');

%% Noise dependence: 10 time-steps
ringo_figures(fullfile(expt3_dir, 'expt3_nonoise_10'), fullfile(expt3_dir, 'expt3_noise_10_2'), [3], cache_file);
%ringo_figures(fullfile(expt3_dir, 'expt3_nonoise_10_5000'), fullfile(expt3_dir, 'expt3_noise_10_2_5000'), [0.4 0.6 0.8 1.4 1.6 1.8 2.2], cache_file);

% Save off the cache file, for future fast access
%if ~exist(cache_file, 'file')
%    save_cache_data(cache_file);
%end;