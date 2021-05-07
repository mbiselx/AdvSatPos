function codeSampled = generateGoldCodeSampled (PRN, fs, fc, T)
% generateGoldCodeSampled.m generates one of the 32 GPS satellite Gold codes.
%
% codeSampled = generateGoldCodeSampled (PRN, fs, fc, T)
%
%   Inputs :
%       PRN             - PRN number of the sequence
%       fs              - sampling frequency (Hz)
%       fc              - chipping rate (chip/s)
%       T               - length of the code (ms)
%
%   Output :
%       codeSampled     - vector containing the code sampled

    % Constants
    NCO_MAX_VALUE = 4294967296;                                                         % Maximum value of a NCO of 32 bits
    NCO_FREQ_TO_INC_FACTOR = NCO_MAX_VALUE / fs;                                        % Conversion factor
    NCOIncrement = round(fc * NCO_FREQ_TO_INC_FACTOR);                                  % NCO increment
    N = fs * T / 1000;                                                                  % Number of samples for T ms

    % Generate the code
%    load('Gold_codes.mat');                                                             % Load all the Gold codes
    code = generateCAcode(PRN);                                                         % Take the code wanted

    % Generate the code NCO values and codeReplica
    NCOValue = NaN(1, N);
    chip = NaN(1, N);

    NCOValue(1) = 0;                                                                    % The NCO starts at 0
    chip(1) = 1;                                                                        % First chip
    for n = 2:N                                                                         % For each sample
        if NCOValue(n-1) <= (NCO_MAX_VALUE-1 - NCOIncrement)                            % If there will not be an overflow
            NCOValue(n) = NCOValue(n-1) + NCOIncrement;                                 % We add the increment
            chip(n) = chip(n-1);                                                        % The chip stays the same
        else                                                                            % If there will be an overflow
            NCOValue(n) = NCOValue(n-1) - NCO_MAX_VALUE + NCOIncrement;                 % We compute the new value
            if chip(n-1) == 1023                                                        % The chip is incremented
                chip(n) = 1;
            else
                chip(n) = chip(n-1) + 1;
            end
        end
    end
    codeSampled = code(chip);                                                           % Get code sampled

end