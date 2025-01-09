function [Phi, Gamma] = predict_matrices(A, B, Np)
    nx = size(A, 1);
    nu = size(B, 2);
    Phi = zeros(Np * nx, nx);
    Gamma = zeros(Np * nx, Np * nu);

    for i = 1:Np
        Phi((i-1)*nx+1:i*nx, :) = A^i;
        for j = 1:i
            Gamma((i-1)*nx+1:i*nx, (j-1)*nu+1:j*nu) = A^(i-j) * B;
        end
    end
end