% Script for testing a single task (parity) that the hemispheres do in
% parallel.

clear globals variables;
close all;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

net = common_args();
net.sets.dataset = 'parity_dual';
net.sets.dirname = fullfile(net.sets.dirname, net.sets.dataset);
net.sets.train_criterion = 0.50;
net.sets.eta_w = 0.005;
net.sets.phi_w = 0.5;
net.sets.lambda_w = 1E-3;
net.sets.batch_size = 32;

ncc = round(linspace(0, net.sets.nhidden_per, 11)); % try 11 different values
delays = [1 5 10 15 20 25 30 35];
asymmetry_looper(net, 10, ncc, delays);
