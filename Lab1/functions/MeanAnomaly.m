function M = MeanAnomaly(MeanAnomaly0, SqrtA, Time0, t)

    % constants
    GM = 3.986005e14      ;    % [m^3 / s^2] Earth gravitation constant

    w = sqrt(GM) ./ SqrtA.^3;
    M = MeanAnomaly0 + w.*(t-Time0);

end
