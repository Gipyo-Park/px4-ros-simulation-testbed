close all, clear all, clc
% -------------------------------------------------------------------------
% Simulation Time
% -------------------------------------------------------------------------
Ts = 0.01;
% Ts_inner = 0.01;
% Ts_outer = 0.01;
Tf = 10;
time = 0:Ts:Tf; time = time';

% -------------------------------------------------------------------------
% Initial Condition
% -------------------------------------------------------------------------
load('Hover_1m');
IC.X = 0;
IC.Y = 0;
IC.Z = 1;

IC.w1 = 2000;
IC.w2 = 2000;
IC.w3 = 2000;
IC.w4 = 2000;
IC.w5 = 2000;
IC.w6 = 2000;
IC.w7 = 2000;
IC.w8 = 2000;

% -------------------------------------------------------------------------
% Position Input
% -------------------------------------------------------------------------
start_time = 5;

% Step
Xd = 0;
Yd = 0;
Zd = 2;
Psid = deg2rad(0);

% Ramp
Vz = 0.1;
stop_time = start_time + (IC.Z - Zd)/Vz;

step_0_ramp_1 = 0;

% -------------------------------------------------------------------------
% Velocity Input
% -------------------------------------------------------------------------
INPUT_MODE_U = 0;
INPUT_MODE_V = 0;
INPUT_MODE_W = 0;

Ud = 0;
Vd = 0;
Wd = 0;

% -------------------------------------------------------------------------
% Attitude Input
% -------------------------------------------------------------------------
INPUT_MODE_PHI = 0;
INPUT_MODE_THETA = 0;

Phid = deg2rad(1);
Thetad = deg2rad(1);

% -------------------------------------------------------------------------
% drone parameter
% -------------------------------------------------------------------------
load('quadModel_X');

cr = 35.5;
b = 516.6;

ct = 5.837e-06;
cq = ct / 1.4865e-07 * 2.9250e-09;

quadModel.cr = cr;
quadModel.b  = b;

quadModel.ct = ct;
quadModel.cq = cq;

l1 = 1.086 / 2;
l2 = 0.720 / 2;
l3 = 2.160 / 2;
quadModel.l1 = l1;
quadModel.l2 = l2;
quadModel.l3 = l3;

quadModel.dctcq = [-ct*l1  +ct*l1  -ct*l1  -ct*l1  +ct*l1  +ct*l1  +ct*l1  -ct*l1
                   -ct*l3  +ct*l3  -ct*l2  +ct*l3  -ct*l3  +ct*l2  -ct*l2  +ct*l2
                   +cq     +cq     -cq     -cq     -cq     -cq     +cq     +cq];

m = 19.78;               
quadModel.mass = m;
Jx = 1.51;
Jy = 7.45;
Jz = 8.88;
quadModel.Jx = Jx;
quadModel.Jy = Jy;
quadModel.Jz = Jz;
quadModel.Jb = [Jx,0,0; 0,Jy,0; 0,0,Jz];
quadModel.Jbinv = inv(quadModel.Jb);

g = quadModel.g;
GO = (sqrt((m*g)/(8*ct))-b)/cr;

% -------------------------------------------------------------------------
% Plant model
% -------------------------------------------------------------------------
Kphi = 16*ct*cr*l1*(cr*GO + b);
num_Gphi = Kphi;
den_Gphi = [Jx 0 0];
Gphi = tf(num_Gphi,den_Gphi);

Ktheta = 8*ct*cr*l3^2*(cr*GO + b);
num_Gtheta = Ktheta;
den_Gtheta = [Jy 0 0];
Gtheta = tf(num_Gtheta,den_Gtheta);

Kpsi = 16*cq*cr*(cr*GO + b);
num_Gpsi = 1;
den_Gpsi = [Jz 0 0];
Gpsi = tf(num_Gpsi,den_Gpsi);

num_Gu = g;
den_Gu = [1 0];
Gu = tf(num_Gu,den_Gu);

num_Gv = g;
den_Gv = [1 0];
Gv = tf(num_Gv,den_Gv);

% Kw = 16*ct*cr*(cr*GO + b);
% num_Gw = Kw;
% den_Gw = [m 0];
% Gw = tf(num_Gw,den_Gw);

num_Gx = 1;
den_Gx = [1 0];
Gx = tf(num_Gx,den_Gx);

num_Gy = 1;
den_Gy = [1 0];
Gy = tf(num_Gy,den_Gy);

Kz = 16*ct*cr*(cr*GO + b);
num_Gz = Kz;
den_Gz = [m 0 0];
Gz = tf(num_Gz,den_Gz);

% num_Gz = 1;
% den_Gz = [1 0];
% Gz = tf(num_Gz,den_Gz);

%K_yawrate

% -------------------------------------------------------------------------
% Theta Controller
% -------------------------------------------------------------------------

Wc_theta = 2*pi;
Zc_theta = 0.707;

Kp_theta = Wc_theta^2*Jy/Ktheta;
Ki_theta = Kp_theta/10;
Kd_theta = 2*Zc_theta*Wc_theta*Jy/Ktheta;

Gc_theta = pid(Kp_theta,Ki_theta,Kd_theta)

% Closed loop system
Go_theta = Gc_theta*Gtheta;
Gcl_theta = feedback(Go_theta, 1);
[num_Gcl_theta, den_Gcl_theta] = tfdata(Gcl_theta, 'v');

% -------------------------------------------------------------------------
% U Controller
% -------------------------------------------------------------------------

% PI Design parameter
Zc_u = 0.707;
Wc_u = 2*pi/5;

% PI Controller design
Kp_u = 2*Zc_u*Wc_u/g;
Ki_u = Wc_u^2/g * 0.7;
Kd_u = Kp_u/50; % extra

% Kp_u = 0.32;
% Ki_u = 0;
% Kd_u = 0.1;

Gc_u = pid(Kp_u,Ki_u,Kd_u)

% Closed loop system
Go_u = Gc_u*Gcl_theta*Gu;
Gcl_u = feedback(Go_u, 1);
[num_Gcl_u, den_Gcl_u] = tfdata(Gcl_u, 'v');

Go_u_approx = Gc_u*Gu;
Gcl_u_approx = feedback(Go_u_approx, 1);

% -------------------------------------------------------------------------
% X Controller
% -------------------------------------------------------------------------

% Design parameter
Wc_x = 2*pi/5/5;
Zc_x = 0.707;

% P Controller design
% Kp_x = Wc_x;
% Ki_x = 0;
% Kd_x = 0;

% PI Controller design
Kp_x = 2*Wc_x*Zc_x;
Ki_x = Wc_x^2 * 0.7;
Kd_x = Kp_x/5; % extra

Gc_x = pid(Kp_x,Ki_x,Kd_x)

% Closed loop system
Go_x = Gc_x*Gcl_u*Gx;
Gcl_x = feedback(Go_x, 1);
[num_Gcl_x, den_Gcl_x] = tfdata(Gcl_x, 'v');

Go_x_approx = Gc_x*Gx;
Gcl_x_approx = feedback(Go_x_approx, 1);

% -------------------------------------------------------------------------
% Phi Controller
% -------------------------------------------------------------------------

Zc_phi = 0.707;
Wc_phi = 2*pi/5;

Kp_phi = Wc_phi^2*Jx/Kphi;
Ki_phi = Kp_phi/10; % extra
Kd_phi = 2*Zc_phi*Wc_phi*Jx/Kphi;

Gc_phi = pid(Kp_phi,Ki_phi,Kd_phi)

% Closed loop system
Go_phi = Gc_phi*Gphi;
Gcl_phi = feedback(Go_phi, 1);
[num_Gcl_phi, den_Gcl_phi] = tfdata(Gcl_phi, 'v');

% -------------------------------------------------------------------------
% V Controller
% -------------------------------------------------------------------------

% PI Design parameter
Zc_v = 0.707;
Wc_v = 2*pi/5/5;

% PI Controller design
Kp_v = 2*Zc_v*Wc_v/g;
Ki_v = Wc_v^2/g * 0.7;
Kd_v = Kp_v/70;

% Kp_v = 0.32;
% Ki_v = 0;
% Kd_v = 0.1;

Gc_v = pid(Kp_v,Ki_v,Kd_v)

% Closed loop system
Go_v = Gc_v*Gcl_phi*Gv;
Gcl_v = feedback(Go_v, 1);
[num_Gcl_v, den_Gcl_v] = tfdata(Gcl_v, 'v');

Go_v_approx = Gc_v*Gv;
Gcl_v_approx = feedback(Go_v_approx, 1);

% -------------------------------------------------------------------------
% Y Controller
% -------------------------------------------------------------------------

% Design parameter
Wc_y = 2*pi/5/5/5;
Zc_y = 0.707;

% P Controller design
% Kp_y = Wc_y;
% Ki_y = 0;
% Kd_y = 0;

% PI Controller design
Kp_y = 2*Wc_y*Zc_y;
Ki_y = Wc_y^2 * 0.7;
Kd_y = Kp_y/5; % extra

Gc_y = pid(Kp_y,Ki_y,Kd_y)

% Closed loop system
Go_y = Gc_y*Gcl_v*Gy;
Gcl_y = feedback(Go_y, 1);
[num_Gcl_y, den_Gcl_y] = tfdata(Gcl_y, 'v');

Go_y_approx = Gc_y*Gy;
Gcl_y_approx = feedback(Go_y_approx, 1);

% -------------------------------------------------------------------------
% W Controller
% -------------------------------------------------------------------------

% PI Design parameter
% Zc_w = 0.707;
% Wc_w = 2*pi;
% 
% % PI Controller design
% Kp_w = 2*Zc_w*Wc_w*m/Kw;
% Ki_w = Wc_w^2*m/Kw;
% Kd_w = Kp_w/10;
% 
% % % P Design parameter
% % Wc_w = 15*r_z;
% % 
% % % P Controller design
% % Kp_w = Wc_w*m/Kt;
% % Ki_w = 0;
% % Kd_w = 0;
% 
% Gc_w = pid(Kp_w,Ki_w,Kd_w)
% 
% % Closed loop system
% Go_w = Gc_w*Gw;
% Gcl_w = feedback(Go_w, 1);
% [num_Gcl_w, den_Gcl_w] = tfdata(Gcl_w, 'v');
% 
% W_Controller = 0;

% -------------------------------------------------------------------------
% Z Controller
% -------------------------------------------------------------------------

% PI Design parameter
Zc_z = 0.707;
Wc_z = 2*pi/5;

% PI Controller design
Kp_z = Wc_z^2*Jz/Kz;
Ki_z = 0;
Kd_z = 2*Zc_z*Wc_z*m/Kz;

% % P Controller design
% Kp_z = Wc_z;
% Ki_z = 0;
% Kd_z = 0;

Gc_z = pid(Kp_z,Ki_z,Kd_z)

% Closed loop system
Go_z = Gc_z*Gz;
Gcl_z = feedback(Go_z, 1);
[num_Gcl_z, den_Gcl_z] = tfdata(Gcl_z, 'v');

% -------------------------------------------------------------------------
% Psi Controller
% -------------------------------------------------------------------------

Zc_psi = 0.707;
Wc_psi = 2*pi;

Kp_psi = Wc_psi^2*Jz/Kpsi;
Ki_psi = Kp_psi/20;
Kd_psi = 2*Zc_psi*Wc_psi*Jz/Kpsi;

Gc_psi = pid(Kp_psi,Ki_psi,Kd_psi)

% Closed loop system
Go_psi = Gc_psi*Gpsi;
Gcl_psi = feedback(Go_psi, 1);
[num_Gcl_psi, den_Gcl_psi] = tfdata(Gcl_psi, 'v');

% -------------------------------------------------------------------------
% Q-Filter
% -------------------------------------------------------------------------
% Phi
W_Qphi = 1*2*pi;
[num_Qphi,den_Qphi] = butter(2, W_Qphi, 'low', 's');
Qphi = tf(num_Qphi,den_Qphi);

num_Pphi = conv(num_Qphi, den_Gphi);
den_Pphi = conv(den_Qphi, num_Gphi);
Pphi = tf(num_Pphi,den_Pphi);

% Theta
W_Qtheta = 1*2*pi;
[num_Qtheta,den_Qtheta] = butter(2, W_Qtheta, 'low', 's');
Qtheta = tf(num_Qtheta,den_Qtheta);

num_Ptheta = conv(num_Qtheta, den_Gtheta);
den_Ptheta = conv(den_Qtheta, num_Gtheta);
Ptheta = tf(num_Ptheta,den_Ptheta);

% Psi
W_Qpsi = 1*2*pi;
[num_Qpsi,den_Qpsi] = butter(2, W_Qpsi, 'low', 's');
Qpsi = tf(num_Qpsi,den_Qpsi);

num_Ppsi = conv(num_Qpsi, den_Gpsi);
den_Ppsi = conv(den_Qpsi, num_Gpsi);
Ppsi = tf(num_Ppsi,den_Ppsi);

% X
W_Qx = 0.1*2*pi;
[num_Qx,den_Qx] = butter(2, W_Qx, 'low', 's');
Qx = tf(num_Qx,den_Qx);

num_Px = conv(num_Qx, den_Gx);
den_Px = conv(den_Qx, num_Gx);
Px = tf(num_Px,den_Px);

% Y
W_Qy = 0.1*2*pi;
[num_Qy,den_Qy] = butter(2, W_Qy, 'low', 's');
Qy = tf(num_Qy,den_Qy);

num_Py = conv(num_Qy, den_Gy);
den_Py = conv(den_Qy, num_Gy);
Py = tf(num_Py,den_Py);

% Z
W_Qz = 0.005*2*pi; %12*...
[num_Qz,den_Qz] = butter(2, W_Qz, 'low', 's');
Qz = tf(num_Qz,den_Qz);

num_Pz = conv(num_Qz, den_Gz);
den_Pz = conv(den_Qz, num_Gz);
Pz = tf(num_Pz,den_Pz);
% -------------------------------------------------------------------------
% Iterative Learning
% -------------------------------------------------------------------------
% Hp = 0.2;
% Hi = 0;
% Hd = 0.025;

Hp = 0.002;
Hi = 0;
Hd = 0.001;

Qiter_en = 1;
W_Qiter = 0.5*2*pi;
[num_Qiter,den_Qiter] = butter(1, W_Qiter, 'low', 's');

Z_u_prev = zeros(length(time),1);
Z_err_prev = zeros(length(time),1);
Z_err_prev_plus = zeros(length(time),1);

iteration = 1;

% -------------------------------------------------------------------------
% Sensor Noise
% -------------------------------------------------------------------------
Var_phi = 0.005^2;
Var_theta = 0.005^2;
Var_psi = 0.005^2;

Var_x = 0.01^2;
Var_y = 0.01^2;
Var_z = 0.01^2;

Var_u = 0.01^2;
Var_v = 0.01^2;
Var_w = 0.01^2;

NOISE = 0;

% -------------------------------------------------------------------------
% Wind Disturbance
% -------------------------------------------------------------------------
% Dist_mean_phi = 0;
% Dist_mean_theta = 0;
% Dist_mean_psi = 0;
% Dist_mean_x = 1;
% Dist_mean_y = 1;
% Dist_mean_z = 0;
% 
% Dist_Var_phi = 0;
% Dist_Var_theta = 0;
% Dist_Var_psi = 0;
% Dist_Var_x = 0.1^2;
% Dist_Var_y = 0.1^2;
% Dist_Var_z = 0.1^2;
% 
% Dist_Amp_phi = 0;
% Dist_Amp_theta = 0;
% Dist_Amp_psi = 0;
% Dist_Amp_x = 0; %0.3;
% Dist_Amp_y = 0;
% Dist_Amp_z = 0;
% 
% Dist_Freq_phi = 0;
% Dist_Freq_theta = 0;
% Dist_Freq_psi = 0;
% Dist_Freq_x = 0; %0.1*2*pi;
% Dist_Freq_y = 0;
% Dist_Freq_z = 0;

Dist_mean_phi = 0;
Dist_mean_theta = 0;
Dist_mean_psi = 0;
Dist_mean_x = 0;
Dist_mean_y = 0;
Dist_mean_z = 0;

Dist_Var_phi = 0;
Dist_Var_theta = 0;
Dist_Var_psi = 0;
Dist_Var_x = 0;
Dist_Var_y = 0;
Dist_Var_z = 0;

Dist_Amp_phi = 0;
Dist_Amp_theta = 0;
Dist_Amp_psi = 0;
Dist_Amp_x = 0;
Dist_Amp_y = 0;
Dist_Amp_z = 0;

Dist_Freq_phi = 0;
Dist_Freq_theta = 0;
Dist_Freq_psi = 0;
Dist_Freq_x = 0;
Dist_Freq_y = 0;
Dist_Freq_z = 0;

DISTURBANCE = 0;

% -------------------------------------------------------------------------
% System Properties Plot
% -------------------------------------------------------------------------

% figure, hold on, grid on
% pzmap(Gcl_theta)
% pzmap(Gcl_u)
% pzmap(Gcl_x)
% pzmap(Gcl_u_approx)
% pzmap(Gcl_x_approx)
% title('X')
% 
% figure, hold on, grid on
% step(Gcl_theta)
% step(Gcl_u)
% step(Gcl_x)
% step(Gcl_u_approx)
% step(Gcl_x_approx)
% title('X')
% 
% figure, hold on, grid on
% bode(Gcl_theta)
% bode(Gcl_u)
% bode(Gcl_x)
% title('X')
% 
% figure, hold on, grid on
% pzmap(Gcl_phi)
% pzmap(Gcl_v)
% pzmap(Gcl_y)
% pzmap(Gcl_v_approx)
% pzmap(Gcl_y_approx)
% title('Y')
% 
% figure, hold on, grid on
% step(Gcl_phi)
% step(Gcl_v)
% step(Gcl_y)
% step(Gcl_v_approx)
% step(Gcl_y_approx)
% title('Y')
% 
% figure, hold on, grid on
% bode(Gcl_phi)
% bode(Gcl_v)
% bode(Gcl_y)
% title('Y')
% 
% figure, hold on, grid on
% pzmap(Gcl_w)
% pzmap(Gcl_z)
% pzmap(Gcl_z_approx)
% title('Z')
% 
% figure, hold on, grid on
% step(Gcl_w)
% step(Gcl_z)
% step(Gcl_z_approx)
% title('Z')
% 
% figure, hold on, grid on
% bode(Gcl_w)
% bode(Gcl_z)
% bode(Gcl_z_approx)
% title('Z')
% 
% figure, hold on, grid on
% pzmap(Gcl_psi)
% title('Yaw')
% 
% figure, hold on, grid on
% step(Gcl_psi)
% title('Yaw')
% 
% figure, hold on, grid on
% bode(Gcl_psi)
% title('Yaw')

% -------------------------------------------------------------------------
% DOBC Simulation
% -------------------------------------------------------------------------

ILC = 0;

DOBC_phi = 0;
DOBC_theta = 0;
DOBC_psi = 0;
DOBC_x = 0;
DOBC_y = 0;
DOBC_z = 0;

simulation = sim('PC_Quadcopter_Simulation_Alchemist');

figure(1),hold on,grid on
plot3(Xd_sim, Yd_sim ,Zd_sim, 'black', 'linewidth', 2);
plot3(X,Y,Z, 'b', 'linewidth', 1.5);
title('Drone Landing while Ground Effect takes Place'), xlabel('X [m]'), ylabel('Y [m]'), zlabel('Z [m]')
legend('Reference Input','Output')

figure(2),hold on,grid on
plot(time, Xd_sim, 'black', 'linewidth', 2);
plot(time, X, 'blue-.', 'linewidth', 1.5);
title('X'), xlabel('time [s]'), ylabel('x [m]')
legend('Reference Input','Output')

figure(3),hold on,grid on
plot(time, Yd_sim, 'black', 'linewidth', 2);
plot(time, Y, 'blue-.', 'linewidth', 1.5);
title('Y'), xlabel('time [s]'), ylabel('y [m]')
legend('Reference Input','Output')

figure(4),hold on,grid on
plot(time, Zd_sim, 'black', 'linewidth', 2);
plot(time, Z, 'blue-.', 'linewidth', 1.5);
title('Altitude'), xlabel('time [s]'), ylabel('z [m]')
legend('Reference Input','Output')

figure(5),hold on,grid on, 
plot(time, rad2deg(Phi_cmd), 'black', 'linewidth', 2);
plot(time, rad2deg(Phi), 'blue-.', 'linewidth', 1.5);
title('Roll'), xlabel('time [s]'), ylabel('\phi [deg]')
legend('Reference Input','Output')

figure(6),hold on,grid on, 
plot(time, rad2deg(Theta_cmd), 'black', 'linewidth', 2);
plot(time, rad2deg(Theta), 'blue-.', 'linewidth', 1.5);
title('Pitch'), xlabel('time [s]'), ylabel('\theta [deg]')
legend('Reference Input','Output')

figure(7),hold on,grid on,
plot(time, rad2deg(Psi_cmd), 'black', 'linewidth', 2);
plot(time, rad2deg(Psi), 'blue-.', 'linewidth', 1.5);
title('Yaw'), xlabel('time [s]'), ylabel('\psi [deg]')
legend('Reference Input','Output')

figure(8),hold on,grid on, 
plot(time, U_cmd, 'black', 'linewidth', 2);
plot(time, U, 'blue-.', 'linewidth', 1.5);
title('U'), xlabel('time [s]'), ylabel('u [m/s]')
legend('Reference Input','Output')

figure(9),hold on,grid on, 
plot(time, V_cmd, 'black', 'linewidth', 2);
plot(time, V, 'blue-.', 'linewidth', 1.5);
title('V'), xlabel('time [s]'), ylabel('v [m/s]')
legend('Reference Input','Output')