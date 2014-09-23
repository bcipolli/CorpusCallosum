clear globals variables;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

net = common_args();
net.sets.dataset = 'shift';
net.sets.dirname = fullfile(net.sets.dirname, net.sets.dataset);

[nets, pats, datas] = r_looper(net, 1); % run 25 network instances
