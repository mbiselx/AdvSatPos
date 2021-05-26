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

obsw            = [0.5 0.5 0.01 0.01].^2;

%% code and phase differencing observations
% data is set up as [TOW(s) PRN P1X(m) P5X(m) L1X(cyc.) L5X(cyc.)]
% P denotes code range
% L denotes phase cycles

% Step 0: transform everything into meters
datam(:,5:6)    = datam(:,5:6).*[l_E1, l_E5a];
datar(:,5:6)    = datar(:,5:6).*[l_E1, l_E5a];

% Part A: get the double differences and covariance matrix per epoch
[ld, Cd]        = double_difference(datam, datar, assgnd_base_prn);

% Part B:
% B1

% Step 1: form Normals equation (assuming neglectible Ionospheric delay for short baslines (i.e. < 5km difference))
P               = diag(1./obsw);
Ae              = [ones(4,1), [zeros(2); diag([l_E1, l_E5a])]];

N = Ae'*P*Ae;
B = Ae'*P;
b = cellfun(@(l) {B*l(:, 3:6)'}, ld);

% for k = 1:length(ld)
%     b{k} = Ae'*P*ld{k};
% end
% for k = 1:length(ld)
%     x{k} = Ae'*P*ld{k} * inv(Ae'*P*Ae);
% end

% Step 2: Elimination of rho
N22_inv = inv(N(2:3, 2:3) - N(1,2:3)*N(2:3,1)/N(1,1));
b21 = cellfun(@(bb) {bb(2,:) - N(2:3,1)*bb(1,:)/N(1,1)}, b);

x = cellfun(@(bb) {N22_inv*bb}, b21)













% A = [1               1      0       0;
%      1  (F_E1/F_E5a)^2      0       0;
%      1              -1   l_E1       0;
%      1 -(F_E1/F_E5a)^2      0   l_E5a];
