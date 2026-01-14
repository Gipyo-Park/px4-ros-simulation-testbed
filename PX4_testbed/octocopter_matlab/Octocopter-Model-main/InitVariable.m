% Initialize Variables of Octocopter. 
% Copyright (C) 2022 Dogan Yildiz <doganyildiz1990@gmail.com>
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% Copyright 2019 The MathWorks, Inc.
clear all; clc; close all;
%%-------------------------------------------------------
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

total_rotor_masses = [rotors.mass];
total_rotor_masses = sum(total_rotor_masses);

total_rotor_Ixx = [rotors.Ixx];
total_rotor_Ixx = sum(total_rotor_Ixx);

total_rotor_Iyy = [rotors.Iyy];
total_rotor_Iyy = sum(total_rotor_Iyy);

total_rotor_Izz = [rotors.Izz];
total_rotor_Izz = sum(total_rotor_Izz);

fprintf('total_rotor_masses = %f \n', total_rotor_masses);
fprintf('total_rotor_Ixx = %f \n', total_rotor_Ixx);
fprintf('total_rotor_Iyy = %f \n', total_rotor_Iyy);
fprintf('total_rotor_Izz = %f \n', total_rotor_Izz);
% fprintf('rotor_1_mass = %f',rotors(1).mass);


gps0_mass = 0.01;
gps0_Ixx = 0.0000021733;
gps0_Iyy = 0.0000021733;
gps0_Izz = 0.00000018;

total_mass = base_link_mass + imu_link_mass + total_rotor_masses + gps0_mass;
total_Ixx = base_link_Ixx + imu_link_Ixx + total_rotor_Ixx + gps0_Ixx ;
total_Iyy = base_link_Iyy + imu_link_Iyy + total_rotor_Iyy + gps0_Iyy ;
total_Izz = base_link_Izz + imu_link_Izz + total_rotor_Izz + gps0_Izz ;

fprintf('total_mass = %f \n', total_mass);
%%---------------------------------------------------

mass                        = total_mass; %kg
moment_of_inertia           = diag([total_Ixx, total_Iyy, total_Izz]); % kg_m_m
%%---------------------------------------------------
gravity                     = 9.81; %m/s
number_of_actuators         = 8;

%%--------------------------------------------------- 이 부분 모터스펙 수정해야할듯
rotor_thrust_coeff          = 6.5;    % rotor_thrust_N = rotor_thrust_coeff*rotor_rad_per_s^2 %Ct
rotor_torque_coeff          = 0.05;   % rotor_torque_Nm = rotor_torque_coeff*rotor_rad_per_s^2 %Cm 


rotor_max_rad_per_s         = 30;      % maximum  allowed rotor spinning velocity (in both directions)
rotor_min_rad_per_s         = 0;       % minimum rotor spinning velocity (stop)
%%--------------------------------------------------- 이 부분 모터스펙 수정해야할듯
l1                          = 0.45;    % long arm length[m]
l2                          = 0.45;    % short arm length[m]
%%------------------------이것도 수정해야해 l1 , l2

alpha                       = 0;       % Tilt angle of motors
dt                          = 0.01;    % Simulation Time

% Initial condition of integrators
vbInt_initial               =[0;0;0];
omegaInt_initial            =[0;0;0];
EulerInt_initial            =[0;0;0];
PosInertialInt_initial      =[0;0;0];
% PID control gain parameters initilization
Kp_z                        = 22;      
Ki_z                        = 60;
Kd_z                        = 2.2;

Kp_vz                       = 8;
Ki_vz                       = 4;
Kd_vz                       = 4.2;

Kp_phi                      = 0.9;
Ki_phi                      = 0.5;
Kd_phi                      = 1.9;

Kp_phidot                   = 0.9;
Ki_phidot                   = 0.3;
Kd_phidot                   = 0.2;

Kp_theta                    = 1.6;
Ki_theta                    = 0.4;
Kd_theta                    = 0.7;

Kp_thetadot                 = 1.5;
Ki_thetadot                 = 0.5;
Kd_thetadot                 = 0.1;

Kp_psi                      = 1.5;
Ki_psi                      = 0.4;
Kd_psi                      = 0.8;

Kp_psidot                   = 1.9;
Ki_psidot                   = 0.2;
Kd_psidot                   = 0.1;

% Reference signal parameters
zRefStepTime                =0;
zRefFinal                   =0;

phiRefStepTime              =0;
phiRefFinal                 =0;

thetaRefStepTime            =0;
thetaRefFinal               =0;

psiRefStepTime              =0;
psiRefFinal                 =0;

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

% First order filter initial parameter
K1                          = 0.5;