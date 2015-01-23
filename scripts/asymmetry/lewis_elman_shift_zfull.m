% Script to test the shift task between the hemispheres, across the full matrix of delays x ncc.
%

net = lewis_elman_common_args();
net.sets.dataset = 'shift';
net.sets.dirname = fullfile(net.sets.dirname, net.sets.dataset);
net.sets.eta_w = 0.005;
net.sets.phi_w = 0.5;
net.sets.lambda_w = 1E-3;

ncc = linspace(0, net.sets.nhidden_per, 6);
delays = [1 5 10 15 20];
r_train_and_analyze_all(net, 10, ncc, delays);

% Draw plots for ncc
for di=1:length(delays)
    r_train_and_analyze_all(net, 10, ncc, delays(di));
end;

for ni=1:length(ncc)
    r_train_and_analyze_all(net, 10, ncc(ni), delays);
end;
