function [ephm, meas] = SelectEphmMeas(ephemerids, measurements, tow, SVprn)

    prn = 1;
    toe = 13;

    SVidx = zeros(2,size(SVprn,2));
    for sv = SVprn
        % ephemera
        eidx = find( ephemerids(prn,:) == sv);
        m = max( ephemerids(toe, eidx(ephemerids(toe, eidx) <= tow) ));   % the past time clostest to tow
        SVidx(1,SVprn == sv) = eidx(ephemerids(toe,eidx) == m);

        % measurements
        SVidx(2,SVprn == sv) = find( measurements(prn,:) == sv );
    end
    
    ephm = ephemerids(:,SVidx(1,:));
    meas = measurements(:,SVidx(2,:));

end
