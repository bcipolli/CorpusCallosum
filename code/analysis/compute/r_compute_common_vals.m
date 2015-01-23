function vals = compute_common_vals(nets, sims, unique_values)
    if ~exist('unique_values', 'var')
        unique_values = true;
    end;

    good_idx = find(cellfun(@(c) ~isempty(c), nets));

    if ~any(good_idx)
        vals = [];
        return;
    end;

    sim = sims{good_idx(1)}{1};
    net = nets{good_idx(1)}{1};

    vals.pat_types = sim.pat_types;
    vals.npattypes = length(vals.pat_types);

    % Only do one hemi (not rh/lh separately)
    vals.locs      = cellfun(@(loc) loc(4:end), sim.hemi_locs(1:end/2), 'UniformOutput', false);
    vals.nlocs     = length(vals.locs);
    vals.tsteps    = sim.tsteps;
    vals.nsims     = length(sim.rh_output(1).patsim);

    vals.ncc    = cellfun(@(nets) getSet(nets, 'ncc'),           nets);
    vals.delays = cellfun(@(nets) max(getSet(nets, 'D_CC_LIM')), nets);
    vals.Ts     = cellfun(@(nets) max(getSet(nets, 'T_LIM')),    nets);

    if unique_values
        vals.ncc = unique(vals.ncc(:));
        vals.delays = unique(vals.delays(:));
        vals.Ts = unique(vals.Ts(:));
    end;

    vals.max_iters = net.sets.niters;


function val = getSet(nets, set)
    if isempty(nets)
        val = NaN;
    else
        val = nets{1}.sets.(set);
        val = val(:);
    end;