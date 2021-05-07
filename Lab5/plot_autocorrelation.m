
%% Select the ACF function ------------------------------------------------
if strcmpi(settings.modulation, 'BPSK')
    corr_fun = @BPSK_ACF;
elseif strcmpi(settings.modulation, 'BOC11')
    corr_fun = @BOC11_ACF;
end

%% Compute the ACF of the LOS ---------------------------------------------
corr_LOS = corr_fun(settings.dtau);

%% Compute the ACF of the Multipath component -----------------------------
if settings.multipath
    corr_multipath = settings.MSAR*corr_fun(settings.dtau-settings.multipath_delay)* ...
        real(exp(1j*(settings.multipath_phase)));
end

%% Compute the Total ACF signal -------------------------------------------
corr = corr_LOS + corr_multipath;
                   

%% Plot results -----------------------------------------------------------
close all

% Create figure
hfig = figure;

% Create axes
axes1 = axes('Parent',hfig,'YGrid','on','XGrid','on');
box(axes1,'on');
hold(axes1,'all');
plot(settings.dtau,corr_LOS,'Parent',axes1,'LineWidth',2,'DisplayName','LOS')
hold on
plot(settings.dtau,corr_multipath,'r','Parent',axes1,'LineWidth',2,'DisplayName','Multipath')
plot(settings.dtau,corr,'g','Parent',axes1,'LineWidth',2,'DisplayName','Total')

% Create axes labels
xlabel('Code Delay [Chips]');
ylabel('Normalized Amplitude');

% Create legend
legend(axes1,'show');

% Create title
title({'Autocorrelation Function'});
hold off
