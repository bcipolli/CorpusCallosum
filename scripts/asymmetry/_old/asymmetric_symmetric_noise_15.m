clear globals variables;
addpath(genpath(fullfile('..', '..', '..', '..', 'lib')));
addpath(genpath(fullfile('..', '..', '..', 'code')));

net = common_args();

net.sets.dataset     = 'asymmetric_symmetric';
net.sets.axon_noise  = 1E-3;
net.sets.ncc         = 3;
net.sets.nhidden_per = 15;

looper(net);

