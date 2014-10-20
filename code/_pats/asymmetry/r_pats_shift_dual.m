function [in_pats, out_pats, pat_cls, pat_lbls, idx] = r_pats_shift_dual(sets, opt)
% Shift, but shifting the *other* side.  Each pattern should have two possible outputs as well,
%   to match r_pats_parity_dual

    if ~exist('opt','var'), opt = ''; end;

    npats = 32;

    all_pats = double(dec2bin([1:2^5] - 1) - '0');
    %all_pats = all_pats(randperm(size(all_pats, 1)), :);  % shuffle rows

%    some_pats = all_pats(1:16,:);
%    other_pats = all_pats(17:end, :);

    ridx_one = randperm(size(all_pats, 1));
    ridx_two = randperm(size(all_pats, 1));

    inpats = [all_pats(ridx_one, :) all_pats(ridx_two, :)];
    outpats = [all_pats(ridx_two, :) all_pats(ridx_one, :)];

    % Split into input/output, revalue to -1 1
    in_pats  = -1+2*inpats;  % left and right symmetry
    out_pats = -1+2*outpats; % left and right symmetry

    % Label patterns
    pat_lbls = cellfun(@(a,b) sprintf('%d => %d', a, b), num2cell(bin2dec(char(inpats + '0'))), num2cell(bin2dec(char(outpats(:,1) + '0'))), 'UniformOutput', false);
    [~,~,pat_cls] = unique(pat_lbls);
    pat_cls       = unique(pat_cls);

    idx = []; % use default calculation for symmetric input/outputs
