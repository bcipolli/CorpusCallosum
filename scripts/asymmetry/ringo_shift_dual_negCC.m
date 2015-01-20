% Script for testing a single task (shift), where the output for each hemisphere
% depends on the input from BOTH hemispheres.  Each hemisphere outputs the input of the other.
%
% Do this with negative-only callosal connections.

net = ringo_common_args();
net.sets.dataset = 'shift_dual';
net.sets.dirname = fullfile(net.sets.dirname, net.sets.dataset);
net.sets.train_criterion = 0.50;
net.sets.eta_w = 0.02;
net.sets.phi_w = 0.50;
net.sets.lambda_w = 3E-4;
net.sets.batch_size = 32;
net.sets.niters = 2500;

net.sets.cc_wt_lim       = [-inf 0];

ncc = linspace(0, net.sets.nhidden_per - 2, 5); % assumes cc fibers do not project intra-
delays = [1 5 10 15 20];

% Sample along ncc and delays independently
r_asymmetry_looper(net, 10, ncc,              delays(ceil(end/2)));
r_asymmetry_looper(net, 10, ncc(ceil(end/2)), delays);
