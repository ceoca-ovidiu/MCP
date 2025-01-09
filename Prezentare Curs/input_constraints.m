function [Aineq, bineq] = input_constraints(Nc, Np, u_prev, du_max, u_max, u_min)
    nu = length(u_prev);
    % Constraints on input changes (Delta U)
    Aineq = [eye(Nc * nu); -eye(Nc * nu)];
    bineq = [repmat(du_max, Nc * nu, 1); repmat(du_max, Nc * nu, 1)];
    
    % Saturation constraints on inputs
    Aineq = [Aineq; kron(eye(Nc), [1; -1])];
    bineq = [bineq; repmat(u_max - u_prev, Nc, 1); repmat(u_prev - u_min, Nc, 1)];
end