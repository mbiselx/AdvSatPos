function [X, Y] = OrbitalPlanePosition(MeanAnomaly, SqrtSemiMajorAxis, Excetricity)

    E = ExcentricAnomaly(MeanAnomaly, Excetricity, epsilon=1e-11);

    X = SqrtSemiMajorAxis.^2 .* (cos(E) - Excetricity);
    Y = SqrtSemiMajorAxis.^2 .* sqrt(1-Excetricity.^2).*sin(E);

end
