% Script to test when LH and RH always do the opposite task of the other.

clear globals variables;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

net = common_args();
net.sets.dataset     = 'parity_and_shift';
net.sets.dirname     = fullfile(net.sets.dirname, net.sets.dataset);

net.sets.nhidden_per = 40; % with two tasks, more hidden units are needed.
net.sets.eta_w       = 3E-2;    %learning rate (initial)
net.sets.alpha_w     = 0.5;       %momentum

ncc = round(linspace(0, net.sets.nhidden_per, 11)); % try 11 different values
asymmetry_looper(net, 10, ncc);
