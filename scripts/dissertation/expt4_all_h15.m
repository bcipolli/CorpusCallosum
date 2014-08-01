clear globals variables;
matlabpool open 4
if ~exist('r_looper','file'), addpath(genpath(fullfile(fileparts(which(mfilename)), '..','..','code'))); end;
if ~exist('matlabpool','file'), chunk_size = 1; else chunk_size = max(1,matlabpool('size')); end;

parfor rseed=(289-1+[1:25])%chunk_size:25])
for axon_noise = [0 NaN]  % NaN means set to existing level
for dataset = {'asymmetric_symmetric', 'asymmetric_asymmetric', 'symmetric_asymmetric', 'symmetric_symmetric'}

    net = dissertation_args();

    net.sets.dataset     = dataset{1};
    net.sets.axon_noise  = guru_iff(~isnan(axon_noise), axon_noise, net.sets.axon_noise);
    net.sets.rseed       = rseed;

    resname             = sprintf('%s_%s_n%d', dataset{1}, guru_iff(axon_noise==0, 'nonoise', 'noise'), net.sets.ncc);
    net.sets.dirname    = fullfile(net.sets.dirname, mfilename, resname);

    r_looper(net, chunk_size)
end;
end;
end;

% Make into one giant cache
cache_dir     = guru_fileparts(net.sets.dirname, 'dir');
cache_file    = fullfile(cache_dir, [mfilename '_cache.mat']);
[~,~,folders] = collect_data_looped( cache_dir, '', '' );

make_cache_file(folders, cache_file);
