function [d,nts,noise,delay,folders] = collect_data_looped_tdlc(dirname, cache_file)
% Calls collect_data_looped, then parses out a few key properties.

if ~exist('dirname','var'),    dirname    = 'runs'; end;
if ~exist('cache_file','var'), cache_file = ''; end; % no caching
if ~exist('prefix','var'), prefix='tdlc'; end;

[d,~,folders] = collect_data_looped(dirname, cache_file, prefix);

for foi=1:length(folders)
    
    % Parse out particular properties
    [n] = sscanf(folders{foi},'tdlc2013_all-%dts-%dd');
    nts(foi) = n(1);   % # timesteps
    delay(foi) = n(2); % delay
    noise(foi) = (folders{foi}(end) == 'n'); % whether noisy or not
end;
