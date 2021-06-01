function t = SV_time_correction(t_sv, ephm, SVprn)

    prn     = 1;
    af0     = 2;
    af1     = 3;
    af2     = 4;
    toe     = 13;

    best_ephm = zeros(size(ephm,1), length(SVprn));
    for i = 1:length(SVprn)
        best_ephm(:,i) = SelectEphm(ephm, t_sv(i), SVprn(i));
    end

    dtk     = best_ephm(af0,:) + best_ephm(af1,:).*(t_sv - best_ephm(toe,:)) + ...
              best_ephm(af2,:).*(t_sv - best_ephm(toe,:)).^2;

    t = t_sv - dtk;

end
