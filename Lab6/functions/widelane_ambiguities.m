function [Nwl, Nif] = widelane_ambiguities(N1, N2, F1, F2)
% calculate wide-lane and iono-free ambiguities
    % inputs:
    %   N1, N2    the two calculated ambiguities
    %   F1, F2    the two frequencies

    Nwl = cellfun("minus", N1, N2, "UniformOutput", false); %N1 - N2;
    Nif = cellfun(@(n1, n2) {F2*n1 - F1*n2}, N1, N2); %(F_E5a*N1 - F_E1*N2);

end
