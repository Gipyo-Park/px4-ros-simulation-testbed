function x_ = calculate_dynamics(p, q, r, u_p, u_q, u_r)

    % Load symbolic expressions from the base workspace
    X_dot = evalin('base', 'X_dot');
    
    p_dot = X_dot(10);
    q_dot = X_dot(11);
    r_dot = X_dot(12);

    f = [p_dot;q_dot;r_dot];

    % Evaluate the symbolic expressions at the given values
    % p_dot = double(subs(p_dot, {'p', 'q', 'r','u_p', 'u_q', 'u_r'},{p, q, r, u_p, u_q, u_r}));
    % q_dot = double(subs(q_dot, {'p', 'q', 'r','u_p', 'u_q', 'u_r'},{p, q, r, u_p, u_q, u_r}));
    % r_dot = double(subs(r_dot, {'p', 'q', 'r','u_p', 'u_q', 'u_r'},{p, q, r, u_p, u_q, u_r}));
    x_ = double(subs(f, {'p', 'q', 'r','u_p', 'u_q', 'u_r'},{p, q, r, u_p, u_q, u_r}));
end