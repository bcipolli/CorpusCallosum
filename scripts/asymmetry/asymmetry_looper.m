function [nets, pats, datas, figs] = asymmetry_looper(net, nexamples, nccs, delays, Ts)

if ~exist('nexamples', 'var'), nexamples = 10; end;
if ~exist('nccs', 'var'), nccs = [net.sets.ncc]; end;
if ~exist('delays', 'var'), delays = unique(net.sets.D_CC_INIT); end;
if ~exist('Ts', 'var'), Ts = unique(net.sets.T_INIT) / net.sets.dt; end;


nets = cell(length(nccs), length(delays), length(Ts)); 
datas = cell(size(nets));
for ni = 1:length(nccs), for di=1:length(delays), for ti=1:length(Ts)
    % set params
    net.sets.ncc = nccs(ni);
    net.sets.D_CC_INIT(:) = delays(di);
    net.sets.T_INIT(:) = Ts(ti) * net.sets.dt;
    net.sets.T_LIM(:) = Ts(ti) * net.sets.dt;

    net.sets

    % Train the network
    [nets{ni, di, ti}, pats, datas{ni, di, ti}] = r_looper(net, nexamples); % run 25 network instances
    
    % Gather any missing data
    if ~isfield(datas{ni, di, ti}, 'an') || ~isfield(datas{ni, di, ti}.an, 'sim')
        [datas{ni, di, ti}.an.sim, ...
         datas{ni, di, ti}.an.simstats] = r_compute_similarity(nets{ni, di, ti}, pats);
    end;
    
    % Plot results
    r_make_movie_similarity(nets{ni, di, ti}, ...
        pats, ...
        datas{ni, di, ti}.an.sim, ...
        datas{ni, di, ti}.an.simstats, ...
        '', ...
        [1 2]);
end; end; end;
