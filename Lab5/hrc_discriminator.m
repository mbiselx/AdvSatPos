function discr = hrc_discriminator(settings, multipath_delay, multipath_phase)
    %--------------------------------------------------------------------------
    % Discriminator function
    % spacing : early-late spacings in chips
    % amplitude : Signal-to-multipath amplitude ratio
    % delay : multipath delay in chips
    % phase: multipath phase in radian
    %--------------------------------------------------------------------------

    %% Select the ACF function ------------------------------------------------
    if strcmpi(settings.modulation, 'BPSK')
        corr_fun = @BPSK_ACF;
    elseif strcmpi(settings.modulation, 'BOC11')
        corr_fun = @BOC11_ACF;
    end


    %% Compute the discriminator ouput of the LOS signal ----------------------
    I_P  = corr_fun(settings.dtau);
    I_E  = corr_fun(settings.dtau - settings.spacing/2);
    I_L  = corr_fun(settings.dtau + settings.spacing/2);
    I_VE = corr_fun(settings.dtau - settings.spacing);
    I_VL = corr_fun(settings.dtau + settings.spacing);

    %discr_LOS = I_P.*(I_E - I_L);
    %discr_LOS = discr_LOS/max(abs(discr_LOS));

    %% Compute the discriminator ouput of the total signal --------------------
    multipath_P  = zeros(length(settings.dtau),1);
    multipath_E  = zeros(length(settings.dtau),1);
    multipath_L  = zeros(length(settings.dtau),1);
    multipath_VE = zeros(length(settings.dtau),1);
    multipath_VL = zeros(length(settings.dtau),1);


    if settings.multipath

        multipath_P = settings.MSAR*corr_fun(settings.dtau ...
            - multipath_delay)* ...
            (exp(1i*(multipath_phase)));

        multipath_E = settings.MSAR*corr_fun(settings.dtau - settings.spacing/2 ...
            - multipath_delay)* ...
            (exp(1i*(multipath_phase)));

        multipath_L = settings.MSAR*corr_fun(settings.dtau + settings.spacing/2 ...
            - multipath_delay)* ...
            (exp(1i*(multipath_phase)));

        multipath_VE = settings.MSAR*corr_fun(settings.dtau - settings.spacing ...
            - multipath_delay)* ...
            (exp(1i*(multipath_phase)));

        multipath_VL = settings.MSAR*corr_fun(settings.dtau + settings.spacing ...
            - multipath_delay)* ...
            (exp(1i*(multipath_phase)));

    end

    I_P_total  = I_P  + real(multipath_P);
    I_E_total  = I_E  + real(multipath_E);
    I_L_total  = I_L  + real(multipath_L);
    I_VE_total = I_VE + real(multipath_VE);
    I_VL_total = I_VL + real(multipath_VL);

    %discr_total = I_P_total.*(I_E_total - I_L_total);

    discr_total = I_E_total - I_L_total - 0.5*(I_VE_total - I_VL_total);
    discr = discr_total/max(abs(discr_total));




end
