close all
clear
clc
addpath(".//functions")


% input files
ememerids       = "EPFL043I.21l";
measurements    = "E1epoch_479420.txt"
[ephm info units] = getrinexephGal(ememerids);
[meas, tow]       = GetRecieverMeasurements(measurements);

prn     = 1;
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

% position from bancroft algorithm, calculated in part A2
X_bancroft = [4364607;  500456; 4609115];% [m]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part B1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% select only the relevant ephemera and measurements
SVprn1 = [2, 7, 8, 11, 25, 30, 36]; % all satellites
[ephm1, meas1] = SelectEphmMeas(ephm, meas, tow, SVprn1);

% preparation (initial guesses)
P  = eye(length(SVprn1)); % weights matrix
X0 = X_bancroft; % [m]

% calculate the receiver position
[X1, DOPs] = LinObsFilter(X0, ephm1, meas1, P, SVprn1, tow);

fprintf("B1)\tthe difference between solutions A2 and B1 is %.1f m\n", sqrt(sum((X_bancroft-X1).^2, 1)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part B2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf("B2)\tthe values of the DOPs are as follows:\n")
fprintf("\tGDOP = %.2f\n",DOPs(1))
fprintf("\tPDOP = %.2f\n",DOPs(2))
fprintf("\tHDOP = %.2f\n",DOPs(3))
fprintf("\tVDOP = %.2f\n",DOPs(4))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part B3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ell1 = xyz2plh(X1);
fprintf("B3)\tthe calculated position is:\n\t%.6f deg\n\t%.6f deg\n\t%.1f m\n", rad2deg(ell1(1)), rad2deg(ell1(2)), ell1(3));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part B4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% select only the relevant ephemera and measurements
SVprn4 = [7, 11, 25, 30];
[ephm4, meas4] = SelectEphmMeas(ephm, meas, tow, SVprn4);

% preparation (initial guesses)
P  = eye(length(SVprn4)); % weights matrix
X0 = X_bancroft; % [m]

% calculate the receiver position
[X4, DOPs, Xk4] = LinObsFilter(X0, ephm4, meas4, P, SVprn4, tow);

ell4 = xyz2plh(X4);
fprintf("B4)\tthe difference between solutions A2 and B4 is %.1f m\n", sqrt(sum((X_bancroft-X4).^2, 1)));
fprintf("\tthe calculated position is:\n\t%.6f deg\n\t%.6f deg\n\t%.1f m\n", rad2deg(ell4(1)), rad2deg(ell4(2)), ell4(3));

fprintf("\tthe values of the DOPs are as follows:\n")
fprintf("\tGDOP = %.2f\n",DOPs(1))
fprintf("\tPDOP = %.2f\n",DOPs(2))
fprintf("\tHDOP = %.2f\n",DOPs(3))
fprintf("\tVDOP = %.2f\n",DOPs(4))
