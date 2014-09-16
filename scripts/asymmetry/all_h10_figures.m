clear all global
addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));

expt3_dir = fullfile(r_out_path('cache'), 'asymmetry', 'all_h10');
cache_file = fullfile(expt3_dir, 'all_h10_cache.mat');

%% Noise dependence: 10 time-steps
ringo_figures(fullfile(expt3_dir, 'symmetric_symmetric_nonoise_n10'), fullfile(expt3_dir, 'symmetric_symmetric_nonoise_n0'), [3], cache_file);



n=10 *more similar* than n=0.
no-noise LH-RH similarity ( all): 0.930136
   noise LH-RH similarity ( all): 0.712238

[note: should be differential from similarity of inputs]

but... should compare to the original!  perhaps independent hemispheres are different similarities from each other...

b.pats.train.P(2,:,2:end)

rh_in =  squeeze(b.pats.train.P(2,:,2:6))
lh_in =  squeeze(b.pats.train.P(2,:,7:11))
rh_out =  squeeze(b.pats.train.d(1,:,1:5))
lh_out =  squeeze(b.pats.train.d(1,:,6:10))

rh_in_sim = pdist(rh_in, 'correlation');
lh_in_sim = pdist(lh_in, 'correlation');
rh_out_sim = pdist(rh_out, 'correlation');
lh_out_sim = pdist(lh_out, 'correlation');


% visualize hidden unit correimagesc(pdist2mat(ation to input (and output) over time.


figure;
subplot(2,2,1);
imagesc(pdist2mat(rh_in_sim));
axis image;
title('rh_in_sim');

subplot(2,2,2);
imagesc(pdist2mat(lh_in_sim));
axis image;
title('lh_in_sim');

subplot(2,2,3);
imagesc(pdist2mat(rh_out_sim));
axis image;
title('rh_out_sim');

subplot(2,2,4);
imagesc(pdist2mat(lh_out_sim));
axis image;
title('lh_out_sim');
