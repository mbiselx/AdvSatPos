function [N1_hat, N2_hat] = ClydeGoad_estimation(Nwl, Nif, F1, F2)

    K1 = cellfun("round", Nwl, "UniformOutput", false);
    K2 = cellfun("round", Nif, "UniformOutput", false);

    N2_hat = cellfun(@(k1, k2) {round((F2*k1-k2)/(F1 - F2))}, K1, K2);
    N1_hat = cellfun("plus", K1, N2_hat, "UniformOutput", false);

end
