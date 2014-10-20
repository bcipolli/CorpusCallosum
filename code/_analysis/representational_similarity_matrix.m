function sim = representational_similarity_matrix(y, net, pats, locs, ptype)
%
% y : activations, in [time] X [patterns] X [units]
% net :
% pats :
% locs :
% ptype : pdist type (correlation, euclidean, etc)
%
%
% sim
%   rh/lh_in : similarity matrix across input patterns
%   rh/lh_out : similarity matrix across output patterns
%   hemi_locs : label of ROIs over which similarities were computed.
%   [loc].patsim : for each timestep, similarity matrix across patterns.
%


    if ~exist('locs', 'var') || isempty(locs)
        switch net.sets.init_type
            case 'ringo', locs = {'input', 'early_hu', 'late_hu', 'output'};
            otherwise, error('Need to specify locations for init_type %s', net.sets.init_type);
        end;
    end;
    if ~exist('ptype', 'var'), ptype = 'correlation'; end;


    % Similarity to inputs
    rh_in =  squeeze(pats.train.P(2,:,pats.idx.rh.in)); % avoid the bias term
    lh_in =  squeeze(pats.train.P(2,:,pats.idx.lh.in));
    rh_out =  squeeze(pats.train.d(1,:,pats.idx.rh.out));
    lh_out =  squeeze(pats.train.d(1,:,pats.idx.lh.out));

    % Input similarity
    sim.rh_in = pdist(rh_in, ptype);
    sim.lh_in = pdist(lh_in, ptype);

    % Output similarity
    sim.rh_out = pdist(rh_out, ptype);
    sim.lh_out = pdist(lh_out, ptype);

    sim.hemi_locs = {};
    for hemi = {'rh', 'lh'}, for loc=locs
        sim.hemi_locs{end+1} = [hemi{1} '_' loc{1}];
    end; end;

    for ti=1:size(y, 1)
        activations = reshape(y(ti, :, :), [size(y, 2) size(y, 3)]);

        for loc = sim.hemi_locs
            loc = loc{1};
            hemi = loc(1:2);

            % Inter-pattern similarity
            if isfield(net.idx, loc) && ~isempty(net.idx.(loc))
                sim.(loc)(ti).patsim = pdist(activations(:, net.idx.(loc)), ptype);
                %non_nan_vals = sim.(loc)(ti).patsim(~isnan(sim.(loc)(ti).patsim));
                %guru_assert(~strcmp(ptype, 'correlation') || all(abs(sim.(loc)(ti).patsim(~isnan(sim.(loc)(ti).patsim))) <= 1));

                % Input similarity
                sim.(loc)(ti).([hemi '_in'])  = sim.(loc)(ti).patsim - sim.([hemi '_in']); %rh_in; %repmat(sim.rh_in, [size(sim.rh_in, 1) 1]);

                % Output similarity
                sim.(loc)(ti).([hemi '_out']) = sim.(loc)(ti).patsim - sim.([hemi '_out']); %repmat(sim.rh_out, [size(sim.rh_out, 1) 1]);
            else
                sim.(loc)(ti).patsim = [];
                sim.(loc)(ti).([hemi '_in']) = [];
                sim.(loc)(ti).([hemi '_out']) = [];
            end;

        end;
    end;
