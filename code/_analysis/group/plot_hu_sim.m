
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