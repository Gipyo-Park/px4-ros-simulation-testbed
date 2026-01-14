function [x_dot, y_dot, z_dot, u_dot, v_dot, w_dot,phi_dot,theta_dot,psi_dot,p_dot,q_dot,r_dot] = calculate_X_dot(x, y, z, u, v, w, phi, theta, psi, p, q, r,fx,fy,fz,mx,my,mz)

    % Load symbolic expressions from the base workspace
    X_dot = evalin('base', 'X_dot');
    

    % Evaluate the symbolic expressions at the given values
    X_dot_val = double(subs(X_dot, {'x', 'y', 'z', 'u', 'v', 'w', 'phi', 'theta', 'psi', 'p', 'q', 'r','fx','fy','fz','mx','my','mz'},{x, y, z, u, v, w, phi, theta, psi, p, q, r,fx,fy,fz,mx,my,mz}));
    
    x_dot = X_dot_val(1);
    y_dot = X_dot_val(2);
    z_dot = X_dot_val(3);
    u_dot = X_dot_val(4);
    v_dot = X_dot_val(5);
    w_dot = X_dot_val(6);
    phi_dot = X_dot_val(7);
    theta_dot = X_dot_val(8);
    psi_dot = X_dot_val(9);
    p_dot = X_dot_val(10);
    q_dot = X_dot_val(11);
    r_dot = X_dot_val(12);

end