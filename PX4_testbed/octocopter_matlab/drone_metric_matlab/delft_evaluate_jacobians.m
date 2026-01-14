function [delft_df_dx_val, delft_df_du_val] = delft_evaluate_jacobians(p, q, r, u_p, u_q, u_r)
    
    coder.extrinsic('evalin');
    coder.extrinsic('subs');
    
    % Load symbolic expressions from the base workspace
    delft_df_dx = evalin('base', 'delft_df_dx');
    delft_df_du = evalin('base', 'delft_df_du');

    
    % Evaluate the symbolic expressions at the given values
    delft_df_dx_val = double(subs(delft_df_dx, {'p', 'q', 'r', 'u_p', 'u_q', 'u_r'},[p, q, r, u_p, u_q, u_r]));
    delft_df_du_val = double(subs(delft_df_du, {'p', 'q', 'r', 'u_p', 'u_q', 'u_r'},[p, q, r, u_p, u_q, u_r]));
end