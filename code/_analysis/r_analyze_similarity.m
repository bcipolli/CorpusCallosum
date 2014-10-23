function r_analyze_similarity(nets, sim, simstats, figs)


    if ~iscell(nets), nets = { nets }; end;
    if isempty(sim), return; end;
    if iscell(sim),   sim  = sim{1}; end;
    if ~exist('xform', 'var'), xform = ''; end;
    if ~exist('figs', 'var'), figs = [1:3]; end;

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
        ih_idx = find(cellfun(@(x) ~isempty(x), regexp('ih$', labels)));
        cc_idx = find(cellfun(@(x) ~isempty(x), regexp('cc$', labels)));
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