function r_make_movie_similarity(nets, pats, sims, xform)
%
% Input args:
% only one arg: it's the filename.
% two args: a net and a pat.

    if ~iscell(nets), nets = { nets }; end;

    if ~exist('xform', 'var'), xform = ''; end;

    if ~exist('sims', 'var') || isempty(sims)
        fprintf('Computing similarity across time steps...');
        [sim, simstats] = r_compute_similarity(nets, pats, 'correlation');
        sim = sim{1};

        % Apply the transform
        switch xform
            case '', ;
            otherwise, error('Unknown xform: %s', xform);
        end;
        fprintf('\n');
    else
        sim = sims{1};
    end;


    % Show their time evolution as a movie.
    F = struct('cdata',[],'colormap',[]);
    f = figure('position', [  25           2        1325         782]);

    nlocs = length(sim.hemi_locs)/2;
    nrows = 4;
    ncols = 2 + nlocs;

    for ti=1:sim.tsteps
        spi = 0;  % subplot index

        % Row 1: RH; Row 2: LH
        for hi=1:2
            hemi = guru_iff(hi == 1, 'lh', 'rh');
            for hli = 0:(nlocs + 1)
                li = (hi-1)*nlocs + hli;

                spi = spi + 1;
                figure(f); subplot(nrows, ncols, spi);

                if hli==0   % input
                    if ti > 1, continue; end;
                    patsim = sim.([hemi '_in']);
                    strtit = 'input';

                elseif hli == nlocs + 1  % output
                    if ti > 1, continue; end;
                    patsim = sim.([hemi '_out']);
                    strtit = 'output';

                else
                    patsim = sim.(sim.hemi_locs{li})(ti).patsim;
                    if isempty(patsim), continue; end;

                    %patsim = patsim - sim.([hemi '_out']);
                    %patsim = abs(1 - abs(patsim));
                    strtit = sim.hemi_locs{li};
                end;

                if ~isempty(patsim)
                    imagesc(squareform(patsim), [-2 2]);
                end;
                axis square;
                set(gca, 'xtick', [], 'ytick', []);
                title(strrep(strtit, '_', '\_'));
            end;
        end;

        % Row 3: average.
        for si=1:0:(nlocs+1)
            spi = spi + 1;
            figure(f); subplot(nrows, ncols, spi);

            if si==0
            elseif si==nlocs+1
            else
                loc = sim.hemi_locs{si}(4:end);
                hemi = sim.hemi_locs{si}(1:2);
                patsim = (sim.(['rh_' loc])(ti).patsim + sim.(['lh_' loc])(ti).patsim) / 2;
                if isempty(patsim), continue; end;

                diff_from_output = patsim - sim.([hemi '_out']);
                if ~isempty(patsim)
                    imagesc(squareform(patsim), [-2 2]);%abs(1 - abs(diff_from_output))), [0 1]);
                end;
                axis square;
                set(gca, 'xtick', [], 'ytick', []);
                title(sprintf('LH/RH average: %.2f, %.2f', nanmean(abs(diff_from_output)), nanstd(abs(diff_from_output)))); %mean(diff_from_output)
            end;
        end;


        % Row 4: asymmetry
        for ai=0:(nlocs+1)
            spi = spi + 1;
            figure(f); subplot(nrows, ncols, spi);

            if ai==0
            elseif ai==nlocs+1
            else
                loc = sim.hemi_locs{ai}(4:end);
                patsim = (sim.(['rh_' loc])(ti).patsim - sim.(['lh_' loc])(ti).patsim);
                if ~isempty(patsim)
                    imagesc(squareform(patsim), [-2 2]);
                end;
                if any(abs(patsim) > 2), keyboard; end;

                axis square;
                set(gca, 'xtick', [], 'ytick', []);
                title(sprintf('asymmetry: %.2f, %.2f', mean(abs(patsim)), std(abs(patsim))));
            end;
        end;


        figure(f);
        drawnow;
        pause(0.25);
        F(ti) = getframe;
    end;
