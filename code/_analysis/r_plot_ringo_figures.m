function fs = r_plot_ringo_figures(clean_dir, noise_dir, plots, cache_file)

% Defaults & scrubbing input
%if ~exist('clean_dir', 'var'), clean_dir = 'nonoise.10'; end;
%if ~exist('noise_dir', 'var'), noise_dir = 'noise.10.1'; end;
if ~exist('plots','var'),      plots     = [ 0.25 ]; end;
if ~exist('cache_file', 'var'),cache_file= fullfile(r_out_path('cache'),'cs2013_cache.mat'); end;

[cdata,ts] = get_cache_data(clean_dir, cache_file);
[ndata]    = get_cache_data(noise_dir, cache_file);


fs = []; % output figure handles

%% Learning trajectory (raw)
if any(0<=plots & plots<1)
    % All
    lt_cdata = struct('intact', cdata.all.intact.clserr, 'lesion', cdata.all.lesion.clserr);
    lt_ndata = struct('intact', ndata.all.intact.clserr, 'lesion', ndata.all.lesion.clserr);
    if ismember(0, plots) || ismember(0.1, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'bce'); end;
    if ismember(0, plots) || ismember(0.3, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'bce', true); end; %overlay on single axes

    lt_cdata = struct('intact', cdata.all.intact.err, 'lesion', cdata.all.lesion.err);
    lt_ndata = struct('intact', ndata.all.intact.err, 'lesion', ndata.all.lesion.err);
    if ismember(0, plots) || ismember(0.2, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'sse'); end;
    if ismember(0, plots) || ismember(0.4, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'sse', true); end;%overlay on single axes

    % Intra
    lt_cdata = struct('intact', cdata.intra.intact.clserr, 'lesion', cdata.intra.lesion.clserr);
    lt_ndata = struct('intact', ndata.intra.intact.clserr, 'lesion', ndata.intra.lesion.clserr);
    if ismember(0, plots) || ismember(0.5, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'bce', true); title([get(get(gca,'Title'),'String') '(intra)']); end; %overlay on single axes

    lt_cdata = struct('intact', cdata.intra.intact.err, 'lesion', cdata.intra.lesion.err);
    lt_ndata = struct('intact', ndata.intra.intact.err, 'lesion', ndata.intra.lesion.err);
    if ismember(0, plots) || ismember(0.6, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'sse', true); title([get(get(gca,'Title'),'String') '(intra)']); end; %overlay on single axes

    % Inter
    lt_cdata = struct('intact', cdata.inter.intact.clserr, 'lesion', cdata.inter.lesion.clserr);
    lt_ndata = struct('intact', ndata.inter.intact.clserr, 'lesion', ndata.inter.lesion.clserr);
    if ismember(0, plots) || ismember(0.7, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'bce', true); title([get(get(gca,'Title'),'String') '(inter)']);  end; %overlay on single axes

    lt_cdata = struct('intact', cdata.inter.intact.err, 'lesion', cdata.inter.lesion.err);
    lt_ndata = struct('intact', ndata.inter.intact.err, 'lesion', ndata.inter.lesion.err);
    if ismember(0, plots) || ismember(0.8, plots), fs(end+1) = plot_raw_learning(lt_cdata,lt_ndata,ts,'sse', true); title([get(get(gca,'Title'),'String') '(inter)']);  end; %overlay on single axes

    clear('lt_cdata', 'lt_ndata');
end;

%% Learning trajectory (diff)
if any(1<=plots & plots<2)
    % All
    lt_cdata = struct('mean', cdata.all.lei.clsmean, 'std', cdata.all.lei.clsstd, 'sem', cdata.all.lei.clssem);
    lt_ndata = struct('mean', ndata.all.lei.clsmean, 'std', ndata.all.lei.clsstd, 'sem', ndata.all.lei.clssem);
    if ismember(1, plots) || ismember(1.3, plots), fs(end+1) = plot_raw_lei(lt_cdata,lt_ndata,ts,'bce'); end;

    lt_cdata = struct('mean', cdata.all.lei.errmean, 'std', cdata.all.lei.errstd, 'sem', cdata.all.lei.errsem);
    lt_ndata = struct('mean', ndata.all.lei.errmean, 'std', ndata.all.lei.errstd, 'sem', ndata.all.lei.errsem);
    if ismember(1, plots) || ismember(1.4, plots), fs(end+1) = plot_raw_lei(lt_cdata,lt_ndata,ts,'sse'); end;

    % Intra
    [h, p] = ttest2(cdata.intra.lei.cls, ndata.intra.lei.cls);
    lt_cdata = struct('mean', mean(cdata.intra.lei.cls,1), 'std', std(cdata.intra.lei.cls,[],1), 'sem', guru_sem(cdata.intra.lei.cls, 1));
    lt_ndata = struct('mean', mean(ndata.intra.lei.cls,1), 'std', std(ndata.intra.lei.cls,[],1), 'sem', guru_sem(ndata.intra.lei.cls, 1));
    if ismember(1, plots) || ismember(1.5, plots), fs(end+1) = plot_raw_lei(lt_cdata,lt_ndata,ts,'bce',h,p); title([get(get(gca,'Title'),'String') ' (intra)']);   end;

    [h, p] = ttest2(cdata.intra.lei.err, ndata.intra.lei.err);
    lt_cdata = struct('mean', mean(cdata.intra.lei.err,1), 'std', std(cdata.intra.lei.err,[],1), 'sem', guru_sem(cdata.intra.lei.err, 1));
    lt_ndata = struct('mean', mean(ndata.intra.lei.err,1), 'std', std(ndata.intra.lei.err,[],1), 'sem', guru_sem(ndata.intra.lei.err, 1));
    if ismember(1, plots) || ismember(1.6, plots), fs(end+1) = plot_raw_lei(lt_cdata,lt_ndata,ts,'sse',h,p); title([get(get(gca,'Title'),'String') ' (intra)']);   end;

    % Inter
    [h, p] = ttest2(cdata.inter.lei.cls, ndata.inter.lei.cls);
    lt_cdata = struct('mean', mean(cdata.inter.lei.cls,1), 'std', std(cdata.inter.lei.cls,[],1), 'sem', guru_sem(cdata.inter.lei.cls, 1));
    lt_ndata = struct('mean', mean(ndata.inter.lei.cls,1), 'std', std(ndata.inter.lei.cls,[],1), 'sem', guru_sem(ndata.inter.lei.cls, 1));
    if ismember(1, plots) || ismember(1.7, plots), fs(end+1) = plot_raw_lei(lt_cdata,lt_ndata,ts,'bce',h,p); title([get(get(gca,'Title'),'String') ' (inter)']);   end;

    [h, p] = ttest2(cdata.inter.lei.err, ndata.inter.lei.err);
    lt_cdata = struct('mean', mean(cdata.inter.lei.err,1), 'std', std(cdata.inter.lei.err,[],1), 'sem', guru_sem(cdata.inter.lei.err, 1));
    lt_ndata = struct('mean', mean(ndata.inter.lei.err,1), 'std', std(ndata.inter.lei.err,[],1), 'sem', guru_sem(ndata.inter.lei.err, 1));
    if ismember(1, plots) || ismember(1.8, plots), fs(end+1) = plot_raw_lei(lt_cdata,lt_ndata,ts,'sse',h,p); title([get(get(gca,'Title'),'String') ' (inter)']);   end;

    clear('lt_cdata', 'lt_ndata');
end;


%% Raw plot of lesion induced errors
if any(2<=plots & plots<3)
    %[h,p] = ttest2(cdata.intra.lei.cls - ndata.intra.lei.cls, cdata.inter.lei.cls - ndata.inter.lei.cls);
    lei_cdata = struct('intra', cdata.intra.lei.cls, 'inter', cdata.inter.lei.cls);
    lei_ndata = struct('intra', ndata.intra.lei.cls, 'inter', ndata.inter.lei.cls);
    if ismember(2, plots) || ismember(2.1, plots), fs(end+1) = plot_lei_split(lei_cdata,lei_ndata,ts,'bce'); end;

    %[h,p] = ttest2(cdata.intra.lei.err - ndata.intra.lei.err, cdata.inter.lei.err - ndata.inter.lei.err);
    lei_cdata = struct('intra', cdata.intra.lei.err, 'inter', cdata.inter.lei.err);
    lei_ndata = struct('intra', ndata.intra.lei.err, 'inter', ndata.inter.lei.err);
    if ismember(2, plots) || ismember(2.2, plots), fs(end+1) = plot_lei_split(lei_cdata,lei_ndata,ts,'sse'); end;
end;


%% Similarity matrix
if any(3<=plots & plots<4)
    if ismember(3, plots) || ismember(3.1, plots), fs(end+1) = plot_hu_sim2(cdata.all,ndata.all, 'all'); end;
    if ismember(3, plots) || ismember(3.2, plots), fs(end+1) = plot_hu_sim2(cdata.intra,ndata.intra, 'intra'); end;
    if ismember(3, plots) || ismember(3.3, plots), fs(end+1) = plot_hu_sim2(cdata.inter,ndata.inter, 'inter'); end;
end;


%% Distribution of fibers
if any(4<=plots & plots<5)
    keyboard
end;





function f = plot_similarity_old(cdata, ndata, lbl)
%
% Compare RH and LH similarity for noise and no-noise conditions.
    nmodels_nonoise = size(cdata.intact.rh_sim, 1);
    nmodels_noise = size(ndata.intact.rh_sim, 1);

    sims_nonoise_intact = zeros(nmodels_nonoise, 1);
    sims_noise_intact   = zeros(nmodels_noise, 1);
    sims_nonoise_lesion = zeros(nmodels_nonoise, 1);
    sims_noise_lesion   = zeros(nmodels_noise, 1);

    for mi=1:nmodels_nonoise
        if isempty(cdata.intact.rh_sim(mi,:)) || isempty(cdata.intact.lh_sim(mi,:))
            continue;
        end;
        sims_nonoise_intact(mi) = corr(cdata.intact.rh_sim(mi,:)', cdata.intact.lh_sim(mi,:)');
        sims_nonoise_lesion(mi) = corr(cdata.lesion.rh_sim(mi,:)', cdata.lesion.lh_sim(mi,:)');
    end;

    for mi=1:nmodels_noise
        if isempty(ndata.intact.rh_sim(mi,:)) || isempty(ndata.intact.lh_sim(mi,:))
            continue;
        end;
        sims_noise_intact(mi) = corr(ndata.intact.rh_sim(mi,:)', ndata.intact.lh_sim(mi,:)');
        sims_noise_lesion(mi) = corr(ndata.lesion.rh_sim(mi,:)', ndata.lesion.lh_sim(mi,:)');
    end;

    fprintf('[%s]: RH / LH no-noise similarity (intact): %.2f +/- %.2f\n', lbl, mean(sims_nonoise_intact), std(sims_nonoise_intact));
    fprintf('[%s]: RH / LH   noise similarity: (intact): %.2f +/- %.2f\n', lbl, mean(sims_noise_intact),   std(sims_noise_intact));
    fprintf('[%s]: RH / LH no-noise similarity (lesion): %.2f +/- %.2f\n', lbl, mean(sims_nonoise_lesion), std(sims_nonoise_lesion));
    fprintf('[%s]: RH / LH   noise similarity: (lesion): %.2f +/- %.2f\n', lbl, mean(sims_noise_lesion),   std(sims_noise_lesion));

    f = plot_hu_sim(cdata, ndata, lbl);


function f = plot_hu_sim(cdata, ndata, lbl)
%
%
    if ~exist('lbl', 'var'), lbl = '';
    else, lbl = [' ' lbl]; end;

    f = figure;

    cdata_rh = cdata.intact.rh_sim;
    cdata_lh = cdata.intact.lh_sim;
    ndata_rh = ndata.intact.rh_sim;
    ndata_lh = ndata.intact.lh_sim;

    subplot(2,3,1);
    imagesc(pdist2mat(mean(cdata_rh, 1)));
    axis square;
    set(gca, 'xtick',[],'ytick',[]);
    title(['(no-noise) RH Similarity' lbl]);

    subplot(2,3,4);
    imagesc(pdist2mat(mean(cdata_lh, 1)));
    axis square;
    set(gca, 'xtick',[],'ytick',[]);
    title(['(no-noise) LH Similarity' lbl]);

    subplot(2,3,2);
    imagesc(pdist2mat(mean(ndata_rh, 1)));
    axis square;
    set(gca, 'xtick',[],'ytick',[]);
    title(['(noise) RH Similarity' lbl]);

    subplot(2,3,5);
    imagesc(pdist2mat(mean(ndata_lh, 1)));
    axis square;
    set(gca, 'xtick',[],'ytick',[]);
    xlabel('LH pattern #');
    title(['(noise) LH Similarity' lbl]);

    if isfield(cdata, 'rh_in_sim')
        subplot(2,3,3);
        imagesc(pdist2mat(cdata.rh_in_sim));
        axis square;
        set(gca, 'xtick',[],'ytick',[]);
        title('input similarity');

        subplot(2,3,6);
        imagesc(pdist2mat(cdata.rh_out_sim));
        axis square;
        set(gca, 'xtick',[],'ytick',[]);
        title('output similarity');
    end;
    
    
    % take the dot product for each, then take the mean of the result.
    no_nan = @(d) (d(~isnan(d)));
    mean_dotted = @(d1, d2) (mean(sum( d1./sqrt(sum(d1.^2, 2)) .* d2./sqrt(sum(d2.^2, 2)), 2)));
    mean_dotted_nan = @(d1, d2) (mean_dotted(no_nan(d1), no_nan(d2)));
    shared_count = min(size(cdata_lh,1), size(ndata_lh, 1));

    if (numel(cdata_rh) > 0)
        fprintf('no-noise LH-RH similarity (%s): %f\n', lbl, mean_dotted(cdata_rh, cdata_lh));
        fprintf('   noise LH-RH similarity (%s): %f\n', lbl, mean_dotted(ndata_rh, ndata_lh));
        fprintf('no/noise LH-LH similarity (%s): %f\n', lbl, mean_dotted(cdata_lh(1:shared_count), ndata_lh(1:shared_count)));
        fprintf('no/noise RH-RH similarity (%s): %f\n', lbl, mean_dotted(cdata_rh(1:shared_count), ndata_rh(1:shared_count)));

        if isfield(cdata, 'rh_in_sim')
            %keyboard

            cdata_rh_vs_input = cdata_rh - repmat(cdata.rh_in_sim, [size(cdata_rh, 1) 1]);
            cdata_lh_vs_input = cdata_lh - repmat(cdata.lh_in_sim, [size(cdata_lh, 1) 1]);
            ndata_rh_vs_input = ndata_rh - repmat(ndata.rh_in_sim, [size(ndata_rh, 1) 1]);
            ndata_lh_vs_input = ndata_lh - repmat(ndata.lh_in_sim, [size(ndata_lh, 1) 1]);

            fprintf('\nVS INPUT\n');
            fprintf('no-noise LH-RH similarity (%s): %f\n', lbl, mean_dotted_nan(cdata_rh_vs_input, cdata_lh_vs_input));
            fprintf('   noise LH-RH similarity (%s): %f\n', lbl, mean_dotted_nan(ndata_rh_vs_input, ndata_lh_vs_input));

            cdata_rh_vs_output = cdata_rh - repmat(cdata.rh_out_sim, [size(cdata_rh, 1) 1]);
            cdata_lh_vs_output = cdata_lh - repmat(cdata.lh_out_sim, [size(cdata_lh, 1) 1]);
            ndata_rh_vs_output = ndata_rh - repmat(ndata.rh_out_sim, [size(ndata_rh, 1) 1]);
            ndata_lh_vs_output = ndata_lh - repmat(ndata.lh_out_sim, [size(ndata_lh, 1) 1]);

            fprintf('\nVS OUTPUT\n');
            fprintf('no-noise LH-RH similarity (%s): %f\n', lbl, mean_dotted_nan(cdata_rh_vs_output, cdata_lh_vs_output));
            fprintf('   noise LH-RH similarity (%s): %f\n', lbl, mean_dotted_nan(ndata_rh_vs_output, ndata_lh_vs_output));
        end;
    end;


function f = plot_lei_split(cdata,ndata,ts,dtype,h,p)
%

    f = figure;
    ddlbls = datatype_dependent_labels(dtype);

    % No noise first
    cc = ddlbls.colors{1};
    nc = ddlbls.colors{2};
    ram = ddlbls.markers{1}; % intra-hemispheric
    erm = ddlbls.markers{2}; %inter-hemispheric

    subplot(1,2,1);
    set(gca, 'FontSize', 18);
    title('a) Lesion-induced error');
    xlabel('training epoch'); ylabel(['\Delta ' ddlbls.ylbl]);
    hold on;

    lh1=plot(ts.lesion,      mean(cdata.intra,1), [cc ram '-.'], 'LineWidth', 3, 'MarkerFaceColor', cc, 'MarkerSize', 10);
    lh2=plot(ts.lesion,      mean(ndata.intra,1), [nc ram '-.'], 'LineWidth', 3, 'MarkerFaceColor', nc, 'MarkerSize', 10);
    lh3=plot(ts.lesion,      mean(cdata.inter,1), [cc erm '-.'], 'LineWidth', 3, 'MarkerFaceColor', cc, 'MarkerSize', 10);
    lh4=plot(ts.lesion,      mean(ndata.inter,1), [nc erm '-.'], 'LineWidth', 3, 'MarkerFaceColor', nc, 'MarkerSize', 10);
    errorbar(ts.lesion,  mean(cdata.intra,1), guru_sem(cdata.intra, 1), [cc '.']);
    errorbar(ts.lesion,  mean(ndata.intra,1), guru_sem(cdata.intra, 1), [nc '.']);
    errorbar(ts.lesion,  mean(cdata.inter,1), guru_sem(cdata.intra, 1), [cc '.']);
    errorbar(ts.lesion,  mean(ndata.inter,1), guru_sem(cdata.intra, 1), [nc '.']);
    legend([lh1 lh2 lh3 lh4], {'Intra- (control)', 'Intra- (noise)', 'Inter- (control)', 'Inter- (noise)'}, 'FontSize', 16, 'Location', 'NorthWest')
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 ts.niters+25], 'ylim', ddlbls.ytick([1 end-1]));
    set(gca, 'ytick', ddlbls.ytick(1:end-1), 'yticklabel', ddlbls.yticklabel(1:end-1));


    intra_dd_mean = mean(cdata.intra,1) - mean(ndata.intra,1);
    inter_dd_mean = mean(cdata.inter,1) - mean(ndata.inter,1);
    intra_dd_sem  = guru_sem(cdata.intra, 1) + guru_sem(ndata.intra, 1);
    inter_dd_sem  = guru_sem(cdata.inter, 1) + guru_sem(ndata.inter, 1);

    subplot(1,2,2);
    set(gca, 'FontSize', 18);
    title('b) \Delta Lesion-induced error');
    xlabel('training epoch'); ylabel(['\Delta \Delta ' ddlbls.ylbl]);
    hold on;

    lh1=plot(ts.lesion, intra_dd_mean, [ram 'k-.'], 'LineWidth', 2, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    lh2=plot(ts.lesion, inter_dd_mean, [erm 'k-.'], 'LineWidth', 2, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
    errorbar(ts.lesion, intra_dd_mean, intra_dd_sem, 'k.');
    errorbar(ts.lesion, inter_dd_mean, inter_dd_sem, 'k.');
    legend([lh1 lh2], {'Intrahemispheric patterns', 'Interhemispheric patterns', }, 'FontSize', 16, 'Location', 'NorthWest');
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 ts.niters+25], 'ylim', ddlbls.ytick(floor(end/2)).*[-1 1]);
%    set(gca, 'ytick', ddlbls.ytick().*[-1 1], 'yticklabel', {['-' ddlbls.yticklabel{floor(end/2)}] ddlbls.yticklabel{floor(end/2)}});
    set(gca, 'ylim', [-0.1, 0.3]);
    axis square;

    if exist('stats','var') && exist('p','var')
        p
        %for ti=1:length(ts.lesion)
        %    if stats(ti)
        %        nstars = min(3, floor(-log10(p(ti))));
        %        stars = repmat('*', [1 nstars]);
        %        xval = ts.lesion(ti);
        %        yval = max([intra_dd_mean(ti), inter_dd_mean(ti)]);
        %
        %        text(xval - 18*length(stars)/2, yval + 0.05, stars, 'FontSize', 18, 'FontWeight', 'bold');
        %    end;
        %end;
    end;
    set(gcf, 'Position', [10          90        1266         594]);
    drawnow;


% Dependence across delays

%% Raw plot of lesion induced errors
function f = plot_raw_lei(cdata,ndata,ts,dtype,stats,p)
%
    f = figure;
    ddlbls = datatype_dependent_labels(dtype);

    % No noise first
    cc = ddlbls.colors{1};
    nc = ddlbls.colors{2};
    hold on;
    set(gca, 'FontSize', 18);
    title('Lesion-induced error');
    xlabel('training epoch'); ylabel(ddlbls.ylbl);
    plot(ts.lesion,      cdata.mean, [cc '.-'], 'LineWidth', 3, 'MarkerFaceColor', cc, 'MarkerSize', 10);
    plot(ts.lesion,      ndata.mean, [nc '.-'], 'LineWidth', 3, 'MarkerFaceColor', nc, 'MarkerSize', 10);
    errorbar(ts.lesion,  cdata.mean, cdata.sem, [cc '.']);
    errorbar(ts.lesion,  ndata.mean, ndata.sem, [nc '.']);

    if exist('stats','var') && exist('p','var')
        p
        %for ti=1:length(ts.lesion)
        %    if stats(ti)
        %        nstars = min(3, floor(-log10(p(ti))));
        %        stars = repmat('*', [1 nstars]);
        %        xval = ts.lesion(ti);
        %        yval = max([cdata.mean(ti), ndata.mean(ti)]);
        %
        %        text(xval - 18*length(stars)/2, yval + 0.05, stars, 'FontSize', 18, 'FontWeight', 'bold');
        %    end;
        %end;
    end;

    legend({'Control', 'Noise'}, 'FontSize', 16, 'Location', 'NorthWest')
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 ts.niters+25], 'ylim', ddlbls.ytick([1 end-1]));
    set(gca, 'ytick', ddlbls.ytick(1:end-1), 'yticklabel', ddlbls.yticklabel(1:end-1));
    %set(gca, 'xlim', [-10 ts.niters+25], 'ylim', ddlbls.ylim);%[0.1 0.8]);
    %set(gca, 'ytick', [0.0:0.1:0.6], 'yticklabel', {'0%' '10%' '20%' '30%' '40%' '50%' '60%'});
    axis square;

    set(gcf, 'Position', [   220    46   727   638]);
    drawnow;


%% Raw plot of learning trajectories, without separation into inter/intra
function f = plot_raw_learning(cdata,ndata,ts,dtype,overlay)
%
    if ~exist('overlay','var'), overlay=false; end;

    f = figure;
    ddlbls = datatype_dependent_labels(dtype);

    % No noise first
    cc = ddlbls.colors{1};
    if ~overlay, subplot(1,2,1); end;
    hold on;

    set(gca, 'FontSize', 18);
    xlabel('training epoch'); ylabel(ddlbls.ylbl);
    lh1 = plot(ts.intact,      mean(cdata.intact(:,ts.intact),1), [cc '.-'], 'LineWidth', 3, 'MarkerFaceColor', cc, 'MarkerSize', 10);
    lh2 = plot(ts.lesion,      mean(cdata.lesion,1),              [cc '.:'], 'LineWidth', 3, 'MarkerFaceColor', cc, 'MarkerSize', 10);
    errorbar(ts.intact,  mean(cdata.intact(:,ts.intact),1), guru_sem(cdata.intact(:,ts.intact), 1), [cc '.']);
    errorbar(ts.lesion,  mean(cdata.lesion,1),              guru_sem(cdata.lesion, 1), [cc '.'])
    if ~overlay
        set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
        set(gca, 'xlim', [-10 ts.niters+25], 'ylim', ddlbls.ylim);
        set(gca, 'ytick', ddlbls.ytick, 'yticklabel', ddlbls.yticklabel);
        title('a) Learning Trajectory (control)');
        legend({'Intact', 'Lesioned' }, 'FontSize', 18);
    end;
    axis square;


    % Noise second
    nc = ddlbls.colors{2};
    if ~overlay, subplot(1,2,2); end;
    hold on;
    set(gca, 'FontSize', 18);
    xlabel('training epoch'); ylabel(ddlbls.ylbl);
    lh3 = plot(ts.intact,      mean(ndata.intact(:,ts.intact),1), [nc '.-'], 'LineWidth', 3, 'MarkerFaceColor', nc, 'MarkerSize', 10);
    lh4 = plot(ts.lesion,      mean(ndata.lesion,1),              [nc '.:'], 'LineWidth', 3, 'MarkerFaceColor', nc, 'MarkerSize', 10);
    errorbar(ts.intact,  mean(ndata.intact(:,ts.intact),1), guru_sem(ndata.intact(:,ts.intact), 1), [nc '.']);
    errorbar(ts.lesion,  mean(ndata.lesion,1),              guru_sem(ndata.lesion, 1), [nc '.'])
    set(gca, 'LooseInset', [0.15 0.2 0.15 0.15]); %[left top right bottom]
    set(gca, 'xlim', [-10 ts.niters+25], 'ylim', ddlbls.ylim);
    set(gca, 'ytick', ddlbls.ytick, 'yticklabel', ddlbls.yticklabel);
    axis square;

    if overlay
        title('Learning Trajectory');
        legend([lh1 lh2 lh3 lh4], {'Intact (control)', 'Lesioned (control)', 'Intact (noise)', 'Lesioned (noise)'}, 'FontSize', 18);

        set(gcf, 'Position', [   220    46   727   638]);
        drawnow;

    else
        title('b) Learning Trajectory (noise)');
        legend({'Intact', 'Lesioned' }, 'FontSize', 18);

        set(gcf, 'Position', [10          90        1266         594]);
        drawnow;
    end;


%%
function ddlbls = datatype_dependent_labels(dtype)
%
    switch dtype
        case 'sse'
            ddlbls.title = 'Sum-squared error';
            ddlbls.ylbl = 'Sum-squared error';
            ddlbls.ylim = [0.0 1.0];
            ddlbls.ytick = [0.0:0.25:1.0];
            ddlbls.yticklabel = {'0' '0.25' '0.50' '0.75' '1.0'};

        case 'bce'
            ddlbls.title = 'Binary classification Error';
            ddlbls.ylbl = '% of wrongly classified outputs';
            ddlbls.ylim = [0.0 1.0];
            ddlbls.ytick = [0.0:0.25:1.0];
            ddlbls.yticklabel = {'0%' '25%' '50%' '75%' '100%'};

        otherwise
            error('Unknown datatype: %s', dtype);
    end;

    % Common to both
    ddlbls.colors  = {'b' 'r' 'g' 'k'};
    ddlbls.markers = {'*','v','s','o'};




