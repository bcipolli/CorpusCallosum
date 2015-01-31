% Script for testing a single task (shift), where the output for each hemisphere
% depends on the input from BOTH hemispheres.  Each hemisphere outputs parity computed over all bits.

net = lewis_elman_common_args();

% Do this with negative-only callosal connections.
net.sets.dataset = 'parity_and_shift';  % dual hemisphere task
net.sets.dirname = fullfile(net.sets.dirname, net.sets.dataset);
net.sets.cc_wt_lim       = [-inf 0]; % Constrain CC weights to non-positive

% Manually-determined training parameters
net.sets.nhidden_per = 40; % with two tasks, more hidden units are needed.
net.sets.eta_w       = 3E-2;    %learning rate (initial)
net.sets.alpha_w     = 0.5;       %momentum

% Train over all combinations of ncc and delays
ncc = linspace(net.sets.nhidden_per, 0, 6);
delays = [1 5 10 15 20];

r_asymmetry_looper(net, 10, ncc, delays);
