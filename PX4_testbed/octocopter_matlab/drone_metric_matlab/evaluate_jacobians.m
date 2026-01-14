function [df_dx_val, df_du_val] = evaluate_jacobians(x, y, z, u, v, w, phi, theta, psi, p, q, r)

    % Load symbolic expressions from the base workspace
    df_dx = evalin('base', 'df_dx');
    df_du = evalin('base', 'df_du');
    
    % Evaluate the symbolic expressions at the given values
    df_dx_val = double(subs(df_dx, {'x', 'y', 'z', 'u', 'v', 'w', 'phi', 'theta', 'psi', 'p', 'q', 'r'},{x, y, z, u, v, w, phi, theta, psi, p, q, r}));
    df_du_val = double(subs(df_du, {'x', 'y', 'z', 'u', 'v', 'w', 'phi', 'theta', 'psi', 'p', 'q', 'r'},{x, y, z, u, v, w, phi, theta, psi, p, q, r}));
end