function [data] = r_analyze_parity_dual(net, pats, data)
%

    [data.sim, data.simstats] = r_compute_similarity(net, pats);