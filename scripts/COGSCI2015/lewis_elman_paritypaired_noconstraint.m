% Script to test the parity task between the hemispheres, across the full matrix of delays x ncc.
%

net = lewis_elman_common_args();

% Do paired parity task
net.sets.dataset = 'parity';
net.sets.dirname = fullfile(net.sets.dirname, net.sets.dataset);

% Manually-determined training parameters
net.sets.eta_w = 0.005;
net.sets.phi_w = 0.5;
net.sets.lambda_w = 1E-3;

% Train over all combinations of ncc and delays
ncc    = [2 6 10]; %linspace(net.sets.nhidden_per, 0, 6);
delays = [1 5 10];

r_train_and_analyze_all(net, 2, ncc, delays);

