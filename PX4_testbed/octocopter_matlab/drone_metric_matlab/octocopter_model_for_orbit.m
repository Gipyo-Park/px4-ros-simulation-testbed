clear all; clc; close all;


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

for i = 1:8
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
syms fx fy fz mx my mz U
syms X_dot X
syms u_p u_q u_r Thrust

% 간단히 하기 위해 cos, sin을 줄여서 씁니다.
% c = @(x) cos(x);
% s = @(x) sin(x);
% t = @(x) tan(x);

m = total_mass; % mass of the octocopter (kg)
g = 9.81; % gravitational acceleration (m/s^2)
I_v = diag([7.46, 1.53, 8.89]); % inertia matrix (kg*m^2)


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

% % 방정식 정의 % kinematic model은 쿼드나 옥토나 같다.
x_dot = Pos_dot(1);
y_dot = Pos_dot(2);
z_dot = Pos_dot(3);

% Rotational
% OMEGA = [phi_dot;theta_dot;psi_dot]; % rotational(angular) velocity in earth frame
OMEGAB = [p;q;r];  % rotational(angular) velocity in body frame
OMEGA = RotMat(phi, theta, psi, 7) * OMEGAB; % rotational(angular) velocity in body frame rotates angular velocity in earth frame % Diff Vehicle frames

% % 방정식 정의 % kinematic model은 쿼드나 옥토나 같다.
phi_dot = OMEGA(1);
theta_dot = OMEGA(2);
psi_dot = OMEGA(3);


% disp('x_dot = ')
% disp(x_dot)
% disp('y_dot = ')
% disp(y_dot)
% disp('z_dot = ')
% disp(z_dot)
% disp('phi_dot = ')
% disp(phi_dot)
% disp('theta_dot = ')
% disp(theta_dot)
% disp('psi_dot = ')
% disp(psi_dot)

% % 방정식 정의 % kinematic model은 쿼드나 옥토나 같다.
% x_dot = w*(sin(phi)*sin(psi) + cos(phi)*cos(psi)*sin(theta)) - v*(cos(phi)*sin(psi) - cos(psi)*sin(phi)*sin(theta)) + u*cos(psi)*cos(theta);
% y_dot = v*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta)) - w*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)) + u*cos(theta)*sin(psi);
% z_dot = w*cos(phi)*cos(theta) - u*sin(theta) + v*cos(theta)*sin(phi);
% phi_dot = p + r*cos(phi)*tan(theta) + q*sin(phi)*tan(theta);
% theta_dot = q*cos(phi) - r*sin(phi);
% psi_dot = r*cos(phi)/cos(theta) + q*sin(phi)/cos(theta);

% VB_dot = [u_dot;v_dot;w_dot]; % linear acceleration in body frame
% OMEGAB_dot = [p_dot;q_dot;r_dot]; % angular acceleration in body frame


% 데이터 불러오기
flight_data = readtable('/home/hmcl/PX4_testbed/octocopter_matlab/drone_metric_matlab/flight_data_for_orbit_mode.csv');

% Create polynomial features for stepwise regression
flight_data.p_squared = flight_data.p.^2;
flight_data.p_cubed = flight_data.p.^3;
flight_data.u_p_squared = flight_data.u_p.^2;
flight_data.u_p_cubed = flight_data.u_p.^3;

flight_data.q_squared = flight_data.q.^2;
flight_data.q_cubed = flight_data.q.^3;
flight_data.u_q_squared = flight_data.u_q.^2;
flight_data.u_q_cubed = flight_data.u_q.^3;

flight_data.r_squared = flight_data.r.^2;
flight_data.r_cubed = flight_data.r.^3;
flight_data.u_r_squared = flight_data.u_r.^2;
flight_data.u_r_cubed = flight_data.u_r.^3;

% Specify predictor variables (independent variables) and response (dependent variable)
Mx_data = flight_data(:, {'p', 'u_p', 'p_squared', 'p_cubed', 'u_p_squared', 'u_p_cubed','Mx'});
My_data = flight_data(:, {'q', 'u_q', 'q_squared', 'q_cubed', 'u_q_squared', 'u_q_cubed','My'});
Mz_data = flight_data(:, {'r', 'u_r', 'r_squared', 'r_cubed', 'u_r_squared', 'u_r_cubed','Mz'});



% Stepwise linear model fitting
Mx_model = stepwiselm(Mx_data, ...
                   'purequadratic', ...
                   'PredictorVars', {'p', 'u_p', 'p_squared', 'p_cubed', 'u_p_squared', 'u_p_cubed'}, ...
                   'ResponseVar', 'Mx', ...
                   'PEnter', 0.05 ,...
                   'PRemove', 0.1);

disp('Stepwise Linear Mx_model Summary:');
disp(Mx_model);

My_model = stepwiselm(My_data, ...
                   'purequadratic', ...
                   'PredictorVars', {'q', 'u_q', 'q_squared', 'q_cubed', 'u_q_squared', 'u_q_cubed'}, ...
                   'ResponseVar', 'My', ...
                   'PEnter', 0.05 ,...
                   'PRemove', 0.1);

disp('Stepwise Linear My_model Summary:');
disp(My_model);

Mz_model = stepwiselm(Mz_data, ...
                   'purequadratic', ...
                   'PredictorVars', {'r', 'u_r', 'r_squared', 'r_cubed', 'u_r_squared', 'u_r_cubed'}, ...
                   'ResponseVar', 'Mz', ...
                   'PEnter', 0.05 ,...
                   'PRemove', 0.1);

disp('Stepwise Linear Mz_model Summary:');
disp(Mz_model);


% Extract coefficients from the model
Mx_coefficients = Mx_model.Coefficients.Estimate;
My_coefficients = My_model.Coefficients.Estimate;
Mz_coefficients = Mz_model.Coefficients.Estimate;

% Assign coefficients from the model
Mx_intercept = Mx_coefficients(1);    % 상수항
coeff_p = Mx_coefficients(2);      % p의 계수
coeff_up = Mx_coefficients(3);     % u_p의 계수
coeff_p_squared = Mx_coefficients(4);  % p^2의 계수
coeff_p_cubed = Mx_coefficients(5);    % p^3의 계수
coeff_up_cubed = Mx_coefficients(6);   % u_p^3의 계수
coeff_p_cubed_squared = Mx_coefficients(7); % (p^3)^2의 계수

My_intercept = My_coefficients(1);    
coeff_q = My_coefficients(2);      
% coeff_uq = My_coefficients(3);     
coeff_q_squared = My_coefficients(3); 
% coeff_q_cubed = My_coefficients(5);    
% coeff_uq_cubed = My_coefficients(6);   
coeff_q_squared_squared = My_coefficients(4);

Mz_intercept = Mz_coefficients(1);    % 상수항
% coeff_r = Mz_coefficients(2);      
coeff_ur = Mz_coefficients(2);     
coeff_r_squared = Mz_coefficients(3);  
% coeff_r_cubed = Mz_coefficients(5);    
% coeff_ur_cubed = Mz_coefficients(6);   
% coeff_r_cubed_squared = Mz_coefficients(7); 



% Polynomial equation in symbolic form
Mx_symbolic = Mx_intercept + ...
              coeff_p * p + ...
              coeff_up * u_p + ...
              coeff_p_squared * p^2 + ...
              coeff_p_cubed * p^3 + ...
              coeff_up_cubed * u_p^3 + ...
              coeff_p_cubed_squared * (p^3^2);

My_symbolic = My_intercept + ...
              coeff_q * q + ...
              coeff_q_squared * q^2 + ...
              coeff_q_squared_squared * (q^2^2);

Mz_symbolic = Mz_intercept + ...
              coeff_ur * u_r + ...
              coeff_r_squared * r^2;

% Display the symbolic polynomial equation
% Optional: substitute p_squared = p^2, p_cubed = p^3, and so on
disp('Mx_symbolic Polynomial Equation:');
disp(Mx_symbolic);

disp('My_symbolic Polynomial Equation:');
disp(My_symbolic);

disp('Mz_symbolic Polynomial Equation:');
disp(Mz_symbolic);




FB = [fx; fy; fz];
MB = [Mx_symbolic; My_symbolic; Mz_symbolic];

U = [u_p ; u_q; u_r; Thrust];
disp('U = ')
disp(U)

% T = U(3);
% mx = U(4);
% my = U(5);
% mz = U(6);




% Translation
VB_dot = (1/m) * (RotMat(phi, theta, psi, 4) * [0; 0; m*g] - FB) - cross(OMEGAB, VB); % body frame

u_dot = VB_dot(1);
v_dot = VB_dot(2);
w_dot = VB_dot(3);


% Rotation Dynamics
% 추후에 여기 MB를 stepwise regression으로 구해서 넣어햐 할듯
OMEGAB_dot = inv(I_v) * MB - cross(inv(I_v)*OMEGAB, I_v * OMEGAB); % body frame

p_dot = OMEGAB_dot(1);
q_dot = OMEGAB_dot(2);
r_dot = OMEGAB_dot(3);







X_dot = [x_dot, y_dot, z_dot, u_dot, v_dot, w_dot,phi_dot,theta_dot,psi_dot,p_dot,q_dot,r_dot].';

disp('X_dot = ')
disp(X_dot)

X = [x;y;z;u;v;w;phi;theta;psi;p;q;r];
df_dx = jacobian(X_dot,X);
df_du = jacobian(X_dot,[fz;mx;my;mz]);


delft_df_dx = jacobian(OMEGAB_dot,[p;q;r]);
delft_df_du = jacobian(OMEGAB_dot,[u_p;u_q;u_r]);


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
% assignin('base', 'VB_dot', VB_dot);
% assignin('base', 'OMEGA', OMEGA);
% assignin('base', 'OMEGAB_dot', OMEGAB_dot);








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


