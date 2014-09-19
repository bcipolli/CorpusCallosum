function [in_pats, out_pats, pat_cls, pat_lbls, idx] = r_pats_parity(sets, opt)
% Parity bit: http://en.wikipedia.org/wiki/Parity_bit

    if ~exist('opt','var'), opt = ''; end;

    inpats = 0:31;
    inpats = dec2bin(inpats) - '0'; % convert to binary
    outpats = mod(sum(inpats, 2), 2); % is the number of bits odd?
    outpats = repmat(outpats, [1 5]); % duplicate 5 times

    % Split into input/output, revalue to -1 1
    in_pats  = -1+2*[inpats inpats];  % left and right symmetry
    out_pats = -1+2*[outpats outpats]; % left and right symmetry

    % Label patterns
    pat_lbls = cellfun(@(a,b) sprintf('%d => %d', a, b), num2cell(bin2dec(char(inpats + '0'))), num2cell(bin2dec(char(outpats(:,1) + '0'))), 'UniformOutput', false);
    [~,~,pat_cls] = unique(pat_lbls);
    pat_cls       = unique(pat_cls);

    idx = []; % use default calculation for symmetric input/outputs
