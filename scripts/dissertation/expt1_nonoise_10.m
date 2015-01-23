clear globals variables;
addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));
dbstop if error;

net = dissertation_args();
net.sets.axon_noise = 0;
net.sets.dirname    = fullfile(net.sets.dirname, mfilename);

r_train_many(net, 25); % run 25 network instances


