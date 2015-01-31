function [an] = r_analyze_training(net, pats, data)

    % Was passed a particular dataset & result; do the actual calculations
    if (isfield(data, 'ypat'))

        % By hemisphere
        an.lh.abs_diff         = abs(data.ypat(pats.gb_lh) - pats.d(pats.gb_lh));
        an.lh.max_diff         = max(an.lh.abs_diff(:));
        an.lh.bits_cor         = (an.lh.abs_diff < net.sets.train_criterion);
        an.lh.bits_set         = length(pats.gb_lh);
        an.lh.bg_total         = sum(an.lh.bits_cor) / an.lh.bits_set;

        an.rh.abs_diff         = abs(data.ypat(pats.gb_rh) - pats.d(pats.gb_rh));
        an.rh.max_diff         = max(an.rh.abs_diff(:));
        an.rh.bits_cor         = (an.rh.abs_diff < net.sets.train_criterion);
        an.rh.bits_set         = length(pats.gb_rh);
        an.rh.bg_total         = sum(an.rh.bits_cor) / an.rh.bits_set;

        an.abs_diff         = abs(data.ypat(pats.gb) - pats.d(pats.gb));
        an.max_diff         = max(an.abs_diff(:));
        an.bits_cor         = (an.abs_diff < net.sets.train_criterion);
        an.bits_set         = length(pats.gb);
        an.bg_total         = sum(an.bits_cor)/an.bits_set;
        return;
    end;

    % Analyze each struture, then report
    if (isfield(data,'lesion'))
        % Generic analyses
        [an.l]  = r_analyze_training(net, pats.(data.lesion.pats), data.lesion);
        [an.nl] = r_analyze_training(net, pats.(data.nolesion.pats), data.nolesion);

        % Generic reports
        %data.lesion.avgerr - data.nolesion.avgerr         % Hemispheric diff in activation
    end;
