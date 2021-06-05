function [X_r, X_rm, s_x] = ddrecLinObsFilter(obsm, obsr, ephm, ld, Cd, N1, N2, f1, f2, X_m, prnb, verbose=true, draw=true)
% recursively calculate a position usinng all available epochs.
% very precise, but is quite slow to calculate
% final part of the lab06

    % constants
    c           = 299792458;            % [m s^-1]
    we          = 7.2921151467e-5;      % [rad s^-1]

    % basics
    SVprn       = unique(obsm{1}(:,2))';
    SVprn_list  = kron(SVprn, ones(1,4));
    prnb_idx    = (SVprn_list == prnb);

    % memory allocations
    Xe_m        = zeros(3,length(SVprn_list));
    Xk_m        = zeros(3,length(SVprn_list));
    Xe_r        = zeros(3,length(SVprn_list));
    Xk_r        = zeros(3,length(SVprn_list));
    Xk_r        = cell(size(obsm));



    % initial guesses
    X_r0        = X_m;
    X_r         = X_r0;
    X_rm        = X_r0 - X_m;
    rho_m       = cellfun(@(obs) obs(:,3:end)'(:)', obsm, "UniformOutput", false);
    tau_m       = cellfun("rdivide", rho_m, {c}, "UniformOutput", false);
    rho_r       = cellfun(@(obs) obs(:,3:end)'(:)', obsr, "UniformOutput", false);
    tau_r       = cellfun("rdivide", rho_r, {c}, "UniformOutput", false);

    Phi         = cellfun(@(l) reshape(l(:,3:end)', numel(l(:,3:end)), 1), ld, "UniformOutput", false);
    Ambiguity   = cellfun(@(n1, n2) reshape([zeros(length(n1),2), c/f1*n1, c/f2*n2]', 4*numel(n1), 1), N1, N2, "UniformOutput", false); % there is no ambiguity on the code measurements
    P           = inv(Cd{1});


    % iterative calculation
    iter        = 1;
    dx          = ones(3,1);
    wb = waitbar(0);
    while (sqrt(dx'*dx) > 1e-3) && iter < 15 % iterate


        sum_N = 0;
        sum_b = 0;

        waitbar(0, wb, sprintf("Iteration %d", iter));
        for e = 1:length(obsm)

            tow         = ld{e}(1);

            % satellite clock corrections
            tk_m        = SV_time_correction(tow - tau_m{e}, ephm, SVprn_list);
            tk_r        = SV_time_correction(tow - tau_r{e}, ephm, SVprn_list);

            % satellite positions
            Xk_r{e} = zeros(3,length(SVprn_list));
            for i = 1:length(SVprn_list)
                Xe_m(:,i)   = ECEFSatellitePosition(ephm, tk_m(i), SVprn_list(i));
                Xk_m(:,i)   = RotMat(we*(tow - tk_m(i)), 3) * Xe_m(:,i);

                Xe_r(:,i)   = ECEFSatellitePosition(ephm, tk_r(i), SVprn_list(i));
                Xk_r{e}(:,i)= RotMat(we*(tow - tk_r(i)), 3) * Xe_r(:,i);
            end

            % distances to satellites
            rho_m{e}    = sqrt(sum((Xk_m - X_m).^2));

            % double differenced ranges to satellites
            rho_d_b0    = repmat(rho_m{e}( prnb_idx) - rho_r{e}( prnb_idx), 1, numel(SVprn)-1);
            rho_d_s0    =        rho_m{e}(~prnb_idx) - rho_r{e}(~prnb_idx);
            rho_dd0     = rho_d_b0 - rho_d_s0;

            % unit vectors pointing to the satellites
            u_b         = repmat((X_r - Xk_r{e}(:, prnb_idx))./rho_r{e}( prnb_idx), 1, numel(SVprn)-1);
            u_s         =        (X_r - Xk_r{e}(:,~prnb_idx))./rho_r{e}(~prnb_idx);

            % linearized calculation
            l_reduced   = Phi{e} - Ambiguity{e} - rho_dd0';
            A           = (u_s - u_b)';

            % do recursive thing
            sum_N       = sum_N + (A' * P * A);
            sum_b       = sum_b + (A' * P * l_reduced);

             waitbar(e/length(obsm), wb)
        end % epochs

        % solve linearized recursive system
        dx          = sum_N \ sum_b;
        if verbose
            fprintf("Iteration %d\n\tdx =\t[%.3f, %.3f, %.3f]\n", iter, dx(1), dx(2), dx(3));
        end;

        % update values
        X_rm        = X_rm + dx;
        X_r         = X_r0 + X_rm;

        temp        = cellfun("power", cellfun("minus", Xk_r, {X_r}, "UniformOutput", false), {2}, "UniformOutput", false);
        rho_r       = cellfun("sqrt",  cellfun("sum", temp, "UniformOutput", false), "UniformOutput", false);
        tau_r       = cellfun("rdivide", rho_r, {c}, "UniformOutput", false);
        tau_m       = cellfun("rdivide", rho_m, {c}, "UniformOutput", false);

        iter = iter + 1;

    end % iterations

    % estimated accuracy
    s_x = inv(sum_N);


    % self control
    rho_d_b    = repmat(rho_m{end}( prnb_idx) - rho_r{end}( prnb_idx), 1, numel(SVprn)-1);
    rho_d_s    =        rho_m{end}(~prnb_idx) - rho_r{end}(~prnb_idx);
    v1         = A * dx + l_reduced;
    v2         = Phi{end} - Ambiguity{end} - (rho_d_b - rho_d_s)';
    assert(all(abs(v1-v2) < 1e-3), "Self-control failed - the error terms do not match!");



    if draw % draw satellites
        for i=1:length(SVprn) label{i}=sprintf("%d", SVprn(i)); end
        draw_ellipsoid([X_m, Xk_m(:,1:4:end)]', ["base", label])
        hold on;
        plot3(X_r(1)*1e-3, X_r(2)*1e-3, X_r(3)*1e-3, 'rd');
        hold off;
    end

    close(wb)


end
