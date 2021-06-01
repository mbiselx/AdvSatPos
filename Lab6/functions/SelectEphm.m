function [ephm, SVidx] = SelectEphm(ephemerids, tow, SVprn = 0)

    prn = 1;
    toe = 13;

    if (SVprn == 0)
        SVprn = unique(ephemerids(prn,:));
    end

    SVidx = zeros(size(SVprn));
    for sv = SVprn
        eidx = find( ephemerids(prn,:) == sv);
        m = max( ephemerids(toe, eidx(ephemerids(toe, eidx) <= tow) ));   % the past time clostest to tow
        if isempty(m) error(sprintf('No ephemerids found for SV%d before %.3f s.', sv, tow)); end
        SVidx(1,SVprn == sv) = eidx(ephemerids(toe,eidx) == m);
    end

    ephm = ephemerids(:,SVidx);

end
