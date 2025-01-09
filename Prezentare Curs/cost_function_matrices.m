function [H, f] = cost_function_matrices(Phi, Gamma, Q, R, x0, ref, Np, Nc)
    % Ensure ref has the same size as the state vector
    nx = size(Phi, 2); % Number of states
    ref = ref(1:nx);   % Truncate or align ref to state size

    % Expand reference for all prediction steps
    ref_full = kron(ones(Np, 1), ref);

    % Compute the cost matrices
    Qbar = kron(eye(Np), Q);
    Rbar = kron(eye(Nc), R);
    
    % Quadratic and linear cost terms
    H = Gamma' * Qbar * Gamma + Rbar;
    f = (Phi * x0 - ref_full)' * Qbar * Gamma;
end
