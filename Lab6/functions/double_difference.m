function [diff2, cov2] = double_difference(datam, datar, base_PRN)
    % Step 1: single differencing - difference rover and master
    %           data has format [tow prn obs1 obs2 ...]
    %           assume that datam and datar have equivalent columns, and all observations are in [m]
    diff1           = [datam(:,1:2), datam(:,3:end) - datar(:,3:end)];

    % Step 2: separate observation differences into base and supplemental SVs
    base_idx        = (diff1(:,2) == base_PRN);
    base_diff1      = diff1( base_idx, :);
    other_diff1     = diff1(~base_idx, :);

    % step 3: double difference - difference between base SV and other SVs
    diff2           = cell(size(base_diff1,1),1);      % preallocate memory
    cov2            = cell(size(base_diff1,1),1);

    for epoch = 1:size(base_diff1,1) % for every epoch
        % determine parameters (in case the number of satellites changes over time)
        %       assume that at least some satellites are available at every epoch
        idx         = (other_diff1(:,1) == base_diff1(epoch,1));
        prns        = unique([base_PRN; other_diff1(idx, 2)]);

        % second differenciation for epoch
        diff2(epoch)= [other_diff1(idx,1:2), base_diff1(epoch,3:end) - other_diff1(idx,3:end)];

        % covariance matrix for epoch
        cov2(epoch) = 2*ones(length(prns)-1) + 2*eye(length(prns)-1);
    end

end
