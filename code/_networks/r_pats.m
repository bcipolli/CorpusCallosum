function [pats] = r_pats(net)
%
    pats.name         = net.sets.dataset;

    %%%%%%%%%%%%%%%%%%
    % Create patterns
    %%%%%%%%%%%%%%%%%%

    % Directly from the given function
    [train.inpat, train.outpat, pats.cls, pats.lbls, pats.idx] = net.fn.pats(net.sets);
    pats.idx.rh.in = 1:length(pats.idx.rh.in);
    pats.idx.rh.out = pats.idx.rh.in;
    pats.idx.lh.in = pats.idx.rh.in(end) + [1:length(pats.idx.lh.in)];
    pats.idx.lh.out = pats.idx.lh.in;
    
    % Don't set test; use train as test
    test         = train;

    % As autoencoder hidden unit encodings
    if (isfield(net.sets, 'ac'))
        % Run the autoencoder; we'll use it for inputs (rather than the original, "raw" inputs)
        net.ac.sets = net.sets.ac;
        net.ac      = r_massage_params(net.ac);

        % Load the autoencoder from a file
        if (exist(net.ac.sets.matfile,'file') && ~net.ac.sets.force)
            s = load(net.ac.sets.matfile,'net','pats','data');
            [net.ac,pats_ac,data_ac] = deal(s.net,s.pats,s.data);

        % Train the autoencoder!
        else
            [net.ac,pats_ac,data_ac] = r_main(net.ac);
        end;

        % Run the autoencoder encodings
        [~, train.outpat, train.cls, train.lbls] = net.fn.pats(net.sets);
        test = train; warning('Not sure if equating training & test patterns here is OK, but ... will leave it for now.');


        % Now get the encodings from the autoencoder
        [enc_idx,~]                  = find(net.ac.cC(:,[net.ac.idx.output]));
        enc_idx                      = setdiff(unique(enc_idx), 1); %remove bias
        shared_pats                  = ismember(pats_ac.lbls,train.lbls);

        if (length(shared_pats)<size(train.inpat,1))
            error('Fewer autoencoder patterns than desired classifier patterns.  Probably a settings issue...');
        end;

        train.inpat                  = zeros(net.sets.tsteps, sum(shared_pats), 1+length(enc_idx), 'single');
        train.inpat(1,:,:)           = net.sets.bias_val;
        train.inpat(1:end-2,:,2:end) = data_ac.nolesion.y(:,shared_pats,enc_idx); %no input at last time step; doesn't matter, it won't propagate to output

        test.inpat                   = zeros(net.sets.tsteps, sum(shared_pats), 1+length(enc_idx), 'single');
        test.inpat(1,:,:)            = net.sets.bias_val;
        test.inpat(1:end-2,:,2:end)  = data_ac.lesion.y(:,shared_pats,enc_idx); %no input at last time step; doesn't matter, it won't propagate to output

        clear('pats_ac','data_ac');
    end;


    %%%%%%%%%%%%%%%%%%
    % Take the existing data, and massage it into the expected form.
    %%%%%%%%%%%%%%%%%%
    pats.train.tsteps                      = net.sets.tsteps;
    pats.test.tsteps                       = net.sets.tsteps;

    [pats.train.P, pats.idx]               = r_pats_massage_input(net, pats, train.inpat);  rmfield(train,'inpat');
    [pats.test.P]                          = r_pats_massage_input(net, pats, test.inpat);   rmfield(test, 'inpat');

    [pats.train.npat]                      = size(pats.train.P,2);
    [pats.test.npat]                       = size(pats.test.P,2);

    [pats.train.d, pats.train.s, pats.idx] = r_pats_massage_output(net, pats, train.outpat, train.inpat); clear('train');
    [pats.test.d,  pats.test.s]  = r_pats_massage_output(net, pats, test.outpat,  test.inpat);  clear('test');

    [pats.train.gb]                        = find(pats.train.s); %good time & good pattern
    [pats.test.gb]                         = find(pats.test.s);  %good time & good pattern

    if strcmp(net.sets.init_type, 'ringo')%length(net.idx.lh_output) == length(net.idx.output)
        pats.train.gb_rh = pats.train.gb;
        pats.train.gb_lh = pats.train.gb;
        pats.test.gb_rh  = pats.test.gb;
        pats.test.gb_lh  = pats.test.gb;


    else % assume LH output first
        no_perhemi = size(pats.train.s,3)/2;

        rh_s = pats.train.s;
        rh_s(:,:,1:no_perhemi) = 0;
        pats.train.gb_rh = find(rh_s);
        rh_s = pats.test.s;
        rh_s(:,:,1:no_perhemi) = 0;
        pats.test.gb_rh = find(rh_s);

        lh_s = pats.train.s;
        lh_s(:,:,no_perhemi+[1:no_perhemi]) = 0;
        pats.train.gb_lh = find(lh_s);
        lh_s = pats.test.s;
        lh_s(:,:,no_perhemi+[1:no_perhemi]) = 0;
        pats.test.gb_lh = find(lh_s);
    end;

    pats.ninput          = size(pats.train.P,3)-1; %no bias
    pats.noutput         = size(pats.train.d,3);


%%%%%%%%%%%%%%%%%%
function [P, idx] = r_pats_massage_input(net, pats, in_pats)
% Massage the inputs
    idx = pats.idx;  % we'll make changes to the indices.

    % Static patterns, need to duplicate in time
    if (ndims(in_pats) == 2)
            npat   = size(in_pats,1);

            %add bias to input
            in_pats = [net.sets.bias_val*ones(size(in_pats,1),1) in_pats];
            idx.lh.in = idx.lh.in + 1;  % shift indices for inputs.
            idx.rh.in = idx.rh.in + 1;
            
            I_LIM_ti  = round(net.sets.I_LIM/net.sets.dt);
            if (round((net.sets.I_LIM(1)-net.sets.tstart/net.sets.dt))<0), error('programming error on I_LIM / tsteps params'); end;
            if (round((net.sets.I_LIM(2)-net.sets.tstop /net.sets.dt))>0),  error('programming error on I_LIM / tsteps params'); end;

            P = zeros(net.sets.tsteps, npat, size(in_pats,2),  'single');
            P(I_LIM_ti(1)+1 : I_LIM_ti(2), :, :) = repmat(reshape(in_pats,  [1 size(in_pats)]),  [diff(I_LIM_ti) 1 1]);
            P(:,:,1) = net.sets.bias_val; % bias should be ON at all times.

    % Dynamic patterns, just need to shove in properly
    elseif (ndims(in_pats) == 3)
        P = in_pats;
    end;



%%%%%%%%%%%%%%%%%%
function [d, s, idx] = r_pats_massage_output(net, pats, out_pats, in_pats)
% Massage the outputs

    idx = pats.idx;

    % Static patterns, need to duplicate in time
    if (ndims(out_pats)==2)
        % Autoencoder
        if (isfield(net.sets,'autoencoder') && net.sets.autoencoder)
            out_pats = in_pats;
        end;

        % Make RH & LH output the full dealio!
        if (isfield(net.sets,'duplicate_output') && net.sets.duplicate_output)
            out_pats = [out_pats out_pats]; %each hemisphere has a full copy on output
        end;

        d = repmat(reshape(out_pats, [1 size(out_pats)]), [net.sets.tsteps 1 1]);

    % Dynamic patterns, just need to shove in properly
    elseif (ndims(out_pats)==3)
        d = out_pats;
    end;



    npat   = size(out_pats,1);

    S_LIM_ti  = round(net.sets.S_LIM/net.sets.dt);
    if (round((net.sets.S_LIM(1)-net.sets.tstart/net.sets.dt))<0), error('programming error on S_LIM / tsteps params'); end;
    if (round((net.sets.S_LIM(2)-net.sets.tstop /net.sets.dt))>0),  error('programming error on S_LIM / tsteps params'); end;

    s = false(net.sets.tsteps, npat, size(out_pats,2));
    s( S_LIM_ti(1)+1 : S_LIM_ti(2),:,:) = 1;         % "important" times

    % Fix up the indices.
    idx.rh.out = 1:length(idx.rh.out);
    idx.lh.out = idx.rh.out(end) + idx.rh.out;