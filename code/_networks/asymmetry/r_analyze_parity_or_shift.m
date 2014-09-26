function [data] = r_analyze_parity_or_shift(net, pats, data)
%

    [data.sim, data.simstats] = r_compute_similarity(net, pats);