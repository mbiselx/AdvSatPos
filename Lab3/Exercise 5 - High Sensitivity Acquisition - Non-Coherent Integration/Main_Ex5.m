%  Advanced Satellite Positioning - Lab 3: Acquisition of GPS signal
%  Spring 2016

% Script Main_Ex5.m processes the raw signal from the specified data
% file (in settings).
% It runs acquisition code identifying the satellites in the file.

%--------------------------------------------------------------------------
%                  SoftGNSS "reduced" for ENV-542 Course v1.0
%                       (Based on SoftGNSS v3.0)
%
%   Copyright (C) Darius Plausinaitis
%   Written by Darius Plausinaitis, Dennis M. Akos
%   Some ideas by Dennis M. Akos
%
%   Modified by Vincenzo Capuanno, Miguel A. Ribot (ESPLAB-EPFL), 2014.
%   Last revision: M. A. Ribot 31/03/2016
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

%% Initialization =========================================================
close all
disp ('Starting processing...');
addpath('./include');

% Load settings using initSettings() function
settings=initSettings();

[fid, message] = fopen(settings.fileName, 'rb');

%If success, then process the data
if (fid > 0)

%% Acquisition ============================================================

    % Find number of samples per spreading code
    samplesPerCode = round(settings.samplingFreq / ...
        (settings.codeFreqBasis / settings.codeLength));

    % Read data for acquisition. 11ms of signal are needed for the fine
    % frequency estimation
    data = fread(fid, settings.cohInt*samplesPerCode, settings.dataType)';
    
    %--- Do the acquisition -------------------------------------------
    disp ('   Acquiring satellites...');

% ########################################################################
%% TO BE COMPLETED BY THE STUDENTS:
%  Write your code here
    acqResults = acquisition_Tncoh(settings, data);

    plotAcquisition(acqResults);

else
    % Error while opening the data file.
    error('Unable to read file %s: %s.', settings.fileName, message);
end % if (fid > 0)
