create_MB_for_agressive;

number_of_rotors = 8; % quad: 4 / octo: 8

base_link_mass = 19.0939;
base_link_Ixx = 7.46;
base_link_Iyy = 1.52;
base_link_Izz = 8.88;

imu_link_mass = 0.015;
imu_link_Ixx = 0.00001;
imu_link_Iyy = 0.00001;
imu_link_Izz = 0.00001;

% 각 rotor의 값들을 배열에 저장
masses = 0.085251;
Ixx_values = 0.00001545;
Iyy_values = 0.00073574;
Izz_values = 0.00074861;

% 구조체 배열을 생성하여 변수들을 저장
rotors = struct('mass', cell(1, 8), 'Ixx', cell(1, 8), 'Iyy', cell(1, 8), 'Izz', cell(1, 8));

for i = 1:number_of_rotors
    rotors(i).mass = masses;
    rotors(i).Ixx = Ixx_values;
    rotors(i).Iyy = Iyy_values;
    rotors(i).Izz = Izz_values;
end

% Sum rotor mass
total_rotor_masses = [rotors.mass];
total_rotor_masses = sum(total_rotor_masses);
% fprintf('total_rotor_masses = %f \n', total_rotor_masses);
% fprintf('rotor_1_mass = %f',rotors(1).mass);


% Sum rotor Ixx
total_rotor_Ixx = [rotors.Ixx];
total_rotor_Ixx = sum(total_rotor_Ixx);

% Sum rotor Iyy
total_rotor_Iyy = [rotors.Iyy];
total_rotor_Iyy = sum(total_rotor_Iyy);

% Sum rotor Izz
total_rotor_Izz = [rotors.Izz];
total_rotor_Izz = sum(total_rotor_Izz);


gps0_mass = 0.01;
gps0_Ixx = 0.0000021733;
gps0_Iyy = 0.0000021733;
gps0_Izz = 0.00000018;

% Sum drone mass
total_mass = base_link_mass + imu_link_mass + total_rotor_masses + gps0_mass;
total_mass = round(total_mass);
fprintf('total_mass = %f \n', total_mass);

% Sum drone Ixx
total_Ixx = base_link_Ixx + imu_link_Ixx + total_rotor_Ixx + gps0_Ixx;
total_Ixx = round(total_Ixx, 2);
fprintf('total_Ixx = %f \n', total_Ixx);

% Sum drone Iyy
total_Iyy = base_link_Iyy + imu_link_Iyy + total_rotor_Iyy + gps0_Iyy;
total_Iyy = round(total_Iyy, 2);
fprintf('total_Iyy = %f \n', total_Iyy);

% Sum drone Izz
total_Izz = base_link_Izz + imu_link_Izz + total_rotor_Izz + gps0_Izz;
total_Izz = round(total_Izz, 2);
fprintf('total_Izz = %f \n', total_Izz);


%% Define parameters

% 변수 정의
syms x y z u v w phi theta psi p q r
syms x_dot y_dot z_dot u_dot v_dot w_dot phi_dot theta_dot psi_dot p_dot q_dot r_dot
syms fx fy fz mx my mz U Ixx Iyy Izz
syms m g fw fwx fwy fwz ft tau_x tau_y tau_z tau_wx tau_wy tau_wz

% 간단히 하기 위해 cos, sin을 줄여서 씁니다.
% c = @(x) cos(x);
% s = @(x) sin(x);
% t = @(x) tan(x);

m = total_mass; % mass of the octocopter (kg)
g = 9.81; % gravitational acceleration (m/s^2)
% I_v = diag([Ixx, Iyy, Izz]); % inertia matrix (kg*m^2) % 수식확인 할때 사용
I_v = diag([total_Ixx, total_Iyy, total_Izz]); % inertia matrix (kg*m^2)


%{
octocopter figure

1cw        2ccw
3ccw       4cw
      ㅁ
5cw        6ccw
7ccw       8cw

%}


%% Six degree of the freedom model 
% Kinematics 

% Translation
% Pos_dot = [x_dot;y_dot;z_dot]; % translational velocity in earth frame
VB = [u;v;w]; % translational velocity in body frame
Pos_dot = RotMat(phi, theta, psi, 5) * VB; %translational velocity in body frame rotates velocity in earth frame % Inertial frame


% Rotational
% OMEGA = [phi_dot;theta_dot;psi_dot]; % rotational(angular) velocity in earth frame
OMEGAB = [p;q;r];  % rotational(angular) velocity in body frame
OMEGA = RotMat(phi, theta, psi, 7) * OMEGAB; % rotational(angular) velocity in body frame rotates angular velocity in earth frame % Diff Vehicle frames


% % 방정식 정의 % kinematic model은 쿼드나 옥토나 같다.
% x_dot = w*(sin(phi)*sin(psi) + cos(phi)*cos(psi)*sin(theta)) - v*(cos(phi)*sin(psi) - cos(psi)*sin(phi)*sin(theta)) + u*cos(psi)*cos(theta);
% y_dot = v*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta)) - w*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)) + u*cos(theta)*sin(psi);
% z_dot = w*cos(phi)*cos(theta) - u*sin(theta) + v*cos(theta)*sin(phi);
% phi_dot = p + r*cos(phi)*tan(theta) + q*sin(phi)*tan(theta);
% theta_dot = q*cos(phi) - r*sin(phi);
% psi_dot = r*cos(phi)/cos(theta) + q*sin(phi)/cos(theta);

% VB = [u_dot;v_dot;w_dot]; % linear acceleration in body frame
% OMEGAB = [p_dot;q_dot;r_dot]; % angular acceleration in body frame



coeffs_Mx = struct( ...
    'p', 3.7765, ...
    'u_p', 21.757, ...
    'p_up', -1508.3, ...
    'p_squared', -7.9738, ...
    'constant', 0.091002); % u_p_squared 제거

coeffs_My = struct( ...
    'q', 1.3502, ...
    'u_q', -0.073419, ...
    'q_uq', -76.175, ...
    'constant', -0.015016); % q_squared, u_q_squared 제거

coeffs_Mz = struct( ...
    'r', 1.0822, ...
    'u_r', 17.142, ...
    'r_squared', 0.20905, ...
    'u_r_squared', -20.001, ...
    'constant', 0.020245); % r_ur 제거

% Define polynomial equations based on regression coefficients
Mx_symbolic = coeffs_Mx.constant + ...
              coeffs_Mx.p * p + ...
              coeffs_Mx.u_p * u_p + ...
              coeffs_Mx.p_up * p * u_p + ...
              coeffs_Mx.p_squared * p^2;

My_symbolic = coeffs_My.constant + ...
              coeffs_My.q * q + ...
              coeffs_My.u_q * u_q + ...
              coeffs_My.q_uq * q * u_q;

Mz_symbolic = coeffs_Mz.constant + ...
              coeffs_Mz.r * r + ...
              coeffs_Mz.u_r * u_r + ...
              coeffs_Mz.r_squared * r^2 + ...
              coeffs_Mz.u_r_squared * u_r^2;

% Display the symbolic polynomial equation
disp('Mx_symbolic Polynomial Equation:');
disp(Mx_symbolic);

disp('My_symbolic Polynomial Equation:');
disp(My_symbolic);

disp('Mz_symbolic Polynomial Equation:');
disp(Mz_symbolic);



gravity_force = RotMat(phi, theta, psi, 8) * [0;0;m*g];
fw = [fwx;fwy;fwz];
thrust_force = ft * [0;0;1];

% 총 force (body frame)
FB = gravity_force - thrust_force + fw;



% Rotor + Wind torque
tau_rotor  = [tau_x; tau_y; tau_z];
tau_wind = [tau_wx; tau_wy; tau_wz];
gyroscopic = [0;0;0];

% 총 torque (body frame)
% MB = tau_rotor - gyroscopic + tau_wind;
MB = [Mx_symbolic; My_symbolic; Mz_symbolic];






% % Translation
% VB = - cross(OMEGAB, VB) + (1/m) * FB ; % body frame
% u_dot = VB(1);
% v_dot = VB(2);
% w_dot = VB(3);
% 
% 
% % Rotation Dynamics
% % 추후에 여기 MB를 stepwise regression으로 구해서 넣어햐 할듯
% OMEGAB = inv(I_v) * ( MB - cross(OMEGAB, I_v * OMEGAB) ); % body frame
% 
% p_dot = OMEGAB(1);
% q_dot = OMEGAB(2);
% r_dot = OMEGAB(3);


% Translation Dynamics
VB = - cross(OMEGAB, VB) + (1/m) * FB ; % body frame

% Rotation Dynamics
OMEGAB = inv(I_v) * ( MB - cross(OMEGAB, I_v * OMEGAB) ); % body frame




X_dot = [Pos_dot; VB; OMEGA; OMEGAB];

disp('X_dot = ');
disp(X_dot);

% 위치 가속도
x_ddot = -(ft/m) * ( cos(phi)*sin(theta)*cos(psi) + sin(phi)*sin(psi) );
y_ddot = -(ft/m) * ( cos(phi)*sin(theta)*sin(psi) - sin(phi)*cos(psi) );
z_ddot = g - (ft/m)*cos(phi)*cos(theta);

% 회전 가속도
phi_ddot   = ((Iyy - Izz)/Ixx)*r*q + tau_x/Ixx;
theta_ddot = ((Izz - Ixx)/Iyy)*p*r + tau_y/Iyy;
psi_ddot   = ((Ixx - Iyy)/Izz)*p*q + tau_z/Izz;

% 상태 미분 벡터
df_dx = jacobian(X_dot,[x;y;z;u;v;w;phi;theta;psi;p;q;r]);
df_du = jacobian(X_dot,[u_p;u_q;u_r;ft]);


delft_df_dx = jacobian(OMEGAB,[p;q;r]);
delft_df_du = jacobian(OMEGAB,[u_p;u_q;u_r]);


disp('df_dx = ')
disp(df_dx)
disp('df_du = ')
disp(df_du)

disp('size of df_dx = ')
disp(size(df_dx))
disp('size of df_du = ')
disp(size(df_du))

assignin('base', 'df_dx', df_dx);
assignin('base', 'df_du', df_du);

%%%%%%%%%%%%%%%%
disp('delft_df_dx = ')
disp(delft_df_dx)
disp('delft_df_du = ')
disp(delft_df_du)

disp('size of delft_df_dx = ')
disp(size(delft_df_dx))
disp('size of delft_df_du = ')
disp(size(delft_df_du))

assignin('base', 'delft_df_dx', delft_df_dx);
assignin('base', 'delft_df_du', delft_df_du);


% assignin('base', 'Pos_dot', Pos_dot); %x_dot , y_dot, z_dot
% assignin('base', 'VB', VB);
% assignin('base', 'OMEGA', OMEGA);
% assignin('base', 'OMEGAB', OMEGAB);








%% initial state

% Initial condition of integrators
vbInt_initial               =[0;0;0];
omegaInt_initial            =[0;0;0];
EulerInt_initial            =[0;0;0];
PosInertialInt_initial      =[0;0;0];

% Error signal parameters 
err1Enable                  =0;
motorErr1Time               =0;

err2Enable                  =0;
motorErr2Time               =0;

err3Enable                  =0;
motorErr3Time               =0;

err4Enable                  =0;
motorErr4Time               =0;

err5Enable                  =0;
motorErr5Time               =0;

err6Enable                  =0;
motorErr6Time               =0;

err7Enable                  =0;
motorErr7Time               =0;

err8Enable                  =0;
motorErr8Time               =0;


