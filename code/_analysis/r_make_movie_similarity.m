

%% Show a similarity matrix movie.
%load('random_t35_d10_r290_188665419.mat');

% Do the forward pass
y = getfield(r_forwardpass(net, pats.test), 'y');

% Compute the similarity matrices
switch net.sets.init_type
    case 'ringo', locs = {'input', 'early_cc', 'early_ih', 'late_cc', 'late_ih','output'};
    case 'lewis_elman', locs = {'input', 'cc', 'ih','output'};
    otherwise, error('Unknown init_type: ''%s''', net.sets.init_type);
end;

sim = representational_similarity_matrix(y, net, pats, locs, 'correlation');

% For each timestep and location, compute similarities.
tsteps = size(y, 1);
nlocs = length(sim.hemi_locs);
nsims = length(sim.rh_output(1).patsim);

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
simstats = zeros(tsteps, nlocs/2, 4); % diff_mean, diff_std, asymm_mean, asymm_std
for ti=1:tsteps
    for li=2:nlocs / 2
        loc = sim.hemi_locs{li}(4:end);
        rh_idx = find(strcmp(sim.hemi_locs, ['rh_' loc]));
        lh_idx = find(strcmp(sim.hemi_locs, ['lh_' loc]));

        rh_simdiff = (reshape(patsims(ti, rh_idx, :), [1 nsims]) - sim.rh_out);
        lh_simdiff = (reshape(patsims(ti, lh_idx, :), [1 nsims]) - sim.lh_out);
        
        patsim_hemimean  = ( rh_simdiff + lh_simdiff ) / 2;
        patsim_asymmetry = (rh_simdiff - lh_simdiff);% ./ patsim_hemimean;
        
            
        simstats(ti, li, 1) = nanmean(abs(patsim_hemimean));
        simstats(ti, li, 2) = nanstd(abs(patsim_hemimean));
        simstats(ti, li, 3) = nanmean(patsim_asymmetry);
        simstats(ti, li, 4) = nanstd(patsim_asymmetry);
    end;
end;

labels = cellfun(@(str) (strrep(str(4:end),  '_', '\_')), sim.hemi_locs(1:end/2), 'UniformOutput', false);
title_addendum = sprintf('(ts=%d, ncc=%d, delay=%d)', tsteps, net.ncc, max(net.D(:)));

%% Figure 1: mean difference from output similarity
f1h = figure;
errorbar(repmat(1:tsteps, [nlocs/2 1])', squeeze(simstats(:, :, 1)), squeeze(simstats(:, :, 2))/sqrt(nsims), 'LineWidth', 2);
legend(labels);
title(strrep(sim.hemi_locs{li}, '_', '\_'));

title(['Mean difference from output similarity ' title_addendum]);
%set(gca, 'ylim', [0 1]);
xlabel('time step');
ylabel('Mean similarity difference from output.');


%% Figure 2: asymmetry in difference from output similarity
f2h = figure;
errorbar(repmat(1:tsteps, [nlocs/2 1])', squeeze(simstats(:, :, 3)), squeeze(simstats(:, :, 4))/sqrt(nsims), 'LineWidth', 2);
legend(labels);
title(strrep(sim.hemi_locs{li}, '_', '\_'));

title(['Asymmetry in difference from output similarity ' title_addendum]);
%set(gca, 'ylim', [0 1]);
xlabel('time step');
ylabel('Asymmetry in difference from output.');


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
        diff_from_output = patsim - sim.([sim.hemi_locs{li}(1:2) '_out']);
        if ~isempty(patsim)
            imagesc(pdist2mat(abs(1 - abs(diff_from_output))), [0 1]);
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
        diff_from_output = patsim - sim.([sim.hemi_locs{li}(1:2) '_out']);
        if ~isempty(patsim)
            imagesc(pdist2mat(abs(1 - abs(diff_from_output))), [0 1]);
        end;
        axis square;
        set(gca, 'xtick', [], 'ytick', []);
        title(sprintf('similarity: %.2f, %.2f', nanmean(diff_from_output), nanstd(diff_from_output))); %mean(diff_from_output)
    end;
    
    % Row 4: asymmetry
    for ai=1:length(sim.hemi_locs)/2
        figure(f);
        subplot(4, length(sim.hemi_locs)/2, li+si+ai);
        loc = sim.hemi_locs{ai}(4:end);
        patsim = (sim.(['rh_' loc])(ti).patsim - sim.(['lh_' loc])(ti).patsim);
        if ~isempty(patsim)
            imagesc(pdist2mat(patsim), [-2 2]);
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
