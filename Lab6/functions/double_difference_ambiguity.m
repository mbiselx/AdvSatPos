function [N1, N2] = double_difference_ambiguity(ld, wl1, wl2, obsw)
% recursively determine ddN1 and ddN2
% assumption: we don't lose satellites from one epoch to another
% inputs:
%   ld          cell array containing the double differeced observations
%               [TOW    PRN   P1  P2  L1  L2]
%   wl1, wl2    wavelengths of the two frequencies
%   obsw        weigts of the different observations (usually std(obs)^(-2))

    %   Step 1: form Normals equation (assuming neglectible Ionospheric delay for short baslines (i.e. < 5km difference))
    P       = diag(obsw);
    Ae      = [ones(4,1), [zeros(2); diag([wl1, wl2])]];

    N       = Ae'*P*Ae;
    B       = Ae'*P;
    b       = cellfun(@(l) {B*l(:, 3:6)'}, ld);

    %   Step 2: Elimination of rho
    N22     = (N(2:3, 2:3) - N(2:3,1)*N(1,2:3)/N(1,1));
    b21     = cellfun(@(bb) {bb(2:3,:) - N(2:3,1)*bb(1,:)/N(1,1)}, b);

    %   Step 3: recursively calculate ddNs for each epoch
    N1      = cell(size(b21));
    N2      = cell(size(b21));
    bt      = zeros(2,1);
    Nt      = zeros(2);
    for t =  1:length(b21)
        bt = bt + b21{t};   % accumulate for recusivity !!!! assumption: we don't lose satellites from one epoch to another
        Nt = Nt + N22;      % accumulate for recusivity
        x = inv(Nt) * bt;
        N1{t} = x(1,:)';
        N2{t} = x(2,:)';
    end

end
