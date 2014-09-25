clear globals variables;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

net = common_args();
net.sets.dataset     = 'parity_or_shift';
net.sets.nhidden_per = 40; % with two tasks, more hidden units are needed.
net.sets.dirname     = fullfile(net.sets.dirname, net.sets.dataset);

for ncc = round(linspace(0, net.sets.nhidden_per, 11)) % try 10 different values
    net.sets.ncc = ncc;
    [nets, pats, datas] = r_looper(net, 10); % run 25 network instances
    [abc, def] = r_compute_similarity(nets, pats);
    r_make_movie_similarity(nets, pats, abc, def, '', [2])
end;
