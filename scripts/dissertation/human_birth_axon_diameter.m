shrinkage = 0.35; % 35% shrinkage
total_cc_area = 204 / (1 - shrinkage); % mm^2
tom_axon_diameters = [0.5 1 1.5 2 2.5 3] * 0.6 / (1 - shrinkage) % these were the max sizes
tom_add = [0.30 0.32 0.20 0.10 0.05]; tom_add(end+1) = 1 - sum(tom_add);
ffrac = 0.87;

available_cc_area = 204 * ffrac;

total_imaged_area = 125 * 10^6 * pi / 4 * sum(tom_add .* (tom_axon_diameters.^2)) / 10^6;

sqrt(10^6 * 4 / pi * (available_cc_area - total_imaged_area) / 675E6)
