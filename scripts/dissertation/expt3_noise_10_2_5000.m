clear globals variables;
addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));
dbstop if error;

noise_schedule = [linspace(1, 1, 500) linspace(1,0.0,500) 0*linspace(0.1,0.0,4000) ];  % relative schedule of noise.

net = dissertation_args();
net.sets.niters = 5000;  guru_assert(net.sets.niters == length(noise_schedule));
net.sets.axon_noise = net.sets.axon_noise * noise_schedule;
net.sets.dirname    = fullfile(net.sets.dirname, mfilename);

r_looper(net, 25); % run 25 network instances


