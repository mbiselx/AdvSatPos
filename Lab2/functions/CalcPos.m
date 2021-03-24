function [r, b] = CalcPos(ephm, meas, SVprn, tow)
% calculate the position of a GPS receiver using the Bancroft method

    prn     = 1;
    af0     = 2;
    psr     = 2;
    af1     = 3;
    af2     = 4;
    toe     = 13;

    % constant declarations
    c       = 299792458;             % [m s^-1]
    we      = 7.2921151467e-5;       % [rad s^-1]


    % initialization
    tau = meas(psr,:)/c;

    % iterative calculation loop
    for i=0:2
        tk  = tow - tau;
        dtk = ephm(af0,:) + ephm(af1,:).*(tk - ephm(toe,:))+ ephm(af2,:).*(tk - ephm(toe,:)).^2;
        Pk  = meas(psr,:) + c*dtk;

        for i = 1:length(SVprn) % (re)calculate satellite positions
            Xe(:,i) = ECEFSatellitePosition(ephm, tk(i), SVprn(i));
            Xk(:,i) = RotMat(we*tau(i), 3)*Xe(:,i);
        end

        [r, b] = BancroftFilter(Xk, Pk);

        rhok = sqrt(sum((Xk-r).^2, 1));
        tau  = rhok/c;
    end

end
