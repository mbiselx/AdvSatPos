function corr = BOC11_ACF(x)
%--------------------------------------------------------------------------
% Autocorrelation function of the BOC(1,1) signal
% x : code delay in chips
%--------------------------------------------------------------------------

corr = ((1 - 3*abs(x)) .* ((abs(x)) <= 0.5) + (abs(x)-1) .* ((abs(x)) > 0.5)).* ((1 - abs(x)) > 0);