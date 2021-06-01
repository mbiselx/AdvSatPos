clear
clc

addpath(".//functions")
datapath = ".//E1E5a//";

% navigation data file
filename = "EPFL043I.21l";
[ephm info units] = getrinexephGal(strcat(datapath, filename));


% observations data files
load(strcat(datapath, 'datam.mat'));
load(strcat(datapath, 'datar.mat'));

% constants
c               = 299792458;    % [m s^-1]
we      = 7.2921151467e-5;       % [rad s^-1]
F0              = 10.23e6;      % [Hz]
F_E1            = 154;          % [-]
F_E5a           = 115;          % [-]

l_E1            = c/F0/F_E1;
l_E5a           = c/F0/F_E5a;

obsw            = [0.5 0.5 0.01 0.01].^-2;
assgnd_base_prn = 7;            % [PRN]
Xm             = [4367900.702, 502906.400, 4605656.478]'; % [m]


%% code and phase differencing observations
% data is set up as [TOW(s) PRN P1X(m) P5X(m) L1X(cyc.) L5X(cyc.)]
% P denotes code range
% L denotes phase cycles

% Step 0: transform everything into meters
datam(:,5:6)    = datam(:,5:6).*[l_E1, l_E5a];
datar(:,5:6)    = datar(:,5:6).*[l_E1, l_E5a];

obsm = mat2cell(datam, sum(datam(:,1) == unique(datam(:,1))'),size(datam,2));
obsr = mat2cell(datar, sum(datar(:,1) == unique(datar(:,1))'),size(datar,2));

%%------------------------------------------------------------
% Part A: get the double differences and covariance matrix per epoch
[ld, Cd]        = double_difference(datam, datar, assgnd_base_prn, obsw);

%%------------------------------------------------------------
% Part B: recursively estimate the ambiguities N1 and N2
[N1, N2]        = dd_AmbiguityEstimate(ld, F0*F_E1, F0*F_E5a, obsw);

%%------------------------------------------------------------
% Part C: estimate the baseline vector via a least-square adjustment
[X_r, X_rm, s_x]= ddLinObsFilter(obsm, obsr, ephm, ...
                                 ld, Cd, N1, N2, ...
                                 F0*F_E1, F0*F_E5a, ...
                                 Xm, assgnd_base_prn, 10:121,
                                 false, true);

%%------------------------------------------------------------
% plot results
X_rm = cell2mat(X_rm')';
X_rm0 = mean(X_rm);
dX_rm = 1000*(X_rm - X_rm0); % make zero-mean, so as not to explode the plot

m_coords = xyz2plh(Xm');
m_coords(1:2) = rad2deg(m_coords(1:2))
r_coords = xyz2plh(X_r{end}');
r_coords(1:2) = rad2deg(r_coords(1:2))


figure()
plot3(dX_rm(:,1), dX_rm(:,2), dX_rm(:,3))
axis("equal")
xlabel("x [mm]")
ylabel("y [mm]")
zlabel("z [mm]")
title("position around mean")
grid on
rotate3d on;
