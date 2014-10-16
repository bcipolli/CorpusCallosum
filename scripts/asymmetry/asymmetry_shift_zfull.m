% Script to test a shared task between the hemispheres across many delays.

clear globals variables;
close all;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

net = common_args();
net.sets.dataset = 'shift';
net.sets.dirname = fullfile(net.sets.dirname, net.sets.dataset);
net.sets.eta_w = 0.005;
net.sets.phi_w = 0.5;
net.sets.lambda_w = 1E-3;

ncc = linspace(0, net.sets.nhidden_per, 6);
delays = [1 5 10 15 20];
asymmetry_looper(net, 10, ncc, delays);

% Draw plots for ncc
for di=1:length(delays)
    asymmetry_looper(net, 10, ncc, delays(di));
    keyboard
end;

for ni=1:length(ncc)
    asymmetry_looper(net, 10, ncc(ni), delays);
end;