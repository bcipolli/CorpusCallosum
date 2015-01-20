% Script for testing a single task (parity), where the output for each hemisphere
% depends on the input from BOTH hemispheres.  Each hemisphere outputs parity computed over all bits.
%
% Do this with delay-dependent noise on the callosal connections.

net = lewis_elman_common_args();
net.sets.dataset = 'parity_dual';
net.sets.dirname = fullfile(net.sets.dirname, net.sets.dataset);
net.sets.train_criterion = 0.50;
net.sets.eta_w = 0.02;
net.sets.phi_w = 0.50;
net.sets.lambda_w = 3E-4;
net.sets.batch_size = 32;
net.sets.niters = 2500;

net.sets.axon_noise       = 0.005;
net.sets.noise_init       = 0;%.001;%1;
net.sets.noise_input      = 0;%1E-6;%.001;%001;%1;

ncc = round(linspace(0, net.sets.nhidden_per, 6));
delays = [1 5 10 15 20];

% Sample along ncc and delays independently
r_asymmetry_looper(net, 10, ncc,              delays(ceil(end/2)));
r_asymmetry_looper(net, 10, ncc(ceil(end/2)), delays);
