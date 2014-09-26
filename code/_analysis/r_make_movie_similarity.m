function r_make_movie_similarity(nets, pats, sims, simstats, xform, figs)
%
% Input args:
% only one arg: it's the filename.
% two args: a net and a pat.

    if ~iscell(nets), nets = { nets }; end;
        
    if ~exist('xform', 'var'), xform = ''; end;
    if ~exist('figs', 'var'), figs = [1:3]; end;
    
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

    
    
    pat_types = sim.pat_types;
    npattypes = length(pat_types);
    nlocs = length(sim.hemi_locs);
    tsteps = sim.tsteps;
    nsims = length(sim.rh_output(1).patsim);

    % Now that output has been suppressed, print info about the network.
    title_addendum = sprintf('D=%d ncc=%d/%d output_ts=[%d %d]', max(nets{1}.sets.D_CC_LIM(:)), nets{1}.sets.ncc, nets{1}.sets.nhidden_per, round(nets{1}.sets.S_LIM/nets{1}.sets.dt));
    labels = cellfun(@(str) (strrep(str(4:end),  '_', '\_')), sim.hemi_locs(1:end/2), 'UniformOutput', false);


    %% Figure 1: mean difference from output similarity
    if ismember(1, figs)
        f1h = figure('Position', [ 72         -21        1209         794]);
        lbls = {};
        for pti=1:npattypes
            subplot(2, npattypes, pti);
            errorbar(repmat(1:tsteps, [nlocs/2 1])', squeeze(simstats(:, :, pti, 1)), squeeze(simstats(:, :, pti, 2))/sqrt(nsims), 'LineWidth', 2);
            legend(labels);
            
            subplot(2, npattypes, pti+1);
            errorbar(repmat(1:tsteps, [nlocs/2 1])', squeeze(simstats(:, :, pti, 3)), squeeze(simstats(:, :, pti, 4))/sqrt(nsims), 'LineWidth', 2);
            legend(labels);

            title(strrep([title_addendum ' ' pat_types{pti}], '_', '\_'));
            if pti == 1, ylabel('Mean difference of similarity from output.'); end;
            xlabel('time step');
        end;

        %title(['Mean difference from output similarity ' title_addendum]);
        %set(gca, 'ylim', [0 1]);
    end;
    
    
    %% Figure 2: asymmetry in difference from output similarity
    if ismember(2, figs)
        f2h = figure('Position', [ 72         327        1227         446]);
        prop_cc = nets{1}.sets.ncc / nets{1}.sets.nhidden_per;
        ih_idx = find(cellfun(@(x) ~isempty(x), regexp('ih$', labels)))
        cc_idx = find(cellfun(@(x) ~isempty(x), regexp('cc$', labels)))
        for pti=1:npattypes
            data_mean = squeeze(simstats(:, :, pti, 5));
            data_std = squeeze(simstats(:, :, pti, 6));
            cur_labels = labels;

            if length(ih_idx) == 1 && length(cc_idx) == 1
                data_mean(:, end+1) = data_mean(:, [cc_idx ih_idx]) * [prop_cc; 1-prop_cc];
                data_std(:, end+1)  = data_std(:, [cc_idx ih_idx])  * [prop_cc; 1-prop_cc];
                cur_labels = {cur_labels{:} 'ih\_combined'};
            end;

            subplot(1,npattypes,pti);
            errorbar(repmat(1:tsteps, [size(data_mean, 2) 1])', data_mean, data_std/sqrt(nsims), 'LineWidth', 2);
            
            set(gca, 'ylim', [0 1.2]);
            legend(cur_labels);
            title(strrep([title_addendum ' ' pat_types{pti}], '_', '\_'));
            if pti == 1, ylabel('Mean difference between LH and RH similarities.'); end;
            xlabel('time step');
        end;
    end;
    

    %% Figure 3: asymmetry in difference from output similarity
    %f3h = figure('Position', [ 72          23        1229         750]);
    if ismember(33, figs)
        f3h = figure('Position', [ 72         327        1227         446]);
        for pti=1:npattypes
            subplot(1,npattypes,pti); set(gca, 'FontSize', 16);
            plot(repmat(1:tsteps, [nlocs/2 1])', squeeze(simstats(:, :, pti, 5)), 'LineWidth', 2);
            legend(labels, 'Location', 'NorthWest');
            %set(gca, 'ylim', [-0.3 1]);
            title(strrep([title_addendum ' ' pat_types{pti}], '_', '\_'));
            if pti == 1, ylabel('Correlation between LH and RH similarities.'); end;

            %subplot(2,npattypes,pti+npattypes);
            %plot(repmat(1:tsteps, [nlocs/2 1])', squeeze(simstats(:, :, pti, 6)), 'LineWidth', 2);
            %legend(labels);
            %title(strrep([title_addendum ' ' pat_types{pti}], '_', '\_'));
            %if pti == 1, ylabel('Correlation between LH and RH (difference between similarity and output).'); end;
            %xlabel('time step');
        end;
    end;
    

    % Show their time evolution as a movie.
    if ismember(4, figs)
        F = struct('cdata',[],'colormap',[]);
        f = figure('position', [  25           2        1325         782]);

        nlocs = length(sim.hemi_locs)/2;
        nrows = 4;
        ncols = 2 + nlocs;

        for ti=1:tsteps
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
    end;
