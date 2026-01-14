create_MB_for_agressive;

number_of_rotors = 8; % quad: 4 / octo: 8
S = diag([1,-1,-1]);

base_link_mass = 2.8;
base_link_Ixx = 0.021;
base_link_Iyy = 0.070;
base_link_Izz = 0.091;

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


gps0_mass = 0;
gps0_Ixx = 0;
gps0_Iyy = 0;
gps0_Izz = 0;

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

5ccw      1cw
7cw       3ccw
      ㅁ
6ccw      8cw
2cw       4ccw

%}


%% Six degree of the freedom model 
% Kinematics 


% % 회전 가속도
phi_ddot   = ((total_Iyy - total_Izz)/total_Ixx)*r*q + u_p/total_Ixx;
theta_ddot = ((total_Izz - total_Ixx)/total_Iyy)*p*r + u_q/total_Iyy;
psi_ddot   = ((total_Ixx - total_Iyy)/total_Izz)*p*q + u_r/total_Izz;

rot_vel_dot = [phi_ddot; theta_ddot; psi_ddot];

delft_df_dx = jacobian(rot_vel_dot, [p;q;r]);
delft_df_du = jacobian(rot_vel_dot, [u_p;u_q;u_r]);



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


