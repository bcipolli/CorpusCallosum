function vals = compute_common_vals(nets, sims, unique_values)
    if ~exist('unique_values', 'var'), unique_values = true; end;

    good_idx = find(cellfun(@(c) ~isempty(c), nets));

    if ~any(good_idx)
        vals = [];
        return;
    end;

    vals = struct();
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

    % Documentation & filtering; the ordering is a centralized assumption
    %   that is implemented in r_train_many
    %
    % NOTE that these will be filtered below.
    vals.dims.ids = {'ncc', 'delays', 'Ts'};
    vals.dims.names = {'# Connections', 'Delay', 'Time Constant'};

    % Which dimensions were varied?
    dim_idx = cellfun( @(dim) length(unique(vals.(dim))) > 1, vals.dims.ids);
    vals.dims.nvaried = sum(dim_idx);
    %guru_assert(vals.dims.nvaried > 0, 'SOME simulations should remain!');

    vals.dims.ids = vals.dims.ids(dim_idx);
    vals.dims.names = vals.dims.names(dim_idx);



function val = getSet(nets, set)
    if isempty(nets)
        val = NaN;
    else
        val = nets{1}.sets.(set);
        val = val(:);
    end;