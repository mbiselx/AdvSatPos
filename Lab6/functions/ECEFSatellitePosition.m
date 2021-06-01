function Xe = ECEFSatellitePosition(ephm, tow, SVprn=0)
%   ephm        ephemerids from navigation files
%   tow         time of week for which we are to calculate satellite position
%   SVprn       PRN of the satellites we are itnerested in. if none are
%               specified, all available satellites are used

    % ephemerid fields
    prn     = 1;
    af0     = 2;
    af1     = 3;
    af2     = 4;
    crs     = 6;
    deltan  = 7;
    m0      = 8;
    cuc     = 9;
    ecc     = 10;
    cus     = 11;
    sqrta   = 12;
    toe     = 13;
    cic     = 14;
    omega0  = 15; % long. of ascending node
    cis     = 16;
    i0      = 17; % inclination
    crc     = 18;
    omega   = 19; % argument of perigee
    omegadot= 20;
    idot    = 21;

    we      = 7.2921151467e-5;       % [rad s^-1]


    if (!exist("SVprn", "var")  || !SVprn)
        SVprn = unique(ephm(prn,:));
        sprintf("PRNs detected: ");
        disp(SVprn);
    end


    % step 0: select only the relevant ephemera
    [~, SVidx] = SelectEphm(ephm, tow, SVprn);

    % step 1: calculate position in orbital plane
    [x1o, x2o, i, w] = CorrectedOrbitalPlanePosition(ephm(:,SVidx), tow);
    Xo = [x1o; x2o; zeros(size(x1o))];

    % step 2: calculate position in ECEF
    Xe = zeros(size(Xo));
    for idx = 1:length(SVidx)         % loop for every satellite
        W = ephm(omega0,SVidx(idx)) + ephm(omegadot,SVidx(idx))*(tow - ephm(toe,SVidx(idx)));
        Xe(:,idx) = RotMat(we*tow - W,3) * RotMat(-i(idx),1) *  RotMat(-w(idx),3) * Xo(:,idx);
    end


end
