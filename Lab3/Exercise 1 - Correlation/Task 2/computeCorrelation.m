%  Advanced Satellite Positioning - Lab 3: Acquisition of GPS signal
%  Spring 2015

function cor = computeCorrelation(signal_1, signal_2)
% computes the correlation of two signals
% the first signal is assumed to be the longer singal, the second is assumed
% to be a sample of equal or lesser length
% returns the corr, the vector containing correlation value by shift+1 (because matlab arrays start at 1)

    l1 = length(signal_1);
    l2 = length(signal_2);

    cor = zeros(1, l2);
    for tau = 1:l2
        cor(tau)= sum(signal_1.*repmat(signal_2, 1, ceil(l1/l2))(1:l1));
        signal_2 = circshift(signal_2, 1);
    end

end
