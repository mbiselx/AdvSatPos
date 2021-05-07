
%% Select the ACF function ------------------------------------------------
if strcmpi(settings.modulation, 'BPSK')
    corr_fun = @BPSK_ACF;
elseif strcmpi(settings.modulation, 'BOC11')
    corr_fun = @BOC11_ACF;
end


%% Compute the discriminator ouput of the LOS signal ----------------------
I_P = corr_fun(settings.dtau);
I_E = corr_fun(settings.dtau - settings.spacing/2);
I_L = corr_fun(settings.dtau + settings.spacing/2);

discr_LOS = 0.5*I_P.*(I_E - I_L);
discr_LOS = discr_LOS/max(abs(discr_LOS));

%% Compute the discriminator ouput of the total signal --------------------
multipath_E = zeros(length(discr_LOS),1);
multipath_L = zeros(length(discr_LOS),1);
multipath_P = zeros(length(discr_LOS),1);

if settings.multipath
    
    multipath_E = settings.MSAR*corr_fun(settings.dtau - settings.spacing/2 ...
        - settings.multipath_delay)* ...
        cos(settings.multipath_phase);
    
    multipath_L = settings.MSAR*corr_fun(settings.dtau + settings.spacing/2 ...
        - settings.multipath_delay)* ...
        cos(settings.multipath_phase);
    
    multipath_P = settings.MSAR*corr_fun(settings.dtau ...
        - settings.multipath_delay)* ...
        cos(settings.multipath_phase);
end

I_P_total = I_P + multipath_P;
I_E_total = I_E + multipath_E;
I_L_total = I_L + multipath_L;

discr_total = 0.5.*I_P_total.*(I_E_total - I_L_total);
%discr_total = (I_E_total - I_L_total);

discr_total = discr_total/max(abs(discr_total));


%% Plot results -----------------------------------------------------------
close all

% Create figure
hfig = figure;

% Create axes
axes2 = axes('Parent',hfig,'YGrid','on','XGrid','on');
box(axes2,'on');
hold(axes2,'all');
xlim(axes2,[-1.5 1.497]);

plot(settings.dtau,discr_LOS,'Parent',axes2,'LineWidth',2,'DisplayName','LOS')
plot(settings.dtau,discr_total,'g','Parent',axes2,'LineWidth',2,'DisplayName','Total')

% Create axes labels
xlabel('Code Delay [Chips]');
ylabel('Error [Chips]');

% Create legend
legend(axes2,'show');

% Create title
title({'Discriminator Function'});
hold off
