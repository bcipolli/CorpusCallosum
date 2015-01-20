% Script for testing a single task (parity) that the hemispheres do in
% parallel.

net = lewis_elman_common_args();
net.sets.dataset     = 'parity_shift';
net.sets.dirname     = fullfile(net.sets.dirname, net.sets.dataset);
net.sets.eta_w = 0.002;
net.sets.phi_w = 0.25;
net.sets.lambda_w = 1E-3;

ncc = round(linspace(0, net.sets.nhidden_per, 6));
delays = [1 5 10 15 20];
Sdur = [1 5 10 15 20 25 30];


% Sample along ncc and delays independently
for si=1:length(Sdur)
    net.sets.S_LIM  = net.sets.tstop -net.sets.dt*(0 + [Sdur(si) 0]);  % min & max time to consider error
    r_asymmetry_looper(net, 10, ncc,              delays(ceil(end/2)));
end;

for si=1:length(Sdur)
    net.sets.S_LIM  = net.sets.tstop -net.sets.dt*(0 + [Sdur(si) 0]);  % min & max time to consider error
    r_asymmetry_looper(net, 10, ncc(ceil(end/2)), delays);
end;
