% Each hemisphere gets the same inputs, but performs a different task.
% Each hemisphere learns both tasks.
%
% So, this is like asymmetry_parity_shift, but both sides learn both tasks, and know what to expect from the other.
%
% A good comparison is to asymmetry_parity_or_shift (where each learns one task without knowing what the other side will do)
%   and asymmetry_parity_shift (where the same relationship holds here, but each hemi learns just one task)

net = ringo_common_args();
net.sets.dataset = 'parity_vs_shift';
net.sets.nhidden_per = 20; % with two tasks, more hidden units are needed.
net.sets.dirname = fullfile(net.sets.dirname, net.sets.dataset);
net.sets.eta_w = 0.002;
net.sets.phi_w = 0.25;
net.sets.lambda_w = 1E-3;

ncc = linspace(0, net.sets.nhidden_per - 2, 5); % assumes cc fibers do not project intra-
delays = [1 5 10 15 20];

% Sample along ncc and delays independently
r_asymmetry_looper(net, 10, ncc,              delays(ceil(end/2)));
r_asymmetry_looper(net, 10, ncc(ceil(end/2)), delays);
