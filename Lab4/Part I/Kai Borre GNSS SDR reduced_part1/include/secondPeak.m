function [ secondPeakSize ] = secondPeak( results, frequencyBinIndex, codePhase, settings )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

%--------------------------------------------------------------------------
%                        SoftGNSS for ENV-542 Course v1.0 
%                           (Based on SoftGNSS v3.0)
% 
%   Copyright (C) Darius Plausinaitis
%   Written by Darius Plausinaitis, Dennis M. Akos
%   Some ideas by Dennis M. Akos
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
%-------------------------------------------------------------------------

% Find number of samples per spreading code
samplesPerCode = round(settings.samplingFreq / ...
    (settings.codeFreqBasis / settings.codeLength));

%--- Find 1 chip wide C/A code phase exclude range around the peak ----
samplesPerCodeChip   = round(settings.samplingFreq / settings.codeFreqBasis);
excludeRangeIndex1 = codePhase - samplesPerCodeChip;
excludeRangeIndex2 = codePhase + samplesPerCodeChip;

%--- Correct C/A code phase exclude range if the range includes array
%boundaries
if excludeRangeIndex1 < 2
    codePhaseRange = excludeRangeIndex2 : ...
        (samplesPerCode + excludeRangeIndex1);
    
elseif excludeRangeIndex2 >= samplesPerCode
    codePhaseRange = (excludeRangeIndex2 - samplesPerCode) : ...
        excludeRangeIndex1;
else
    codePhaseRange = [1:excludeRangeIndex1, ...
        excludeRangeIndex2 : samplesPerCode];
end

%--- Find the second highest correlation peak in the same freq. bin ---
secondPeakSize = max(results(frequencyBinIndex, codePhaseRange));

end

