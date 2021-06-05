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
F0              = 10.23e6;      % [Hz]
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
% Part A:
disp("Double differencing of observations ...")

% get the double differences and covariance matrix per epoch
[ld, Cd]        = double_difference(datam, datar, assgnd_base_prn, obsw);


%%------------------------------------------------------------
% Part B:
disp("Determining ambiguities, using Clyde Goad method ...")

% B1 recursively determine ddN1 and ddN2
[N1, N2] = double_difference_ambiguity(ld, l_E1, l_E5a, obsw);

% B2 calculate wide-lane and iono-free ambiguities
[Nwl, Nif] = widelane_ambiguities(N1, N2, F_E1, F_E5a);

% B3 using the Clyde Goad method, evaluate
[N1_hat, N2_hat] = ClydeGoad_estimation(Nwl, Nif, F_E1, F_E5a);

% Output 4 & self check: ambiguity values usig all observations from all epochs:
fprintf("Base SV: %d\n", assgnd_base_prn)
for k = 1:length(N1{end})
    fprintf("DD(%2d-%2d):\tN1 =%6.1f (%4d)\tN2 =%6.1f (%4d)\tNwl =%6.1f\n", ...
        assgnd_base_prn, ld{end}(k,2), ...
        N1{end}(k), N1_hat{end}(k), ...
        N2{end}(k), N2_hat{end}(k), ...
        Nwl{end}(k))
end

% Output 5: plots of the wide-lane ambiguity evolution
N_wl = cell2mat(Nwl');
figure(1)
for k = 1:length(N1{end})
    subplot(3,2, k)
    plot(N_wl(k,:))
    title(sprintf("N_{WL (%d-%d)}", assgnd_base_prn, ld{end}(k,2)))
    xlabel("[epochs]")
    ylabel("[cycles]")
end

% B4 Analyze the differential delay of the ionosphere over epochs
I = dd_iono_delay(ld, N1_hat, N2_hat, F_E1, F_E5a, l_E1, l_E5a);
I = cell2mat(I');
figure(2)
for k = 1:length(N1{end})
    subplot(3,2, k)
    plot(1e3*I(k,:))
    title(sprintf("Ionospheric phase delay for SV pair (%d-%d)", assgnd_base_prn, ld{end}(k,2)))
    xlabel("[epochs]")
    ylabel("delay [mm]")
end
