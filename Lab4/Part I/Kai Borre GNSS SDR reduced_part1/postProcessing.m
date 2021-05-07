% Script postProcessing.m processes the raw signal from the specified data
% file (in settings). 
%
% For every data file, a supplementary 'eph_data.mat'
% is required. 'eph_data.mat' must contain the Ephemeris data, subFramestart 
% for every SVN, and TOW for the current data file. In this way, short raw 
% signal captures (i.e. => 1 sec) can generate a navigation solution.   
%
% First it runs acquisition code identifying the satellites in the file,
% then the code and carrier for each of the satellites are tracked
% After processing all satellites in the 
% data block, then postNavigation is called. It calculates pseudoranges
% and attempts a position solutions. At the end plots are made for that
% block of data.

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
%--------------------------------------------------------------------------

%                         THE SCRIPT "RECIPE"
%
% The purpose of this script is to combine all parts of the software
% receiver.
%
% 1.1) Open the data file for the processing and seek to desired point.
%
% 2.1) Acquire satellites
%
% 3.1) Initialize channels (preRun.m).
% 3.2) Pass the channel structure and the file identifier to the tracking
% function. It will read and process the data. The tracking results are
% stored in the trackResults structure. The results can be accessed this
% way (the results are stored each millisecond):
% trackResults(channelNumber).XXX(fromMillisecond : toMillisecond), where
% XXX is a field name of the result (e.g. I_P, codePhase etc.)
%
% 4) Pass tracking results to the navigation solution function. It will
% decode navigation messages, find satellite positions, measure
% pseudoranges and find receiver position.
%
% 5) Plot the results.

%% Initialization =========================================================
disp ('Starting processing...');

[fid, message] = fopen(settings.fileName, 'rb');

%If success, then process the data
if (fid > 0)
    
    % Move the starting point of processing. Can be used to start the
    % signal processing at any point in the data record (e.g. good for long
    % records or for signal processing in blocks).
    fseek(fid, settings.skipNumberOfBytes, 'bof');

%% Acquisition ============================================================

    % Do acquisition if it is not disabled in settings or if the variable
    % acqResults does not exist.
    if ((settings.skipAcquisition == 0) || ~exist('acqResults', 'var'))
        
        % Find number of samples per spreading code
        samplesPerCode = round(settings.samplingFreq / ...
                           (settings.codeFreqBasis / settings.codeLength));
        
        % Read data for acquisition. 11ms of signal are needed for the fine
        % frequency estimation
        data = fread(fid, 11*samplesPerCode, settings.dataType)';

        %--- Do the acquisition -------------------------------------------
        disp ('   Acquiring satellites...');
        acqResults = acquisition_s2(data, settings);

        plotAcquisition(acqResults);
    end

%% Initialize channels and prepare for the run ============================

    % Start further processing only if a GNSS signal was acquired (the
    % field FREQUENCY will be set to 0 for all not acquired signals)
    if (any([acqResults.carrFreq]))
        channel = preRun(acqResults, settings);
        showChannelStatus(channel, settings);
    else
        % No satellites to track, exit
        disp('No GNSS signals detected, signal processing finished.');
        trackResults = [];
        return;
    end
    

%% Track the signal =======================================================
    startTime = now;
    disp (['   Tracking started at ', datestr(startTime)]);

    % Process all channels for given data block
    [trackResults, channel] = tracking(fid, channel, settings);

    % Close the data file
    fclose(fid);
    
    disp(['   Tracking is over (elapsed time ', ...
                                        datestr(now - startTime, 13), ')'])     

    % Auto save the acquisition & tracking results to a file to allow
    % running the positioning solution afterwards.
    disp('   Saving Acq & Tracking results to file "trackingResults.mat"')
    save('trackingResults', ...
                      'trackResults', 'settings', 'acqResults', 'channel');                  

%% Calculate navigation solutions =========================================
%     disp('   Calculating navigation solutions...');
%     navSolutions = postNavigation(trackResults, settings);
% 
%     disp('   Processing is complete for this data block');

%% Plot all results ===================================================
    disp ('   Ploting results...');
    if settings.plotTracking
        plotTracking(1:settings.numberOfChannels, trackResults, settings);
    end

%     plotNavigation(navSolutions, settings);

    disp('Post processing of the signal is over.');

else
    % Error while opening the data file.
    error('Unable to read file %s: %s.', settings.fileName, message);
end % if (fid > 0)
