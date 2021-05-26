function diff2 = double_difference_matrix(datam, datar, base_PRN)
    % Step 1: setup differencing matrix
    prns      = unique(datam(:,2));

    Dd = zeros(length(prns)-1, 2*length(prns));
    Dd(:, logical(kron((prns == base_PRN)', [true, true]))) = kron(ones(length(prns)-1, 1), [1, -1]);
    Dd(:, logical(kron((prns ~= base_PRN)', [true, true]))) = kron(speye(length(prns)-1),  [-1, 1]);
    cov2(epoch) = Dd * Dd';


    % Step 2: double difference - for every epoch
    D = kron(ones(length(unique(datam(:,1)))), Dd)
    % l = D * [datam;] % somehow zip datam and datar ??

end
