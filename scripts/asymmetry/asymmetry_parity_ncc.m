% Script to test a shared task between the hemispheres across many delays.

clear globals variables;
close all;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

net = common_args();
net.sets.dataset = 'parity';
net.sets.dirname = fullfile(net.sets.dirname, net.sets.dataset);

net.sets.eta_w = 0.005;
net.sets.phi_w = 0.5;
net.sets.lambda_w = 1E-3;

ncc = linspace(0, net.sets.nhidden_per, 11); %net.sets.nhidden_per/2;
delays = 10;%   [1 5 10 15 20 25 30 35];
asymmetry_looper(net, 10, ncc, delays);
