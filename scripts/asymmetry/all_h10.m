clear globals variables;

if ~exist('r_looper','file'), addpath(genpath(fullfile(fileparts(which(mfilename)), '..','..','code'))); end;

if exist('matlabpool','file'), chunk_size = matlabpool('size');
else, chunk_size = 1; end;

for rseed=(289-1+[1:chunk_size:10])
for ncc = [0 15]
for axon_noise = [0]
  for dataset = {'symmetric_symmetric'}

    net = common_args();
    net.sets.dirname     = fullfile(net.sets.dirname, mfilename(), sprintf('%s_%s_n%d', dataset{1}, guru_iff(axon_noise==0, 'nonoise', 'noise'), ncc));

    net.sets.dataset     = dataset{1};
    net.sets.axon_noise  = axon_noise;

    net.sets.ncc         = ncc;
    net.sets.nhidden_per = 10;

    net.sets.rseed = rseed;

    r_looper(net, chunk_size)
end;
end;
end;
end;


  % Make into one giant cache
%  cache_dir     = '~/_cache/ringo/asymmetry/all_h10';
%  cache_file    = fullfile(cache_dir, 'all_h10_cache.mat');
  cache_dir     = guru_fileparts(fileparts(net.sets.dirname), 'name');
  cache_file    = fullfile(cache_dir, [mfilename '_cache.mat']);
  [~,~,folders] = collect_data_looped( cache_dir, '', '' );

  make_cache_file(folders, cache_file);
