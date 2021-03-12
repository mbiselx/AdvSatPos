function M = CorrectedMeanAnomaly(MeanAnomaly0, SqrtA, Time0, delta_n, t)

    # constants
    GM = 3.986005e14      ;    # [m^3 / s^2] Earth gravitation constant

    w = sqrt(GM) ./ SqrtA.^3 + delta_n;
    M = MeanAnomaly0 + w.*(t-Time0);

end
