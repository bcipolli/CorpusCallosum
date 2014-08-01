function net = dissertation_args_long()

    net = dissertation_args(30, 1, 29, [], []);

    net.sets.T_INIT = 2*net.sets.dt.*[1 1];  %change
