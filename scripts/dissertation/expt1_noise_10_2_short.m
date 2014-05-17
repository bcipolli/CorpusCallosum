clear globals variables;
addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));
dbstop if error;

net = dissertation_args_short();   % Noise level contained in args
net.sets.dirname    = fullfile(net.sets.dirname, mfilename);

r_looper(net, 25); % run 25 network instances


