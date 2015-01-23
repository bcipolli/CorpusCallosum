clear globals variables;
addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));
dbstop if error;

sets = dissertation_args();

chunk_size = guru_iff(exist('matlabpool','file'), matlabpool('size'), 1);

for rseed=(289-1+[1:chunk_size:25])
  for tsteps=[15:5:50 75]
    for delay=[2 10]
      for noise=[sets.axon_noise*(10/delay) 0] % 1% activation for all delays (baseline is delay=10, multiplicative factor)
          dirname = sprintf('%s-%dts-%dd%s', mfilename(), tsteps, delay,guru_iff(noise>0,'n',''));
          if ~exist(dirname,'dir'), mkdir(dirname); end;

          % Make sure not to reuse networks!
          clear 'net';
          net.sets = sets;

          net.sets.tstart = 0;
          net.sets.tsteps = tsteps  ;%we'll add another hidden layer, so measure output at one step later
          net.sets.tstop  = net.sets.tsteps * net.sets.dt;
          net.sets.I_LIM  = net.sets.tstart+net.sets.dt*(Idel +[0 Idur]); %in terms of time, not steps
          net.sets.S_LIM  = net.sets.tstop -net.sets.dt*(Sdel +[Sdur 0]);  % min & max time to consider error

          net.sets.D_CC_INIT(1,:,:) = delay*[1 1; 1 1];             %early; l->r and r->l
          net.sets.D_CC_INIT(2,:,:) = net.sets.D_CC_INIT(1,:,:); %late;  l->r and r->l

          net.sets.axon_noise       = noise; % constant level of noise

          net.sets.rseed = rseed;
          net.sets.dirname = fullfile(net.sets.dirname, mfilename, dirname);

          r_train_many(net, chunk_size);
      end;
    end;
  end;
end;

  % Make into one giant cache
  cache_dir         = guru_fileparts(fileparts(net.sets.dirname), 'name');
  cache_file        = fullfile(cache_dir, [mfilename '.mat']);
  [~,~,folders] = collect_data_looped_tdlc( cache_dir );

  make_cache_file(folders, cache_file);

