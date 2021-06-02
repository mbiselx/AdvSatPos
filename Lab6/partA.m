clear
clc

addpath(".//functions")
datapath = ".//E1E5a//";

% navigation data file
% filename = "EPFL043I.21l";
% [ephm info units] = getrinexephGal(strcat(datapath, filename));


% observations data files
load(strcat(datapath, 'datam.mat'));
load(strcat(datapath, 'datar.mat'));

% constants
assgnd_base_prn = 7;            % [PRN]
c               = 299792458;    % [m s^-1]
F0              = 1.023e6;      % [Hz]
F_E1            = 154;          % [-]
F_E5a           = 115;          % [-]

l_E1            = c/F0/F_E1;
l_E5a           = c/F0/F_E5a;

obsw            = [0.5 0.5 0.01 0.01].^-2;

%% code and phase differencing observations
% data is set up as [TOW(s) PRN P1X(m) P5X(m) L1X(cyc.) L5X(cyc.)]
% P denotes code range
% L denotes phase cycles

% Step 0: transform everything into meters
datam(:,5:6)    = datam(:,5:6).*[l_E1, l_E5a];
datar(:,5:6)    = datar(:,5:6).*[l_E1, l_E5a];


%%------------------------------------------------------------
% Part A: get the double differences and covariance matrix per epoch
[ld, Cd]        = double_difference(datam, datar, assgnd_base_prn, obsw);
