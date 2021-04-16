%  Advanced Satellite Positioning - Lab 3: Acquisition of GPS signal
%  Spring 2015

function settings = initSettings()
% This function initializes and saves settings. Settings can be edited
% inside of the function, updated from the command line or updated using
% a dedicated GUI - "setSettings".
%
% All settings are described inside function code.
%
% settings = initSettings()
%
%   Inputs: none
%
%   Outputs:
%       settings     - Receiver settings (a structure).
%
%--------------------------------------------------------------------------
%                        SoftGNSS for ENV-542 Course v1.0
%                           (Based on SoftGNSS v3.0)
%
%   Copyright (C) Darius Plausinaitis
%   Written by Darius Plausinaitis
%
%   Modified by Vincenzo Capuanno, Miguel A. Ribot (ESPLAB-EPFL), 2014.
%   Last revision: M. A. Ribot 16/03/2015
%
%--------------------------------------------------------------------------
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
% USA.
%--------------------------------------------------------------------------

%% Constants ==============================================================

settings.c                  = 299792458;    % The speed of light, [m/s]
settings.startOffset        = 68.802;       %[ms] Initial sign. travel time


%% Processing settings ====================================================

% Coherent Integration time used in Acquisition:
settings.cohInt             = 10;            %[ms];

%% Raw signal file name and other parameter ===============================
% This is a "default" name of the data file (signal record) to be used in
% the post-processing mode
settings.fileName           = ...
   '../ENV542_GPS_CA_data_capture.bin';
% Data type used to store one sample
settings.dataType           = 'int8';

% Intermediate, sampling and code frequencies
settings.IF                 = 4.5e6;        %[Hz]
settings.samplingFreq       = 6.5e6;        %[Hz]
settings.codeFreqBasis      = 1.023e6;      %[Hz]

% Define number of chips in a code period
settings.codeLength         = 1023;

%% Acquisition settings ===================================================
% Skips acquisition in the script postProcessing.m if set to 1
settings.skipAcquisition    = 0;
% List of satellites to look for. Some satellites can be excluded to speed
% up acquisition
settings.acqSatelliteList   = 1:32;         %[PRN numbers]
% Band around IF to search for satellite signal. Depends on max Doppler
settings.acqSearchBand      = 20;           %[kHz]
% Threshold for the signal presence decision rule
settings.acqThreshold       = 2.5;
% Acquistion frequency step
settings.acqFreqstep        = (2/3)/(settings.codeLength/settings.codeFreqBasis)*1e-3; %[kHz]
