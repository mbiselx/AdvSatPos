clear
clc
addpath(".//functions")


% input files
ememerids       = "EPFL043I.21l";
measurements    = "E1epoch_479420.txt"
[ephm info units] = getrinexephGal(ememerids);
[meas, tow]       = GetRecieverMeasurements(measurements);

prn     = 1; % this could be much more elegant, but i can't
af0     = 2;
psr     = 2;
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

% constant declarations
c       = 299792458;             % [m s^-1]
we      = 7.2921151467e-5;       % [rad s^-1]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part A1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% select only the relevant ephemera and measurements
SVprn1 = [2, 7, 8, 11];% 25 30 36];
[ephm1, meas1] = SelectEphmMeas(ephm, meas, tow, SVprn1);

[r1, b1] = CalcPos(ephm1, meas1, tow, SVprn1);

fprintf("Part A1:\n");
fprintf("\tCalculated position is %7.0f / %7.0f / %7.0f [m].\n", r1(1), r1(2), r1(3));
fprintf("\tDeltaT is %.1f m\n", b1);
err = abs(r1 - [4364000; 500450; 4609100]);
if ((err(1) >= 1000) || (err(2) >= 10) || (err(3) >= 10))
    error('not precise enough!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part A2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% select only the relevant ephemera and measurements
SVprn2 = [2, 7, 8, 11, 25, 30, 36];
[ephm2, meas2] = SelectEphmMeas(ephm, meas, tow, SVprn2);

[r2, b2] = CalcPos(ephm2, meas2, tow, SVprn2);

fprintf("Part A2:\n");
fprintf("\tCalculated position is %7.0f / %7.0f / %7.0f [m].\n", r2(1), r2(2), r2(3));
fprintf("\tDeltaT is %.1f m\n", b2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ex 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

difference = sqrt(sum((r1-r2).^2));
fprintf("The difference between A1 and A2 is %.0f m.\n", difference);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ex 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% preparation
tau = meas2(psr,:)/c;

% loop
for i=0:2
    tk  = tow - tau;
    Pk  = meas2(psr,:);

    for i = 1:length(SVprn2)
        Xe(:,i) = ECEFSatellitePosition(ephm2, tk(i), SVprn2(i));
        Xk(:,i) = RotMat(we*tau(i), 3)*Xe(:,i);
    end

    [r2_ns, ~] = BancroftFilter(Xk, Pk);

    rhok = sqrt(sum((Xk-r2_ns).^2, 1));
    tau  = rhok/c;
end

difference = sqrt(sum((r2 - r2_ns).^2));
fprintf("Neglecting satellite clock corrections in pseudoranges\n\tgives an error of %.1f km.\n", difference/1000);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ex 5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% preparation
tau = meas2(psr,:)/c;

% loop
for i=0:2
    tk  = tow - tau;
    dtk = ephm2(af0,:) + ephm2(af1,:).*(tk - ephm2(toe,:))+ ephm2(af2,:).*(tk - ephm2(toe,:)).^2;
    Pk  = meas2(psr,:) + c*dtk;

    for i = 1:length(SVprn2)
        Xk(:,i) = ECEFSatellitePosition(ephm2, tk(i), SVprn2(i));
    end

    [r2_nr, ~] = BancroftFilter(Xk, Pk);

    rhok = sqrt(sum((Xk-r2_nr).^2, 1));
    tau  = rhok/c;
end

difference = sqrt(sum((r2 - r2_nr).^2));
fprintf("Neglecting earth rotation gives an error of %.2f km.\n", difference/1000);
