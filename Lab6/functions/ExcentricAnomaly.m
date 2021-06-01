function E = ExcentricAnomaly(MeanAnomaly, Excetricity, epsilon=1e-11)
    % iteratively computes the excentric anomaly from a given mean anomaly
    %   MeanAnomaly : mean anomaly to calculate excentric anomaly from
    %   epsilon     : precision at which we stop iterating

    i = 0;
    preE = MeanAnomaly;                         # first iteration
    E = Excetricity .* sin(preE) + MeanAnomaly;

    while (any(abs(E - preE) > epsilon) && (i < 100))
        preE = E;
        E = Excetricity .* sin(preE) + MeanAnomaly;
        i++;
    end

    if (i >= 100)
        error('Inft. loop detected, breaking off');
    end

end
