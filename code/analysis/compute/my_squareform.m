function mat = my_squareform(dat)
%function mat = my_squareform(dat)
%
% squareform
    sz =  (1 + sqrt(1 + 4*1*2*numel(dat))) / 2;  % quadratic solution for M(M-1)/2 = numel(dat)
    guru_assert(sz == floor(sz), 'sz is an integer.');

    lower =  double(~triu(ones(sz)));
    upper = double(~~triu(ones(sz)) - eye(sz));

    lower(logical(lower)) = dat;
    upper(logical(upper)) = dat;
    mat = lower + upper;
