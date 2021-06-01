function [diff2, cov2] = double_difference_matrix(datam, datar, base_PRN, obsw)
    % Step 1: single differencing - difference rover and master
    %           data has format [tow prn obs1 obs2 ...]
    %           assume that datam and datar have equivalent columns, and all observations are in [m]

    epochs = unique(datam(:,1));
    SVprn  = unique(datam(:,2));

    % combine observations into observation vector
    l = zeros(size(datam,1), 2*4);
    l(:,1:2:end) = datam(:,3:end);
    l(:,2:2:end) = datar(:,3:end);
    l = reshape(l', numel(l), 1);

    % Dd for one epoch
    d = -eye(length(SVprn));
    d(:,SVprn == base_PRN) = 1;
    d = d(SVprn ~= base_PRN,:);

    Dd = kron(d, kron(eye(4)./sqrt(obsw), [1,-1]));


    for e = 1:length(epochs)
        l_e = l(4*length(SVprn)*(e-1) + 1: 4*length(SVprn)*e);
    end


    diff2 = 0;
    cov2 = 0;

end
