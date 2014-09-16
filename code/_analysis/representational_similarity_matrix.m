function sim = representational_similarity_matrix(y, net, pats, locs, ptype)
%
% y : activations, in [time] X [patterns] X [units]
% pat_idx : pattern indices

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

            % Inter-pattern similarity
            if isfield(net.idx, loc{1}) && ~isempty(net.idx.(loc{1}))
                sim.(loc{1})(ti).patsim = pdist(activations(:, net.idx.(loc{1})), 'correlation');
            else
                sim.(loc{1})(ti).patsim = [];
            end;
            % Input similarity
            %sim.(loc{1})(ti).([hemi{1} '_in']) = sim.(hemi_loc)(ti).patsim - repmat(cdata.rh_out_sim, [size(cdata_rh, 1) 1]);

            % Output similarity
            %sim.(loc{1})(ti).([hemi{1} '_out']) = pdist(sim.([hemi{1} '_out']), 'correlation');
        end;
    end;
