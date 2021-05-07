function acqResults = acquisition_s2(longSignal, settings)
% Function performs cold start acquisition on the collected "data". It
% searches for GPS signals of all satellites, which are listed in field
% "acqSatelliteList" in the settings structure. Function saves code phase
% and frequency of the detected signals in the "acqResults" structure.
%
% acqResults = acquisition(longSignal, settings)
%
%   Inputs:
%       longSignal    - 11 ms of raw signal from the front-end
%       settings      - Receiver settings. Provides information about
%                       sampling and intermediate frequencies and other
%                       parameters including the list of the satellites to
%                       be acquired.
%   Outputs:
%       acqResults    - Function saves code phases and frequencies of the
%                       detected signals in the "acqResults" structure. The
%                       field "carrFreq" is set to 0 if the signal is not
%                       detected for the given PRN number.

%--------------------------------------------------------------------------
%                        SoftGNSS for ENV-542 Course v1.0
%                           (Based on SoftGNSS v3.0)
%
%   Copyright (C) Darius Plausinaitis and Dennis M. Akos
%   Written by Darius Plausinaitis and Dennis M. Akos
%   Based on Peter Rinder and Nicolaj Bertelsen
%
%   Modified by Vincenzo Capuanno, Miguel A. Ribot (ESPLAB-EPFL), 2014.
%
%--------------------------------------------------------------------------
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>
%--------------------------------------------------------------------------

%% Initialization =========================================================


% %--- Initialize acqResults ------------------------------------------------
% % % Carrier frequencies of detected signals
%acqResults.carrFreq     = zeros(1, 32);
% % % C/A code phases of detected signals
%acqResults.codePhase    = zeros(1, 32);
% % % Correlation peak ratios of the detected signals
%acqResults.peakMetric   = zeros(1, 32);

fprintf('(');

% Perform search for all listed PRN numbers ...
for PRN = settings.acqSatelliteList
    
     acqResults_std(PRN)  = acquisition_PRN_student( PRN, settings, longSignal );

end    % for PRN = satelliteList

     acqResults.carrFreq=[acqResults_std.carrFreq];
     acqResults.codePhase=[acqResults_std.codePhase];
     acqResults.peakMetric=[acqResults_std.peakMetric];
     

%=== Acquisition is over ==================================================
fprintf(')\n');
