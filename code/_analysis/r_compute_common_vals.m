function vals = compute_common_vals(nets, sims)

    sim = sims{1}{1};

    vals.pat_types = sim.pat_types;
    vals.npattypes = length(vals.pat_types);

    % Only do one hemi (not rh/lh separately)
    vals.locs      = cellfun(@(loc) loc(4:end), sim.hemi_locs(1:end/2), 'UniformOutput', false);
    vals.nlocs     = length(vals.locs);
    vals.tsteps    = sim.tsteps;
    vals.nsims     = length(sim.rh_output(1).patsim);

    vals.ncc    = cellfun(@(nets) getSet(nets, 'ncc'),                nets(:,1,1));
    vals.delays = cellfun(@(nets) max(max(max(getSet(nets, 'D_CC_LIM')))), nets(1,:,1));
    vals.Ts     = cellfun(@(nets) max(max(getSet(nets, 'T_LIM'))),    nets(:,1,1));



function val = getSet(nets, set)
    if isempty(nets)
        val = NaN;
    else
        val = nets{1}.sets.(set);
    end;