function r_make_movie_similarity(varargin)
%
% Input args:
% only one arg: it's the filename.
% two args: a net and a pat.



    switch length(varargin)
        case 1
            load(varargin{1});
        case 2
            net = varargin{1};
            pats = varargin{2};

        otherwise
            error(sprintf('Unexpected number of input arguments.\n%s', help(mfilename)));
    end;

%% Show a similarity matrix movie.
%load('random_t35_d10_r290_188665419.mat');

% Set some analysis variables to assist, based on 
switch net.sets.init_type
    case 'ringo',       locs = {'input', 'early_cc', 'early_ih', 'late_cc', 'late_ih','output'};
    case 'lewis_elman', locs = {'input', 'cc', 'ih','output'};
    otherwise, error('Unknown init_type: ''%s''', net.sets.init_type);
end;

switch net.sets.dataset
    case {'lewis_elman'}, pat_types = {'inter', 'intra'};
    otherwise, pat_types = {};
end;


pat_types = {'all', pat_types{:}};

% Do the forward pass
y = getfield(r_forwardpass(net, pats.test), 'y');

% Compute the similarity matrices
sim = representational_similarity_matrix(y, net, pats, locs, 'correlation');

% Now that output has been suppressed, print info about the network.
title_addendum = sprintf('D=%d ncc=%d/%d output_ts=[%d %d]', max(net.sets.D_CC_LIM(:)), net.sets.ncc, net.sets.nhidden_per, round(net.sets.S_LIM/net.sets.dt));

% For each timestep and location, compute similarities.
tsteps = size(y, 1);
nlocs = length(sim.hemi_locs);
nsims = length(sim.rh_output(1).patsim);
npattypes = length(pat_types);
npats = pats.train.npat;

% Just collect into matrix
patsims = zeros(tsteps, nlocs, nsims);
for ti=1:tsteps
    for li = 1:nlocs
        patsim = sim.(sim.hemi_locs{li})(ti).patsim;
        if isempty(patsim)
            patsims(ti, li, :) = NaN;
        else
            patsims(ti, li, :) = patsim;
        end;
    end;
end;

% Now compare across the hemispheres
simstats = zeros(tsteps, nlocs/2, npattypes+1, 5); % diff_mean, diff_std, asymm_mean, asymm_std
for ti=1:tsteps
    for li=2:nlocs / 2  % #1 is input... cheating :)
        for pti=1:npattypes  % inter, intra
            loc = sim.hemi_locs{li}(4:end);
            rh_idx = strcmp(sim.hemi_locs, ['rh_' loc]);
            lh_idx = strcmp(sim.hemi_locs, ['lh_' loc]);

            rh_sim = reshape(patsims(ti, rh_idx, :), [1 nsims]);
            lh_sim = reshape(patsims(ti, lh_idx, :), [1 nsims]);
            rh_simdiff = (rh_sim - sim.rh_out);
            lh_simdiff = (lh_sim - sim.lh_out);

            patsim_hemimean  = ( rh_simdiff + lh_simdiff ) / 2;
            patsim_asymmetry = (rh_simdiff - lh_simdiff);% ./ patsim_hemimean;
            
            switch pat_types{pti}
                case 'all', idx = 1:npats;
                otherwise,  idx = pats.idx.(pat_types{pti});
            end;            
            lower_diag_inpat = ones(npats) - eye(npats);
            lower_diag_inpat(idx, idx) = lower_diag_inpat(idx, idx) + 1;
            lower_diag_inpat = double(lower_diag_inpat > 1);
            pattype_idx = squareform(lower_diag_inpat) > 0;  % logical index

            if ~all(isnan(rh_simdiff))
                sim_corr     = corr(rh_sim(~isnan(rh_sim) & pattype_idx)', lh_sim(~isnan(lh_sim) & pattype_idx)');
                simdiff_corr = corr(rh_simdiff(~isnan(rh_simdiff) & pattype_idx)', lh_simdiff(~isnan(lh_simdiff) & pattype_idx)');
            else
                sim_corr = NaN;
                simdiff_corr = NaN;
            end;
            
            simstats(ti, li, pti, 1) = nanmean(abs(patsim_hemimean(pattype_idx)));
            simstats(ti, li, pti, 2) = nanstd(abs(patsim_hemimean(pattype_idx)));
            simstats(ti, li, pti, 3) = nanmean(abs(patsim_asymmetry(pattype_idx)));
            simstats(ti, li, pti, 4) = nanstd(abs(patsim_asymmetry(pattype_idx)));
            simstats(ti, li, pti, 5) = sim_corr;
            simstats(ti, li, pti, 6) = simdiff_corr;
        end;
    end;
end;

labels = cellfun(@(str) (strrep(str(4:end),  '_', '\_')), sim.hemi_locs(1:end/2), 'UniformOutput', false);

%% Figure 1: mean difference from output similarity
f1h = figure('Position', [ 72         327        1227         446]);
lbls = {};
for pti=1:npattypes
    subplot(1,npattypes,pti);
    errorbar(repmat(1:tsteps, [nlocs/2 1])', squeeze(simstats(:, :, pti, 1)), squeeze(simstats(:, :, pti, 2))/sqrt(nsims), 'LineWidth', 2);
    legend(labels);
    title(strrep([title_addendum ' ' pat_types{pti}], '_', '\_'));
    if pti == 1, ylabel('Mean difference of similarity from output.'); end;
    xlabel('time step');
end;

%title(['Mean difference from output similarity ' title_addendum]);
%set(gca, 'ylim', [0 1]);

%% Figure 2: asymmetry in difference from output similarity
f2h = figure('Position', [ 72         327        1227         446]);
for pti=1:npattypes
    subplot(1,npattypes,pti);
    errorbar(repmat(1:tsteps, [nlocs/2 1])', squeeze(simstats(:, :, pti, 3)), squeeze(simstats(:, :, pti, 4))/sqrt(nsims), 'LineWidth', 2);
    legend(labels);
    title(strrep([title_addendum ' ' pat_types{pti}], '_', '\_'));
    if pti == 1, ylabel('Mean difference between LH and RH similarities.'); end;
    xlabel('time step');
end;


%% Figure 3: asymmetry in difference from output similarity
%f3h = figure('Position', [ 72          23        1229         750]);
f3h = figure('Position', [ 72         327        1227         446]);
for pti=1:npattypes
    subplot(1,npattypes,pti); set(gca, 'FontSize', 16);
    plot(repmat(1:tsteps, [nlocs/2 1])', squeeze(simstats(:, :, pti, 5)), 'LineWidth', 2);
    legend(labels, 'Location', 'NorthWest');
    set(gca, 'ylim', [-0.3 1]);
    title(strrep([title_addendum ' ' pat_types{pti}], '_', '\_'));
    if pti == 1, ylabel('Correlation between LH and RH similarities.'); end;

    %subplot(2,npattypes,pti+npattypes);
    %plot(repmat(1:tsteps, [nlocs/2 1])', squeeze(simstats(:, :, pti, 6)), 'LineWidth', 2);
    %legend(labels);
    %title(strrep([title_addendum ' ' pat_types{pti}], '_', '\_'));
    %if pti == 1, ylabel('Correlation between LH and RH (difference between similarity and output).'); end;
    %xlabel('time step');
end;

%return;

% Show their time evolution as a movie.
F = struct('cdata',[],'colormap',[]);
f = figure('position', [ 80   275   999   509]);
for ti=1:size(y, 1)
    % Row 1: RH; Row 2: LH
    for li = 1:length(sim.hemi_locs)
        figure(f);
        subplot(4, length(sim.hemi_locs)/2, li);
        patsim = sim.(sim.hemi_locs{li})(ti).patsim;
        if isempty(patsim), continue; end;
        
        diff_from_output = patsim - sim.([sim.hemi_locs{li}(1:2) '_out']);
        if ~isempty(patsim)
            imagesc(squareform(abs(1 - abs(diff_from_output))), [0 1]);
        end;
        axis square;
        set(gca, 'xtick', [], 'ytick', []);
        title(strrep(sim.hemi_locs{li}, '_', '\_'));
    end;
    
    % Row 3: average.
    for si=1:length(sim.hemi_locs)/2
        figure(f);
        subplot(4, length(sim.hemi_locs)/2, li+si);
        loc = sim.hemi_locs{si}(4:end);
        patsim = (sim.(['rh_' loc])(ti).patsim + sim.(['lh_' loc])(ti).patsim) / 2;
        if isempty(patsim), continue; end;
        
        diff_from_output = patsim - sim.([sim.hemi_locs{li}(1:2) '_out']);
        if ~isempty(patsim)
            imagesc(squareform(abs(1 - abs(diff_from_output))), [0 1]);
        end;
        axis square;
        set(gca, 'xtick', [], 'ytick', []);
        title(sprintf('LH/RH average: %.2f, %.2f', nanmean(diff_from_output), nanstd(diff_from_output))); %mean(diff_from_output)
    end;
    
    % Row 4: asymmetry
    for ai=1:length(sim.hemi_locs)/2
        figure(f);
        subplot(4, length(sim.hemi_locs)/2, li+si+ai);
        loc = sim.hemi_locs{ai}(4:end);
        patsim = (sim.(['rh_' loc])(ti).patsim - sim.(['lh_' loc])(ti).patsim);
        if ~isempty(patsim)
            imagesc(squareform(patsim), [-2 2]);
        end;
        if any(abs(patsim) > 2), keyboard; end;
        
        axis square;
        set(gca, 'xtick', [], 'ytick', []);
        title(sprintf('asymmetry: %.2f, %.2f', mean(patsim), std(patsim)));
    end;
    

    figure(f);
    drawnow;
    pause(0.25);
    F(ti) = getframe;
end;


% Now, plot interesting quantities
