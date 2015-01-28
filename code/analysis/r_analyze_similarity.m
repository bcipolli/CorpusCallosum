function [sim, simstats, lagstats] = r_analyze_similarity(net, pats, data)

    % Will propagate data to cell array.
    fprintf('Computing similarity...')
    [sim, simstats, lagstats] = r_compute_similarity(net, pats);
    fprintf(' done.\n');