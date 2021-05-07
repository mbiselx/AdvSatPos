function tri = BPSK_ACF(x)
%--------------------------------------------------------------------------
% Triangular function 
% x : code delay in chips
%--------------------------------------------------------------------------

tri = (1 - abs(x)) .* ((1 - abs(x)) > 0);