function [in_pats, out_pats, pat_cls, pat_lbls, idx] = r_pats_parity_shift(sets, opt)
    if ~exist('sets', 'var'), sets = struct(); end;
    if ~exist('opt',  'var'), opt  = {}; end;

    [p_in_pats, p_out_pats, p_pat_cls, p_pat_lbls] = r_pats_parity(sets, opt);
    [s_in_pats, s_out_pats, s_pat_cls, s_pat_lbls] = r_pats_shift(sets, opt);

    p_npats = size(p_in_pats, 1);
    s_npats = size(s_in_pats, 1);
    in_pats = [p_in_pats(:, 1:end/2) s_in_pats(:, (1+end/2):end) ];

    out_pats = [p_out_pats(:, 1:end/2) s_out_pats(:, (1+end/2):end)];

    pat_cls  = [p_pat_cls; s_pat_cls];
    pat_lbls = {p_pat_lbls{:}; s_pat_lbls{:}}';
    idx      = []; % use default symmetric labeling
