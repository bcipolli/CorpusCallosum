% Script to test when each hemisphere has a task

clear globals variables;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

net = common_args();
net.sets.dataset     = 'parity_or_shift';
net.sets.nhidden_per = 40; % with two tasks, more hidden units are needed.
net.sets.dirname     = fullfile(net.sets.dirname, net.sets.dataset);

ncc = round(linspace(0, net.sets.nhidden_per, 11)); % try 10 different values
asymmetry_looper(net, 10, ncc);
