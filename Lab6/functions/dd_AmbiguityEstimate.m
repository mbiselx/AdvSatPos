function [N1_hat, N2_hat] = dd_AmbiguityEstimate(ld, f1, f2, obsw)
    % constants
    c       = 299792458;             % [m s^-1]

    % recursively determine ddN1 and ddN2
    [N1, N2] = double_difference_ambiguity(ld, c/f1, c/f2, obsw);

    % calculate wide-lane and iono-free ambiguities
    [Nwl, Nif] = widelane_ambiguities(N1, N2, f1, f2);

    % using the Clyde Goad method, evaluate
    [N1_hat, N2_hat] = ClydeGoad_estimation(Nwl, Nif, f1, f2);

end
