function [X_r, X_rm, s_x] = ddLinObsFilter(obsm, obsr, ephm, ld, Cd, N1, N2, f1, f2, X_m, prnb, epochs, verbose=true, draw=true)

    % constants
    c           = 299792458;            % [m s^-1]
    we          = 7.2921151467e-5;      % [rad s^-1]

    % initial position guess
    X_r0        = X_m;

    % memory allocations
    X_r         = cell(length(epochs),1);
    X_rm        = cell(length(epochs),1);
    s_x         = cell(length(epochs),1);

    % for every epoch, calculate:
    wb = waitbar(0);
    for e = 1:length(epochs)
        if verbose
            disp("------------------------------------------------------------")
            disp(sprintf("calculating epoch %d of %d", e, max(epochs)))
        end

        % basics
        SVprn       = unique(obsm{epochs(e)}(:,2))';
        SVprn_list  = kron(SVprn, ones(1,4));
        prnb_idx    = (SVprn_list == prnb);
        tow         = ld{epochs(e)}(1);

        % memory allocations
        Xe_m        = zeros(3,length(SVprn_list));
        Xk_m        = zeros(3,length(SVprn_list));
        Xe_r        = zeros(3,length(SVprn_list));
        Xk_r        = zeros(3,length(SVprn_list));

        % satellite clock corrections
        tau_m       = (obsm{epochs(e)}(:,3:end)'/c)(:)'; % initial guess
        tk_m        = SV_time_correction(tow - tau_m, ephm, SVprn_list);

        tau_r       = (obsr{epochs(e)}(:,3:end)'/c)(:)';
        tk_r        = SV_time_correction(tow - tau_r, ephm, SVprn_list);

        % satellite positions
        for i = 1:length(SVprn_list)
            Xe_m(:,i)   = ECEFSatellitePosition(ephm, tk_m(i), SVprn_list(i));
            Xk_m(:,i)   = RotMat(we*(tow - tk_m(i)), 3) * Xe_m(:,i);

            Xe_r(:,i)   = ECEFSatellitePosition(ephm, tk_r(i), SVprn_list(i));
            Xk_r(:,i)   = RotMat(we*(tow - tk_r(i)), 3) * Xe_r(:,i);
        end

        % distances to satellites
        rho_m       = sqrt(sum((Xk_m - X_m).^2));
        rho_r       = (obsr{epochs(e)}(:,3:end)')(:)'; % best guess?

        % observations
        Phi         = reshape(ld{epochs(e)}(:,3:end)', numel(ld{epochs(e)}(:,3:end)), 1);
        Ambiguity   = reshape([zeros(length(N1{epochs(e)}),2), c/f1*N1{epochs(e)}, c/f2*N2{epochs(e)}]', ...
                                4*numel(N1{epochs(e)}), 1); % there is no ambiguity on the code measurements
        P           = inv(Cd{epochs(e)});

        % iterative calculation
        dx          = ones(3,1);
        while (sqrt(dx'*dx) > 1e-3)

            % double differenced ranges to satellites
            rho_d_b0    = repmat(rho_m( prnb_idx) - rho_r( prnb_idx), 1, numel(SVprn)-1);
            rho_d_s0    =        rho_m(~prnb_idx) - rho_r(~prnb_idx);
            rho_dd0     = rho_d_b0 - rho_d_s0;

            % unit vectors pointing to the satellites
            u_b         = repmat((X_r0 - Xk_r(:, prnb_idx))./rho_r( prnb_idx), 1, numel(SVprn)-1);
            u_s         =        (X_r0 - Xk_r(:,~prnb_idx))./rho_r(~prnb_idx);

            % linearized calculation
            b           = Phi - Ambiguity - rho_dd0';
            A           = (u_s - u_b)';
            dx          = (A' * P * A) \ (A' * P) * b;
            if verbose disp("dx = "); disp(dx); end;

            % update values
            X_r0        = X_r0 + dx;
            rho_r       = sqrt(sum((Xk_r - X_r0).^2));
            tk_r        = SV_time_correction(tow - rho_r'/c, ephm, SVprn_list);
            for i = 1:length(SVprn_list) % satellite positions update
                Xe_r(:,i)   = ECEFSatellitePosition(ephm, tk_r(i), SVprn_list(i));
                Xk_r(:,i)   = RotMat(we*(tow - tk_r(i)), 3) * Xe_r(:,i);
            end

        end % iterative calculation

        % save the values
        X_r{e}     = X_r0;
        X_rm{e}    = X_r0 - X_m;

        % accuracy estimation, using uncertainty propagation
        s_x{e}     = inv(A' * P * A);

        % self control
        rho_d_b    = repmat(rho_m( prnb_idx) - rho_r( prnb_idx), 1, numel(SVprn)-1);
        rho_d_s    =        rho_m(~prnb_idx) - rho_r(~prnb_idx);
        v1         = A * dx + b;
        v2         = Phi - Ambiguity - (rho_d_b - rho_d_s)';
        assert(all((v1-v2) < sqrt(sum(diag(s_x{e}).^2))), "Self-control failed - the error terms do not match!");

        waitbar(e/length(epochs), wb);
    end % epochs


    if draw % draw satellites
        for i=1:length(SVprn) label{i}=sprintf("%d", SVprn(i)); end
        draw_ellipsoid([X_m, Xk_m(:,1:4:end)]', ["base", label])
        hold on;
        plot3(X_r{end}(1)*1e-3, X_r{end}(2)*1e-3, X_r{end}(3)*1e-3, 'rd');
        title("situation for last epoch")
        hold off;
    end

    close(wb);

end
