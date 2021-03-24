function [X, DOPs, Xk] = LinObsFilter(X0, ephm, meas, P, SVprn, tow)
    prn     = 1;
    af0     = 2;
    psr     = 2;
    af1     = 3;
    af2     = 4;
    toe     = 13;

    % constant declarations
    c       = 299792458;             % [m s^-1]
    we      = 7.2921151467e-5;       % [rad s^-1]

    % initial values
    rhok    = meas(psr,:);
    tau     = rhok/c;
    dx      = ones(4,1);

    % time corrections
    tk  = tow - tau;
    dtk = ephm(af0,:) + ephm(af1,:).*(tk - ephm(toe,:)) + ephm(af2,:).*(tk - ephm(toe,:)).^2;

    % satellite positions
    for i = 1:length(SVprn)
        Xe(:,i) = ECEFSatellitePosition(ephm, tk(i), SVprn(i));
        Xk(:,i) = RotMat(we*tau(i), 3) * Xe(:,i);
    end

    % iterative calculations
    while (sqrt(dx(1:3)'*dx(1:3)) > 1)
        % time corrections
        tk  = tow - tau;
        dtk = ephm(af0,:) + ephm(af1,:).*(tk - ephm(toe,:)) + ephm(af2,:).*(tk - ephm(toe,:)).^2;

        % % satellite positions                                         # note: though we should probably correct at every iteration, we can't do this for ex. B4, so it's been commented here.
        % for i = 1:length(SVprn)
        %     Xe(:,i) = ECEFSatellitePosition(ephm, tk(i), SVprn(i));
        %     Xk(:,i) = RotMat(we*tau(i), 3) * Xe(:,i);
        % end

        % corrected pseudoranges
        Pk = meas(psr,:) + c*dtk;

        % linear filter
        l  = (Pk - rhok)';
        A  = [((X0 - Xk)./rhok)', ones(length(SVprn), 1)];
        F  = pinv(A' * P * A) * A' * P;
        dx = F * l;

        % update values
        X0   = X0+dx(1:3);
        rhok = (sqrt(sum((Xk-X0).^2, 1)) - dx(4));
        tau  = rhok/c;
    end

    X = X0;

    for i=1:length(SVprn)
        label{i}=sprintf("%d", SVprn(i));
    end
    draw_ellipsoid([X, Xk]', [{"receiver"}, label])

    [GDOP, PDOP, HDOP, VDOP] = DOP(X, A, P);
    DOPs = [GDOP, PDOP, HDOP, VDOP];

end
