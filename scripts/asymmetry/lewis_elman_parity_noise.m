% Script for testing a single task (shift) that the hemispheres do in
% parallel, with noise on the interhemispheric connections

net = lewis_elman_common_args();
net.sets.dataset = 'parity';
net.sets.dirname = fullfile(net.sets.dirname, net.sets.dataset);
%net.sets.train_criterion = 0.25;
net.sets.eta_w = 0.01;
net.sets.phi_w = 0.5;
net.sets.lambda_w = 1E-3;

net.sets.axon_noise       = 0.005;
net.sets.noise_init       = 0;%.001;%1;
net.sets.noise_input      = 0;%1E-6;%.001;%001;%1;


ncc = round(linspace(0, net.sets.nhidden_per, 6));
delays = [1 5 10 15 20];

% Sample along ncc and delays independently
asymmetry_looper(net, 10, ncc,              delays(ceil(end/2)));
asymmetry_looper(net, 10, ncc(ceil(end/2)), delays);
