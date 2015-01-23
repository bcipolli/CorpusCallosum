% Script to test when LH and RH always do the same task--parity sometimes, shift other times.
%

net = ringo_common_args();
net.sets.dataset     = 'parity_and_shift';
net.sets.dirname     = fullfile(net.sets.dirname, net.sets.dataset);

net.sets.nhidden_per = 40; % with two tasks, more hidden units are needed.
net.sets.eta_w       = 3E-2;    %learning rate (initial)
net.sets.alpha_w     = 0.5;       %momentum

ncc = linspace(0, net.sets.nhidden_per - 2, 5); % assumes cc fibers do not project intra-
delays = [1 5 10 15 20];

% Sample along ncc and delays independently
r_train_and_analyze_all(net, 10, ncc,              delays(ceil(end/2)));
r_train_and_analyze_all(net, 10, ncc(ceil(end/2)), delays);
