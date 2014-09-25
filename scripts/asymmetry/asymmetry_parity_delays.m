clear globals variables;
close all;
addpath(genpath('code'));
dbstop if error;
%dbstop if warning;

net = common_args();
net.sets.dataset = 'parity';
net.sets.dirname = fullfile(net.sets.dirname, net.sets.dataset);


for ncc = net.sets.nhidden_per/2;%round(linspace(0, net.sets.nhidden_per, 11)) % try 10 different values
    net.sets.ncc = ncc;
    delays = [1 5 10 15 20 25 30 35];
    for del = delays(end:-1:1)
        net.sets.D_CC_INIT(:,:,:) = del;
        
        [nets, pats, datas] = r_looper(net, 10); % run 25 network instances
        [abc, def] = r_compute_similarity(nets, pats);
        r_make_movie_similarity(nets, pats, abc, def, '', [1 2])
    end;
end;