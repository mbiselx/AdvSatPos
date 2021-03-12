function [X, Y, i, w] = CorrectedOrbitalPlanePosition(ephm, t)
    % formulas adapted from ascelibrary.org

    % constants
    GM = 3.986005e14      ;    % [m^3 / s^2] Earth gravitation constant

    prn     = 1; % this could be much more elegant, but i can't
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


    % mean anomaly
    n = sqrt(GM) ./ ephm(sqrta,:).^3 + ephm(deltan,:);
    M = ephm(m0,:) + n.*(t-ephm(toe,:));

    % excentric anomaly
    E = ExcentricAnomaly(M, ephm(ecc,:), epsilon=1e-11);

    % true anomaly
    f = atan2(sqrt(1-ephm(ecc,:).^2).*sin(E), cos(E) - ephm(ecc,:));

    % argument of latitude
    phi = f + ephm(omega,:);

    % corrections
    du = ephm(cuc,:).*cos(2*phi) + ephm(cus,:).*sin(2*phi);
    w  = ephm(omega,:) + du;
    dr = ephm(crc,:).*cos(2*phi) + ephm(crs,:).*sin(2*phi);
    r  = ephm(sqrta,:).^2 .*(1-ephm(ecc,:).*cos(E)) + dr;
    di = ephm(cic,:).*cos(2*phi) + ephm(cis,:).*sin(2*phi);
    i  = ephm(i0,:) + ephm(idot,:).*(t-ephm(toe,:)) + di;

    % orbital position
    X = r.*cos(f);
    Y = r.*sin(f);

end
