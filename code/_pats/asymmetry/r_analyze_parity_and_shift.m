function [data] = r_analyze_parity_and_shift(net, pats, data)
%

    [data.sim, data.simstats] = r_compute_similarity(net, pats);