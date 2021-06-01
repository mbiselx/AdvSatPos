function ddI = dd_iono_delay(ld, N1, N2, F1, F2, wl1, wl2)
% calculate the differential delay of the ionosphere over epochs

    mat = (inv([1, -1; 1, -(F1/F2)^2]) * [eye(2), -diag([wl1, wl2])])(2,:)';

    ddI = cellfun(@(l, n1, n2) {[l(:,5:6), n1, n2] * mat}, ld, N1, N2);

end
