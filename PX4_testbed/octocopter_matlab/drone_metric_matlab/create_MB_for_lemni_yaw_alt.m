% step-wise regression을 통해 MB를 추정한다

clear all; clc; close all;

% Define symbolic variables
syms p u_p q u_q r u_r


% 데이터 불러오기
flight_data = readtable('/home/hmcl/PX4_testbed/octocopter_matlab/drone_metric_matlab/flight_data_for_lemni_yaw_alt.csv');

% Create polynomial features for stepwise regression
% flight_data.p_squared = flight_data.p.^2;
% flight_data.p_cubed = flight_data.p.^3;
% flight_data.u_p_squared = flight_data.u_p.^2;
% flight_data.u_p_cubed = flight_data.u_p.^3;
% 
% flight_data.q_squared = flight_data.q.^2;
% flight_data.q_cubed = flight_data.q.^3;
% flight_data.u_q_squared = flight_data.u_q.^2;
% flight_data.u_q_cubed = flight_data.u_q.^3;
% 
% flight_data.r_squared = flight_data.r.^2;
% flight_data.r_cubed = flight_data.r.^3;
% flight_data.u_r_squared = flight_data.u_r.^2;
% flight_data.u_r_cubed = flight_data.u_r.^3;

% Specify predictor variables (independent variables) and response (dependent variable)
% Mx_data = flight_data(:, {'p', 'u_p', 'p_squared', 'u_p_squared', 'p_cubed', 'u_p_cubed', 'Mx'});
% My_data = flight_data(:, {'q', 'u_q', 'q_squared', 'u_q_squared', 'q_cubed', 'u_q_cubed', 'My'});
% Mz_data = flight_data(:, {'r', 'u_r', 'r_squared', 'u_r_squared', 'r_cubed', 'u_r_cubed', 'Mz'});
Mx_data = flight_data(:, {'p', 'u_p', 'backward_Mx'});
My_data = flight_data(:, {'q', 'u_q', 'backward_My'});
Mz_data = flight_data(:, {'r', 'u_r', 'backward_Mz'});



% Stepwise linear model fitting
Mx_model = stepwiselm(Mx_data, ...
                   'quadratic', ...
                   'PredictorVars', {'p', 'u_p'}, ...
                   'ResponseVar', 'backward_Mx', ...
                   'PEnter', 0.05 ,...
                   'PRemove', 0.1);

disp('Stepwise Linear Mx_model Summary:');
disp(Mx_model);

My_model = stepwiselm(My_data, ...
                   'quadratic', ...
                   'PredictorVars', {'q', 'u_q'}, ...
                   'ResponseVar', 'backward_My', ...
                   'PEnter', 0.05 ,...
                   'PRemove', 0.1);

disp('Stepwise Linear My_model Summary:');
disp(My_model);

Mz_model = stepwiselm(Mz_data, ...
                   'quadratic', ...
                   'PredictorVars', {'r', 'u_r'}, ...
                   'ResponseVar', 'backward_Mz', ...
                   'PEnter', 0.05 ,...
                   'PRemove', 0.1);

disp('Stepwise Linear Mz_model Summary:');
disp(Mz_model);


% % Extract coefficients from the model
% Mx_coefficients = Mx_model.Coefficients.Estimate;
% My_coefficients = My_model.Coefficients.Estimate;
% Mz_coefficients = Mz_model.Coefficients.Estimate;
% 
% % Assign coefficients from the model
% Mx_intercept = Mx_coefficients(1);    % 상수항
% coeff_p = Mx_coefficients(2);      % p의 계수
% coeff_up = Mx_coefficients(3);     % u_p의 계수
% coeff_p_squared = Mx_coefficients(4);  % p^2의 계수
% coeff_p_cubed = Mx_coefficients(5);    % p^3의 계수
% coeff_up_cubed = Mx_coefficients(6);   % u_p^3의 계수
% coeff_p_cubed_squared = Mx_coefficients(7); % (p^3)^2의 계수
% 
% My_intercept = My_coefficients(1);    
% coeff_q = My_coefficients(2);      
% % coeff_uq = My_coefficients(3);     
% coeff_q_squared = My_coefficients(3); 
% % coeff_q_cubed = My_coefficients(5);    
% % coeff_uq_cubed = My_coefficients(6);   
% coeff_q_squared_squared = My_coefficients(4);
% 
% Mz_intercept = Mz_coefficients(1);    % 상수항
% % coeff_r = Mz_coefficients(2);      
% coeff_ur = Mz_coefficients(2);     
% coeff_r_squared = Mz_coefficients(3);  
% % coeff_r_cubed = Mz_coefficients(5);    
% % coeff_ur_cubed = Mz_coefficients(6);   
% % coeff_r_cubed_squared = Mz_coefficients(7); 
% 
% 
% 
% % Polynomial equation in symbolic form
% Mx_symbolic = Mx_intercept + ...
%               coeff_p * p + ...
%               coeff_up * u_p + ...
%               coeff_p_squared * p^2 + ...
%               coeff_p_cubed * p^3 + ...
%               coeff_up_cubed * u_p^3 + ...
%               coeff_p_cubed_squared * (p^3^2);
% 
% My_symbolic = My_intercept + ...
%               coeff_q * q + ...
%               coeff_q_squared * q^2 + ...
%               coeff_q_squared_squared * (q^2^2);
% 
% Mz_symbolic = Mz_intercept + ...
%               coeff_ur * u_r + ...
%               coeff_r_squared * r^2;
% 
% % Display the symbolic polynomial equation
% % Optional: substitute p_squared = p^2, p_cubed = p^3, and so on
% disp('Mx_symbolic Polynomial Equation:');
% disp(Mx_symbolic);
% 
% disp('My_symbolic Polynomial Equation:');
% disp(My_symbolic);
% 
% disp('Mz_symbolic Polynomial Equation:');
% disp(Mz_symbolic);