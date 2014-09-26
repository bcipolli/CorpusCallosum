% Script to test when LH and RH have one task each that differs.

clear globals variables;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

net = common_args();
net.sets.dataset     = 'parity_shift';
net.sets.dirname     = fullfile(net.sets.dirname, net.sets.dataset);

ncc = round(linspace(0, net.sets.nhidden_per, 11)); % try 10 different values
asymmetry_looper(net, 10, ncc);
