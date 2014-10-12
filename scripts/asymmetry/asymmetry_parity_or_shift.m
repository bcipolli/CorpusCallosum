% Script to test when each hemisphere is executing parity or shift (irrespective of what the other is doing)

clear globals variables;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

net = common_args();
net.sets.dataset     = 'parity_or_shift';
net.sets.nhidden_per = 40; % with two tasks, more hidden units are needed.
net.sets.dirname     = fullfile(net.sets.dirname, net.sets.dataset);
net.sets.eta_w = 0.002;
net.sets.phi_w = 0.25;
net.sets.lambda_w = 1E-3;

ncc = round(linspace(0, net.sets.nhidden_per, 6));
delays = [1 5 10 15 20];

% Sample along ncc and delays independently
asymmetry_looper(net, 10, ncc,              delays(ceil(end/2)));
asymmetry_looper(net, 10, ncc(ceil(end/2)), delays);
