% Script to test a shared task between the hemispheres across many delays.

clear globals variables;
close all;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

net = common_args();
net.sets.dataset = 'parity';
net.sets.dirname = fullfile(net.sets.dirname, net.sets.dataset);


ncc = net.sets.nhidden_per/2;
delays = [1 5 10 15 20];
asymmetry_looper(net, 10, ncc, delays);
