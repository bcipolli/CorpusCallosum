function [in_pats, out_pats, pat_cls, pat_lbls, idx] = r_pats_parity_dual(sets, opt)
% Parity bit: http://en.wikipedia.org/wiki/Parity_bit

    if ~exist('opt','var'), opt = ''; end;

    npats = 32;
    
    all_pats = double(dec2bin([1:2^5] - 1) - '0');
    all_pats = all_pats(randperm(size(all_pats, 1)), :);  % shuffle rows
    nbits = sum(all_pats, 2)';
    
    even_num_bits = find(mod(nbits, 2) == 0, npats/4)';
    odd_num_bits  = find(mod(nbits, 2) == 1, npats/4)';
    
    inpats = [ all_pats(even_num_bits,:) all_pats(even_num_bits,:)
               all_pats(even_num_bits,:) all_pats(odd_num_bits,:)
               all_pats(odd_num_bits,:)  all_pats(even_num_bits,:)
               all_pats(odd_num_bits,:)  all_pats(odd_num_bits,:) ];
    outpats = mod(sum(inpats, 2), 2); % is the number of bits odd?
    outpats = [outpats 1-outpats outpats 1-outpats outpats]; %repmat(outpats, [1 5]); % duplicate 5 times

    % Split into input/output, revalue to -1 1
    in_pats  = -1+2*inpats;  % left and right symmetry
    out_pats = -1+2*[outpats outpats]; % left and right symmetry

    % Label patterns
    pat_lbls = cellfun(@(a,b) sprintf('%d => %d', a, b), num2cell(bin2dec(char(inpats + '0'))), num2cell(bin2dec(char(outpats(:,1) + '0'))), 'UniformOutput', false);
    [~,~,pat_cls] = unique(pat_lbls);
    pat_cls       = unique(pat_cls);

    idx = []; % use default calculation for symmetric input/outputs
