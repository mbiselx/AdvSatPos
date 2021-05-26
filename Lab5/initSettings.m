function [settings] = initSettings

% To be modified by the Student in every Exercise

% Select the signal modulation, it should be BPSK or BOC11
settings.modulation = 'BPSK';

% Select the early-late spacing, 0<spacing<1 (d)
settings.spacing = 1;                                  % [chips]

% Select the code delay span and steps
settings.delay_step = 0.001;                             % [chips]
settings.dtau = -2:settings.delay_step:2;                % [chips]

% Enable or disable multipath: 1 enable, 0 disable.
settings.multipath = 1;

% Select the Multipath to Signal Amplitude Ration [MSAR]
settings.MSAR = 0.6;

% Select the Multipath Delay
settings.multipath_delay = 0.5;                          % [chips]

% Select the Multipath Phase
settings.multipath_phase = 0;                             % [rad]



%% Validate settings ------------------------------------------------------

if strcmpi(settings.modulation, 'BPSK')==0 && strcmpi(settings.modulation, 'BOC11') == 0
    fprintf(2, 'Invalid modulation type.\n');
    clear all;
    return
end

if settings.spacing > 1
    fprintf(2, 'Invalid Early-Late spacing (must be =< 1).\n');
    clear all;
    return
end

if (settings.multipath ~= 1) && (settings.multipath ~= 0)
    fprintf(2, 'Invalid Multipath settingstings (Must be 0 or 1).\n');
    clear all;
    return
end

if (settings.MSAR > 1)
    fprintf(2, 'Invalid MSAR (must be < 1).\n');
    clear all;
    return
end

% if (settings.multipath_phase > 1)
%     fprintf(2, 'Invalid multipath phase (must be betwen 0 or 1).\n');
%     clear all;
%     return
% end

end
