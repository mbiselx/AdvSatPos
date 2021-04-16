% Advanced Satellite Positioning - Lab 3: Acquisition of GPS signal
% Spring 2015

function cor = FFTCorrelation(signal_1, signal_2)
% computed the cross correlation between the two signals, using the FFTCorrelation
% in this function we assume that signals 1 and 2 are the same length

    cor = ifft(fft(signal_1).*conj(fft(signal_2)));

end
