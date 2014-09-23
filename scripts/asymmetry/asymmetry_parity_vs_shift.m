clear globals variables;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

net = common_args();
net.sets.dataset     = 'parity_vs_shift';
net.sets.nhidden_per = 20; % with two tasks, more hidden units are needed.
net.sets.dirname     = fullfile(net.sets.dirname, net.sets.dataset);

[nets, pats, datas] = r_looper(net, 1); % run 25 network instances
