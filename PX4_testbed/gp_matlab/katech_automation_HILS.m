clear; clc;close all;

tic;

% --- [시작] 동적 경로 설정 ---
% 이 블록은 사용자마다 다른 절대 경로(/home/hmcl/...)를 자동으로 설정합니다.

% 1. 현재 사용자의 홈 디렉터리 경로를 자동으로 가져옵니다.
% (예: '/home/hmcl' 또는 '/home/ghgrlfehd')
try
    % MATLAB에 내장된 Java를 사용해 사용자 홈 디렉터리를 찾습니다.
    user_home = char(java.lang.System.getProperty('user.home'));
    if isempty(user_home)
        error('Java user.home 속성을 찾을 수 없습니다. getenv로 재시도합니다.');
    end
catch
    user_home = getenv('HOME'); % Java 실패 시 Linux/macOS 표준 방식 사용
    if isempty(user_home)
        error('사용자 홈 디렉터리를 자동으로 찾을 수 없습니다. 스크립트 경로를 확인하세요.');
    end
end

% 2. 'PX4_testbed' 기본 경로를 설정합니다. (스크린샷 참조)
project_root = fullfile(user_home, 'PX4_testbed');

% 3. 'automation_codes' 쉘 스크립트 경로를 동적으로 설정합니다.
automation_path = fullfile(project_root, 'automation_codes');

set_automation_env = fullfile(automation_path, 'set_automation_env.sh'); % 드론이 하버링 하도록 SILS 환경을 자동화
close_terminal = fullfile(automation_path, 'close_terminal.sh'); % 자동화에서 사용된 모든 터미널을 닫음
open_NoFTC_MotorFault_terminal = fullfile(automation_path, 'open_NoFTC_MotorFault_terminal.sh'); % FTC_toggle 토글에 따라 고장 주입
open_FTC_MotorFault_terminal = fullfile(automation_path, 'open_FTC_MotorFault_terminal.sh'); % FTC_toggle 토글에 따라 고장 주입
open_roscore_for_simulink = fullfile(automation_path, 'open_roscore_for_simulink.sh'); % ROSCORE 실행
octo_model_path = fullfile(project_root, 'gp_matlab', 'octo_model');
addpath(octo_model_path);
disp(['[Path] 경로 추가 완료: ' octo_model_path]);

try
    % 'octo_model' 폴더가 addpath를 통해 경로에 추가되었으므로 파일명만으로 실행 가능
    run('octo_model/octocopter_model_for_agressive_HILS.m');
catch ME
    error('octo_model/octocopter_model_for_agressive_HILS.m 스크립트 실행에 실패했습니다. (%s)', ME.message);
end




% Execute the bash script using the system command
% set_automation_env = '/home/yjchun/KATECH_250715/automation_codes/set_automation_env.sh';
% close_terminal = '/home/yjchun/KATECH_250715/automation_codes/close_terminal.sh';
% open_NoFTC_MotorFault_terminal = '/home/yjchun/KATECH_250715/automation_codes/open_NoFTC_MotorFault_terminal.sh';
% open_FTC_MotorFault_terminal = '/home/yjchun/KATECH_250715/automation_codes/open_FTC_MotorFault_terminal.sh';
% open_roscore_for_simulink = '/home/yjchun/KATECH_250715/automation_codes/open_roscore_for_simulink.sh';
% addpath('/home/yjchun/KATECH_250715/gp_matlab/octo_model');

%시뮬레이션 돌린 날짜
currentDateTime = datetime('now');

% 날짜를 'yyyymmdd' 형식의 문자열로 변환
formattedDate = datestr(currentDateTime, 'yyyymmdd');

diary('diary.txt');   % 원하는 파일명 지정(확장자 포함)
diary on;             % 기록 시작

%% setup Parameter

% 기준 히트맵과 임계값 설정
% reference 파일의 row와 column 갯수는 내가 뽑고 싶은 히트맵의 row와 column의 갯수가 같아야한다.
% reference 파일의 row size = 내가 뽑고 싶은 히트맵의 row size
%% 
% reference 파일의 column size = 내가 뽑고 싶은 히트맵의 column size
% load_reference_heatmap = load('heatmap_mat_format_max_xy_error_original_fault_1_0_0_reference.mat'); % reference heatmap 파일을 로드합니다.
% reference_heatmap = load_reference_heatmap.heatmap_mat_format_max_xy_error_original; %구조체에서 데이터 추출
% threshold_value = 4; % 임계값 설정

% start_date automation돌린 날짜 하지만 원하는 날짜로 바꿔도 된다.
% ex) start_date = 20241225;  원하는 날짜
% ex) start_date = str2double(formattedDate);  현재를 자동입력 날짜
start_date = str2double(formattedDate);

% 이 변수는 폴더이름과 rostopic에 사용된다.
FTC_toggle = 0; % 1: OnFTC / 0 : OffFTC
motor_failure_number = 0;
motor_failure_number1 = 0;
motor_failure_number2 = 0;

%FCM window 사이즈 설정
window_size_ = Simulink.Parameter(100);

% 바람 유형 토글 (1: 거스트/상수 바람, 2: 정규분포 바람)
wind_type_toggle = 2;    % 기본값: 1 (거스트)

% 하나의 테스트 케이스 종류 되고 정지되는 시간 설정
pause_time_according_to_GUI = 2;


% 정규분포일때 variance max 설정
wind_normal_distribution_Max = 5;
wind_normal_distribution_Variance = 5;


% 정규 분포 일때 
% Mean 값 설정 : wind_upper 와 wind_lower
% Max 값 설정 : wind_upper +wind_normal_distribution_Max 와 wind_lower +wind_normal_distribution_Max
wind_lower = -20;
wind_upper = 20;
increment = 1; % Set increment value (e.g., 0.1, 0.5, 1, etc.)

%{
octocopter figure

5       1
7       3
    ㅁ
6       8
2       4

%}




%% Algorithms start

% ftc_status_str 정의
if FTC_toggle
    ftc_status_str = 'with FTC';
else
    ftc_status_str = 'without FTC';
end

% 정규분포 바람에서 사용할 기본 Max, variance 범위 (없으면 0)
if wind_type_toggle == 2
    % 정규분포 바람: wind_lower ~ wind_upper 범위에서 Mean을 선택
    default_Normal_Max = wind_normal_distribution_Max;
    default_Normal_Var = wind_normal_distribution_Variance;
else
    % 거스트 바람: Max, Variance 모두 0으로 설정
    default_Normal_Max = 0;
    default_Normal_Var = 0;
end

% wind_type_str 정의
if wind_type_toggle == 2
    wind_type_str = sprintf('Normal Max%d Var%d', ...
                            round(default_Normal_Max), ...
                            round(default_Normal_Var));
else
    wind_type_str = 'Gust';
end

% 각 모터고장 값을 txt 파일에 저장
fid = fopen('motor_failure_number.txt', 'w');
fprintf(fid, '%d', motor_failure_number);
fclose(fid);

fid = fopen('motor_failure_number1.txt', 'w');
fprintf(fid, '%d', motor_failure_number1);
fclose(fid);

fid = fopen('motor_failure_number2.txt', 'w');
fprintf(fid, '%d', motor_failure_number2);
fclose(fid);


input_wind_x = 0; % don't touch
input_wind_y = 0; % don't touch
input_wind_z = 0; % don't touch

num_x = ceil((wind_upper - wind_lower) / increment) + 1; %only round up
num_y = ceil((wind_upper - wind_lower) / increment) + 1;

i = 0;
cell_format = cell(num_x, num_y);

% Update wind_x and wind_y in the for loop
for wind_x = wind_lower:increment:wind_upper
    for wind_y = wind_lower:increment:wind_upper
        i = i + 1;

        x = round((wind_x - wind_lower) / increment) + 1;
        y = round((wind_y - wind_lower) / increment) + 1;

        mat = [wind_x, wind_y];
        cell_format{x, y} = mat;

        fprintf('mat row = %.1f , column = %.1f\n', x, y);
    end
end

disp('Completed filling cell_format');




heatmap_mat_format_max_roll = zeros(num_x,num_y);
heatmap_mat_format_max_roll_original = zeros(num_x,num_y);

heatmap_mat_format_max_xy_error = zeros(num_x,num_y);
heatmap_mat_format_max_xy_error_original = zeros(num_x,num_y);

heatmap_mat_format_endstep_xy_error = zeros(num_x,num_y);
heatmap_mat_format_endstep_xy_error_original = zeros(num_x,num_y);

heatmap_mat_format_endstep_x_error = zeros(num_x,num_y);
heatmap_mat_format_endstep_x_error_original = zeros(num_x,num_y);

heatmap_mat_format_endstep_y_error = zeros(num_x,num_y);
heatmap_mat_format_endstep_y_error_original = zeros(num_x,num_y);

heatmap_mat_format_endstep_z_error = zeros(num_x,num_y);
heatmap_mat_format_endstep_z_error_original = zeros(num_x,num_y);

heatmap_mat_format_max_x_error = zeros(num_x,num_y);
heatmap_mat_format_max_x_error_original = zeros(num_x,num_y);

heatmap_mat_format_max_y_error = zeros(num_x,num_y);
heatmap_mat_format_max_y_error_original = zeros(num_x,num_y);

heatmap_mat_format_max_z_error = zeros(num_x,num_y);
heatmap_mat_format_max_z_error_original = zeros(num_x,num_y);

heatmap_mat_format_min_FCMW = zeros(num_x,num_y);
heatmap_mat_format_min_FCMW_original = zeros(num_x,num_y);

heatmap_mat_format_min_avg_array_FCM = zeros(num_x,num_y);
heatmap_mat_format_min_avg_array_FCM_original = zeros(num_x,num_y);


heatmap_mat_format_postion_xyz = cell(num_x, num_y);

heatmap_mat_format_max_xyz_error = zeros(num_x,num_y);
heatmap_mat_format_max_xyz_error_original = zeros(num_x,num_y);

heatmap_mat_format_endstep_xyz_error = zeros(num_x,num_y);
heatmap_mat_format_endstep_xyz_error_original = zeros(num_x,num_y);

heatmap_mat_format_avg_FCM_in_range = zeros(num_x,num_y);
heatmap_mat_format_avg_FCM_in_range_orginal = zeros(num_x,num_y);

heatmap_mat_format_total_FCM = cell(num_x, num_y);

heatmap_mat_format_avg_FCM_saturated_in_range = zeros(num_x,num_y);
heatmap_mat_format_avg_FCM_saturated_in_range_orginal = zeros(num_x,num_y);

heatmap_mat_format_min_avg_array_FCM_saturated = zeros(num_x,num_y);
heatmap_mat_format_min_avg_array_FCM_saturated_original = zeros(num_x,num_y);

heatmap_mat_format_max_avg_xyz_error = zeros(num_x,num_y);
heatmap_mat_format_max_avg_xyz_error_original = zeros(num_x,num_y);



open_system("data_collection");
disp('Opening the simulink');
pause(10);

% 한번 초기화해야 run 했을때 오류 없이 된다.
if wind_type_toggle == 2
    %정규 분포 일때
    set_param('data_collection/Switch Case Action Subsystem1/ND_X_Mean','Value','0');
    set_param('data_collection/Switch Case Action Subsystem1/ND_X_Max','Value','0');
    set_param('data_collection/Switch Case Action Subsystem1/ND_X_Variance','Value','0');

    set_param('data_collection/Switch Case Action Subsystem1/ND_Y_Mean','Value','0');
    set_param('data_collection/Switch Case Action Subsystem1/ND_Y_Max','Value','0');
    set_param('data_collection/Switch Case Action Subsystem1/ND_Y_Variance','Value','0');

    set_param('data_collection/Switch Case Action Subsystem1/ND_Dir_X','Value','0');
    set_param('data_collection/Switch Case Action Subsystem1/ND_Dir_Y','Value','0');
    set_param('data_collection/Switch Case Action Subsystem1/ND_Dir_Z','Value','0');

else
    %거스트 일때
    set_param('data_collection/Switch Case Action Subsystem/wind_x2','Value','0');
    set_param('data_collection/Switch Case Action Subsystem/wind_y2','Value','0');
end


for b = 1:num_x
    for a = 1:num_y

        % % 기준 히트맵의 값을 확인하고 임계값 초과 시 생략
        % if reference_heatmap(a, b) > threshold_value
        %     fprintf('Threshold exceeded at (%d, %d), skipping simulation.\n', a, b);
        % 
        %     % 히트맵 변수들에 100 설정
        %     heatmap_mat_format_endstep_x_error(a, b) = 100;
        %     heatmap_mat_format_endstep_y_error(a, b) = 100;
        %     heatmap_mat_format_endstep_z_error(a, b) = 100;
        %     heatmap_mat_format_endstep_xy_error(a, b) = 100;
        % 
        %     heatmap_mat_format_max_x_error(a, b) = 100;
        %     heatmap_mat_format_max_y_error(a, b) = 100;
        %     heatmap_mat_format_max_z_error(a, b) = 100;
        %     heatmap_mat_format_max_xy_error(a, b) = 100;
        % 
        %     % 원본 히트맵 변수들에 100 설정
        % 
        %     heatmap_mat_format_endstep_x_error_original(a, b) = 100;
        %     heatmap_mat_format_endstep_y_error_original(a, b) = 100;
        %     heatmap_mat_format_endstep_z_error_original(a, b) = 100;
        %     heatmap_mat_format_endstep_xy_error_original(a, b) = 100;
        % 
        %     heatmap_mat_format_max_x_error_original(a, b) = 100;
        %     heatmap_mat_format_max_y_error_original(a, b) = 100;
        %     heatmap_mat_format_max_z_error_original(a, b) = 100;
        %     heatmap_mat_format_max_xy_error_original(a, b) = 100;
        % 
        % 
        %     heatmap_mat_format_max_roll(a, b) = 100;
        %     heatmap_mat_format_max_roll_original(a, b) = 100;
        % 
        %     continue;
        % end


        

        system(open_roscore_for_simulink);
        % rosshutdown;
        % setenv('http://127.0.0.1:11311');
        % rosinit;
        fprintf('-----ROSCORE-------- \n');
        pause(2);
        
        % 모델 이름 정의
        modelName = 'data_collection';

        % 모델 열기
        open_system(modelName);

        % 시뮬레이션 시간 설정 (무한)
        set_param(modelName, 'StopTime', 'inf');

        % 시뮬레이션 시작
        set_param(modelName, 'SimulationCommand', 'start');

        % 다음 명령어 실행
        disp('Simulink starts and the Matlab script continues to run.');



        system(set_automation_env);
        fprintf('set_automation_env.sh is turning on. Please wait. \n');
        pause(20);
        

        if FTC_toggle
            system(open_FTC_MotorFault_terminal);
            fprintf('motor_failure!!!!!!!!!!! with FTC \n');
        else
            system(open_NoFTC_MotorFault_terminal);
            fprintf('motor_failure!!!!!!!!!!! with NoFTC \n');
        end
        pause(10);

        value = cell_format{a,b};
        input_wind_x = value(1);
        input_wind_y = value(2);

        % ====== 토글에 따라 바람 파라미터 설정 ======
        if wind_type_toggle == 2
            % 정규 분포 바람일때
            % sign 함수를 사용하여 손쉽게 방향을 설정
            wind_normal_distribution_Direction_X = sign(input_wind_x);
            wind_normal_distribution_Direction_Y = sign(input_wind_y);

            wind_normal_distribution_X_Mean = abs(input_wind_x);
            wind_normal_distribution_X_Max = wind_normal_distribution_X_Mean + wind_normal_distribution_Max;
            wind_normal_distribution_X_Variance = wind_normal_distribution_Variance;

            wind_normal_distribution_Y_Mean = abs(input_wind_y);
            wind_normal_distribution_Y_Max = wind_normal_distribution_Y_Mean + wind_normal_distribution_Max;
            wind_normal_distribution_Y_Variance = wind_normal_distribution_Variance;

            set_param('data_collection/wind_toggle','Value','wind_type_toggle');

            set_param('data_collection/Switch Case Action Subsystem1/ND_X_Mean','Value','wind_normal_distribution_X_Mean');
            set_param('data_collection/Switch Case Action Subsystem1/ND_X_Max','Value','wind_normal_distribution_X_Max');
            set_param('data_collection/Switch Case Action Subsystem1/ND_X_Variance','Value','wind_normal_distribution_X_Variance');

            set_param('data_collection/Switch Case Action Subsystem1/ND_Y_Mean','Value','wind_normal_distribution_Y_Mean');
            set_param('data_collection/Switch Case Action Subsystem1/ND_Y_Max','Value','wind_normal_distribution_Y_Max');
            set_param('data_collection/Switch Case Action Subsystem1/ND_Y_Variance','Value','wind_normal_distribution_Y_Variance');

            set_param('data_collection/Switch Case Action Subsystem1/ND_Dir_X','Value','wind_normal_distribution_Direction_X');
            set_param('data_collection/Switch Case Action Subsystem1/ND_Dir_Y','Value','wind_normal_distribution_Direction_Y');
            set_param('data_collection/Switch Case Action Subsystem1/ND_Dir_Z','Value','0');

        else
            % ---------------------------
            % 거스트/상수 바람 모드 (1)
            % ---------------------------
            % 실제 input_wind_x, input_wind_y 를 곧바로 거스트 값으로 사용
            set_param('data_collection/wind_toggle','Value','wind_type_toggle');

            set_param('data_collection/Switch Case Action Subsystem/wind_x2','Value','input_wind_x');
            set_param('data_collection/Switch Case Action Subsystem/wind_y2','Value','input_wind_y');
        end
        % ====== 토글에 따른 파라미터 설정 끝 ======

        fprintf('Mode: %s, wind (X=%.1f, Y=%.1f)\n', wind_type_str, input_wind_x, input_wind_y);

        if abs(input_wind_x) > 15 || abs(input_wind_y) > 15
            % disp('hi');
            pause(30);
        elseif abs(input_wind_x) > 10 || abs(input_wind_y) > 10
            % disp('hello');
            pause(30);
        else
            % disp('lol');
            pause(30);
        end





        if evalin('base', 'exist(''max_roll'', ''var'')')
            max_roll = evalin('base', 'max_roll'); % 기본 워크스페이스에서 max_roll 변수를 가져옴
            disp(['max_roll: ', num2str(max_roll)]); % max_roll 의 현재 값을 표시
            if abs(max_roll) > 50   
                heatmap_mat_format_max_roll(a, b) = 100; % max_roll 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_max_roll(a, b) = max_roll; % 그렇지 않으면 max_roll 값을 저장
            end
            heatmap_mat_format_max_roll_original(a, b) = max_roll;
        else
            disp('max_roll not yet defined.'); % max_roll 변수가 정의되지 않았음을 표시
            heatmap_mat_format_max_roll(a, b) = 100; % max_roll 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_max_roll_original(a, b) = 1;
        end



        if evalin('base', 'exist(''max_xy_error'', ''var'')')
            max_xy_error = evalin('base', 'max_xy_error'); % 기본 워크스페이스에서 max_xy_error 변수를 가져옴
            disp(['Current max_xy_error: ', num2str(max_xy_error)]); % max_xy_error 의 현재 값을 표시
            if abs(max_xy_error) > 20
                heatmap_mat_format_max_xy_error(a, b) = 100; % max_xy_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_max_xy_error(a, b) = max_xy_error; % 그렇지 않으면 max_xy_error 값을 저장
            end
            heatmap_mat_format_max_xy_error_original(a, b) = max_xy_error;
        else
            disp('max_xy_error not yet defined.'); % max_xy_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_max_xy_error(a, b) = 100; % max_xy_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_max_xy_error_original(a, b) = 1;
        end

        
        if evalin('base', 'exist(''endstep_xy_error'', ''var'')')
            endstep_xy_error = evalin('base', 'endstep_xy_error'); % 기본 워크스페이스에서 endstep_xy_error 변수를 가져옴
            disp(['Current endstep_xy_error: ', num2str(endstep_xy_error)]); % endstep_xy_error 의 현재 값을 표시
            if abs(endstep_xy_error) > 20
                heatmap_mat_format_endstep_xy_error(a, b) = 100; % endstep_xy_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_endstep_xy_error(a, b) = endstep_xy_error; % 그렇지 않으면 endstep_xy_error 값을 저장
            end
            heatmap_mat_format_endstep_xy_error_original(a, b) = endstep_xy_error;
        else
            disp('endstep_xy_error not yet defined.'); % endstep_xy_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_endstep_xy_error(a, b) = 100; % endstep_xy_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_endstep_xy_error_original(a, b) = 1;
        end




        if evalin('base', 'exist(''endstep_x_error'', ''var'')')
            endstep_x_error = evalin('base', 'endstep_x_error'); % 기본 워크스페이스에서 endstep_x_error 변수를 가져옴
            disp(['Current endstep_x_error: ', num2str(endstep_x_error)]); % endstep_x_error 의 현재 값을 표시
            if abs(endstep_x_error) > 20
                heatmap_mat_format_endstep_x_error(a, b) = 100; % endstep_x_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_endstep_x_error(a, b) = endstep_x_error; % 그렇지 않으면 endstep_x_error 값을 저장
            end
            heatmap_mat_format_endstep_x_error_original(a, b) = endstep_x_error;
        else
            disp('endstep_x_error not yet defined.'); % endstep_x_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_endstep_x_error(a, b) = 100; % endstep_x_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_endstep_x_error_original(a, b) = 1;
        end





        if evalin('base', 'exist(''endstep_y_error'', ''var'')')
            endstep_y_error = evalin('base', 'endstep_y_error'); % 기본 워크스페이스에서 endstep_y_error 변수를 가져옴
            disp(['Current endstep_y_error: ', num2str(endstep_y_error)]); % endstep_y_error 의 현재 값을 표시
            if abs(endstep_y_error) > 20
                heatmap_mat_format_endstep_y_error(a, b) = 100; % endstep_y_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_endstep_y_error(a, b) = endstep_y_error; % 그렇지 않으면 endstep_y_error 값을 저장
            end
            heatmap_mat_format_endstep_y_error_original(a, b) = endstep_y_error;
        else
            disp('endstep_y_error not yet defined.'); % endstep_y_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_endstep_y_error(a, b) = 100; % endstep_y_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_endstep_y_error_original(a, b) = 1;
        end


        if evalin('base', 'exist(''endstep_z_error'', ''var'')')
            endstep_z_error = evalin('base', 'endstep_z_error'); % 기본 워크스페이스에서 endstep_z_error 변수를 가져옴
            disp(['Current endstep_z_error: ', num2str(endstep_z_error)]); % endstep_z_error 의 현재 값을 표시
            if abs(endstep_z_error) > 20
                heatmap_mat_format_endstep_z_error(a, b) = 100; % endstep_z_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_endstep_z_error(a, b) = endstep_z_error; % 그렇지 않으면 endstep_z_error 값을 저장
            end
            heatmap_mat_format_endstep_z_error_original(a, b) = endstep_z_error;
        else
            disp('endstep_z_error not yet defined.'); % endstep_z_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_endstep_z_error(a, b) = 100; % endstep_z_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_endstep_z_error_original(a, b) = 1;
        end


        if evalin('base', 'exist(''max_x_error'', ''var'')')
            max_x_error = evalin('base', 'max_x_error'); % 기본 워크스페이스에서 max_x_error 변수를 가져옴
            disp(['Current max_x_error: ', num2str(max_x_error)]); % max_x_error 의 현재 값을 표시
            if abs(max_x_error) > 20
                heatmap_mat_format_max_x_error(a, b) = 100; % max_x_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_max_x_error(a, b) = max_x_error; % 그렇지 않으면 max_x_error 값을 저장
            end
            heatmap_mat_format_max_x_error_original(a, b) = max_x_error;
        else
            disp('max_x_error not yet defined.'); % max_x_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_max_x_error(a, b) = 100; % max_x_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_max_x_error_original(a, b) = 1;
        end


        if evalin('base', 'exist(''max_y_error'', ''var'')')
            max_y_error = evalin('base', 'max_y_error'); % 기본 워크스페이스에서 max_y_error 변수를 가져옴
            disp(['Current max_y_error: ', num2str(max_y_error)]); % max_y_error 의 현재 값을 표시
            if abs(max_y_error) > 20
                heatmap_mat_format_max_y_error(a, b) = 100; % max_y_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_max_y_error(a, b) = max_y_error; % 그렇지 않으면 max_y_error 값을 저장
            end
            heatmap_mat_format_max_y_error_original(a, b) = max_y_error;
        else
            disp('max_y_error not yet defined.'); % max_y_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_max_y_error(a, b) = 100; % max_y_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_max_y_error_original(a, b) = 1;
        end


        if evalin('base', 'exist(''max_z_error'', ''var'')')
            max_z_error = evalin('base', 'max_z_error'); % 기본 워크스페이스에서 max_z_error 변수를 가져옴
            disp(['Current max_z_error: ', num2str(max_z_error)]); % max_z_error 의 현재 값을 표시
            if abs(max_z_error) > 20
                heatmap_mat_format_max_z_error(a, b) = 100; % max_z_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_max_z_error(a, b) = max_z_error; % 그렇지 않으면 max_z_error 값을 저장
            end
            heatmap_mat_format_max_z_error_original(a, b) = max_z_error;
        else
            disp('max_z_error not yet defined.'); % max_z_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_max_z_error(a, b) = 100; % max_z_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_max_z_error_original(a, b) = 1;
        end


        if evalin('base', 'exist(''min_FCMW'', ''var'')')
            min_FCMW = evalin('base', 'min_FCMW'); % 기본 워크스페이스에서 min_FCMW 변수를 가져옴
            disp(['Current min_FCMW: ', num2str(min_FCMW)]); % min_FCMW 의 현재 값을 표시
            if abs(min_FCMW) > 20
                heatmap_mat_format_min_FCMW(a, b) = 100; % min_FCMW 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_min_FCMW(a, b) = min_FCMW; % 그렇지 않으면 min_FCMW 값을 저장
            end
            heatmap_mat_format_min_FCMW_original(a, b) = min_FCMW;
        else
            disp('min_FCMW not yet defined.'); % min_FCMW 변수가 정의되지 않았음을 표시
            heatmap_mat_format_min_FCMW(a, b) = 100; % min_FCMW 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_min_FCMW_original(a, b) = 1;
        end


        if evalin('base', 'exist(''min_avg_array_FCM'', ''var'')')
            min_avg_array_FCM = evalin('base', 'min_avg_array_FCM'); % 기본 워크스페이스에서 min_avg_array_FCM 변수를 가져옴
            disp(['Current min_avg_array_FCM: ', num2str(min_avg_array_FCM)]); % min_avg_array_FCM 의 현재 값을 표시
            if abs(min_avg_array_FCM) > 20
                heatmap_mat_format_min_avg_array_FCM(a, b) = 100; % min_avg_array_FCM 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_min_avg_array_FCM(a, b) = min_avg_array_FCM; % 그렇지 않으면 min_avg_array_FCM 값을 저장
            end
            heatmap_mat_format_min_avg_array_FCM_original(a, b) = min_avg_array_FCM;
        else
            disp('min_avg_array_FCM not yet defined.'); % min_avg_array_FCM 변수가 정의되지 않았음을 표시
            heatmap_mat_format_min_avg_array_FCM(a, b) = 100; % min_avg_array_FCM 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_min_avg_array_FCM_original(a, b) = 1;
        end


        if evalin('base', 'exist(''max_xyz_error'', ''var'')')
            max_xyz_error = evalin('base', 'max_xyz_error'); % 기본 워크스페이스에서 max_xyz_error 변수를 가져옴
            disp(['Current max_xyz_error: ', num2str(max_xyz_error)]); % max_xyz_error 의 현재 값을 표시
            if abs(max_xyz_error) > 20
                heatmap_mat_format_max_xyz_error(a, b) = 100; % max_xyz_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_max_xyz_error(a, b) = max_xyz_error; % 그렇지 않으면 max_xyz_error 값을 저장
            end
            heatmap_mat_format_max_xyz_error_original(a, b) = max_xyz_error;
        else
            disp('max_xyz_error not yet defined.'); % max_xyz_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_max_xyz_error(a, b) = 100; % max_xyz_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_max_xyz_error_original(a, b) = 1;
        end

        
        if evalin('base', 'exist(''endstep_xyz_error'', ''var'')')
            endstep_xyz_error = evalin('base', 'endstep_xyz_error'); % 기본 워크스페이스에서 endstep_xyz_error 변수를 가져옴
            disp(['Current endstep_xyz_error: ', num2str(endstep_xyz_error)]); % endstep_xyz_error 의 현재 값을 표시
            if abs(endstep_xyz_error) > 20
                heatmap_mat_format_endstep_xyz_error(a, b) = 100; % endstep_xyz_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_endstep_xyz_error(a, b) = endstep_xyz_error; % 그렇지 않으면 endstep_xyz_error 값을 저장
            end
            heatmap_mat_format_endstep_xyz_error_original(a, b) = endstep_xyz_error;
        else
            disp('endstep_xyz_error not yet defined.'); % endstep_xyz_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_endstep_xyz_error(a, b) = 100; % endstep_xyz_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_endstep_xyz_error_original(a, b) = 1;
        end
        

        if evalin('base', 'exist(''avg_FCM_in_range'', ''var'')')
            avg_FCM_in_range = evalin('base', 'avg_FCM_in_range'); % 기본 워크스페이스에서 avg_FCM_in_range 변수를 가져옴
            disp(['Current avg_FCM_in_range: ', num2str(avg_FCM_in_range)]); % avg_FCM_in_range 의 현재 값을 표시
            if abs(avg_FCM_in_range) > 20
                heatmap_mat_format_avg_FCM_in_range(a, b) = 100; % avg_FCM_in_range 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_avg_FCM_in_range(a, b) = avg_FCM_in_range; % 그렇지 않으면 avg_FCM_in_range 값을 저장
            end
            heatmap_mat_format_avg_FCM_in_range_orginal(a, b) = avg_FCM_in_range;
        else
            disp('avg_FCM_in_range not yet defined.'); % avg_FCM_in_range 변수가 정의되지 않았음을 표시
            heatmap_mat_format_avg_FCM_in_range(a, b) = 100; % avg_FCM_in_range 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_avg_FCM_in_range_orginal(a, b) = 1;
        end

        
        if evalin('base', 'exist(''avg_FCM_saturated_in_range'', ''var'')')
            avg_FCM_saturated_in_range = evalin('base', 'avg_FCM_saturated_in_range'); % 기본 워크스페이스에서 avg_FCM_saturated_in_range 변수를 가져옴
            disp(['Current avg_FCM_saturated_in_range: ', num2str(avg_FCM_saturated_in_range)]); % avg_FCM_saturated_in_range 의 현재 값을 표시
            if abs(avg_FCM_saturated_in_range) > 20
                heatmap_mat_format_avg_FCM_saturated_in_range(a, b) = 100; % avg_FCM_saturated_in_range 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_avg_FCM_saturated_in_range(a, b) = avg_FCM_saturated_in_range; % 그렇지 않으면 avg_FCM_saturated_in_range 값을 저장
            end
            heatmap_mat_format_avg_FCM_saturated_in_range_orginal(a, b) = avg_FCM_saturated_in_range;
        else
            disp('avg_FCM_saturated_in_range not yet defined.'); % avg_FCM_saturated_in_range 변수가 정의되지 않았음을 표시
            heatmap_mat_format_avg_FCM_saturated_in_range(a, b) = 100; % avg_FCM_saturated_in_range 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_avg_FCM_saturated_in_range_orginal(a, b) = 1;
        end


        if evalin('base', 'exist(''min_avg_array_FCM_saturated'', ''var'')')
            min_avg_array_FCM_saturated = evalin('base', 'min_avg_array_FCM_saturated'); % 기본 워크스페이스에서 min_avg_array_FCM_saturated 변수를 가져옴
            disp(['Current min_avg_array_FCM_saturated: ', num2str(min_avg_array_FCM_saturated)]); % min_avg_array_FCM_saturated 의 현재 값을 표시
            if abs(min_avg_array_FCM_saturated) > 20
                heatmap_mat_format_min_avg_array_FCM_saturated(a, b) = 100; % min_avg_array_FCM_saturated 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_min_avg_array_FCM_saturated(a, b) = min_avg_array_FCM_saturated; % 그렇지 않으면 min_avg_array_FCM_saturated 값을 저장
            end
            heatmap_mat_format_min_avg_array_FCM_saturated_original(a, b) = min_avg_array_FCM_saturated;
        else
            disp('min_avg_array_FCM_saturated not yet defined.'); % min_avg_array_FCM_saturated 변수가 정의되지 않았음을 표시
            heatmap_mat_format_min_avg_array_FCM_saturated(a, b) = 100; % min_avg_array_FCM_saturated 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_min_avg_array_FCM_saturated_original(a, b) = 1;
        end

        if evalin('base', 'exist(''max_avg_xyz_error'', ''var'')')
            max_avg_xyz_error = evalin('base', 'max_avg_xyz_error'); % 기본 워크스페이스에서 max_avg_xyz_error 변수를 가져옴
            disp(['Current max_avg_xyz_error: ', num2str(max_avg_xyz_error)]); % max_avg_xyz_error 의 현재 값을 표시
            if abs(max_avg_xyz_error) > 20
                heatmap_mat_format_max_avg_xyz_error(a, b) = 100; % max_avg_xyz_error 가 threshold 보다  크면 null 값을 저장
            else
                heatmap_mat_format_max_avg_xyz_error(a, b) = max_avg_xyz_error; % 그렇지 않으면 max_avg_xyz_error 값을 저장
            end
            heatmap_mat_format_max_avg_xyz_error_original(a, b) = max_avg_xyz_error;
        else
            disp('max_avg_xyz_error not yet defined.'); % max_avg_xyz_error 변수가 정의되지 않았음을 표시
            heatmap_mat_format_max_avg_xyz_error(a, b) = 100; % max_avg_xyz_error 변수가 정의되지 않았으면 null 값을 저장
            heatmap_mat_format_max_avg_xyz_error_original(a, b) = 1;
        end
        

        if wind_type_toggle == 2
            %정규 분포 일때
            set_param('data_collection/Switch Case Action Subsystem1/ND_X_Mean','Value','0');
            set_param('data_collection/Switch Case Action Subsystem1/ND_X_Max','Value','0');
            set_param('data_collection/Switch Case Action Subsystem1/ND_X_Variance','Value','0');

            set_param('data_collection/Switch Case Action Subsystem1/ND_Y_Mean','Value','0');
            set_param('data_collection/Switch Case Action Subsystem1/ND_Y_Max','Value','0');
            set_param('data_collection/Switch Case Action Subsystem1/ND_Y_Variance','Value','0');

            set_param('data_collection/Switch Case Action Subsystem1/ND_Dir_X','Value','0');
            set_param('data_collection/Switch Case Action Subsystem1/ND_Dir_Y','Value','0');
            set_param('data_collection/Switch Case Action Subsystem1/ND_Dir_Z','Value','0');

        else
            %거스트 일때
            set_param('data_collection/Switch Case Action Subsystem/wind_x2','Value','0');
            set_param('data_collection/Switch Case Action Subsystem/wind_y2','Value','0');
        end

        fprintf('This step test is finished. \n input_wind_x = %.1f , input_wind_y = %.1f measured wind \n', input_wind_x, input_wind_y);

        
        % Now you can kill the terminals using their PIDs
        system(close_terminal);

        % 시뮬레이션 멈춤
        set_param(modelName, 'SimulationCommand', 'stop');
        
        fprintf('---------Terminals and simulink closed---------------- \n\n');
        heatmap_mat_format_postion_xyz{a,b} = out.ScopeData_Postion;
        heatmap_mat_format_total_FCM{a,b} = out.ScopeData_FCM;
        pause(pause_time_according_to_GUI);





    end
end


%% Save data after algorithm ends

% 폴더 이름 생성
save_folder = sprintf('%dby%d_increment_%d_fault_%d_%d_%d_date_%d_%s_%s_window_%d', wind_upper * 2, wind_upper * 2, increment, motor_failure_number, motor_failure_number1,motor_failure_number2,start_date, ftc_status_str, wind_type_str, window_size_.Value);

% 폴더가 존재하지 않으면 생성
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

% 파일 이름 생성
filename = sprintf('%s/%dby%d_increment_%d_fault_%d_%d_%d_date_%d_%s_%s_window_%d.mat', save_folder, wind_upper * 2, wind_upper * 2, increment, motor_failure_number, motor_failure_number1, motor_failure_number2, start_date, ftc_status_str, wind_type_str,window_size_.Value);

% 로그 파일 생성
diary off

% 2) 경로(folder), 파일명(name), 확장자(ext) 분리
[folder, name, ext] = fileparts(filename);

% 3) .txt 확장자로 변경하여 logname 생성
logname = [name, '.txt'];

destPath = fullfile(folder,logname);
status = movefile('diary.txt', destPath);

if status
    fprintf('Log move and renaming successful.\n');
else
    fprintf('Log move and renaming failed.\n');
end

% 히트맵 제목
titlename  = sprintf('xy maximum error for No. %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, ftc_status_str, wind_type_str);

titlename1 = sprintf('roll maximum error for No. %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, ftc_status_str, wind_type_str);

titlename2 = sprintf('xy max error at Last Time Step for No. %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, ftc_status_str, wind_type_str);

titlename3 = sprintf('Min average FCM for No. %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, ftc_status_str, wind_type_str);

titlename4  = sprintf('xyz maximum error for No. %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, ftc_status_str, wind_type_str);

titlename5  = sprintf('Avg FCM in range for No. %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, ftc_status_str, wind_type_str);

titlename6  = sprintf('Avg FCM Saturated in range for No. %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, ftc_status_str, wind_type_str);

titlename7  = sprintf('Min average FCM Saturated for No. %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, ftc_status_str, wind_type_str);

titlename8  = sprintf('Max average xyz error for No. %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, ftc_status_str, wind_type_str);


% 변수들을 저장 (MAT 파일 형식 7.3 지정)
save(filename, '-v7.3');


%% Heatmap with value display

figure();
hh = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_max_xy_error_original);
hh.Title = strcat(titlename, ' original');
hh.XLabel = 'Wind Y';
hh.YLabel = 'Wind X';
hh.Colormap = jet;
hh.ColorLimits = [0 5];
hh.CellLabelColor = 'none';
hh.GridVisible = 'off';


figure();
kk = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_max_roll_original);
kk.Title = strcat(titlename1, ' original');
kk.XLabel = 'Wind Y';
kk.YLabel = 'Wind X';
kk.Colormap = jet;
kk.ColorLimits = [0 30];
kk.CellLabelColor = 'none';
kk.GridVisible = 'off';



% figure();
% asas = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_endstep_xy_error_original);
% asas.Title = strcat(titlename2, ' original');
% asas.XLabel = 'Wind Y';
% asas.YLabel = 'Wind X';
% asas.Colormap = jet;
% asas.ColorLimits = [0 5];
% asas.CellLabelColor = 'none';
% asas.GridVisible = 'off';
% 
% figure();
% bsbs = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_endstep_xy_error);
% bsbs.Title = titlename2;
% bsbs.XLabel = 'Wind Y';
% bsbs.YLabel = 'Wind X';
% bsbs.Colormap = jet;
% bsbs.ColorLimits = [0 5];
% bsbs.CellLabelColor = 'none';
% bsbs.GridVisible = 'off';


figure();
cscs = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_min_avg_array_FCM_original);
cscs.Title = strcat(titlename3, ' original');
cscs.XLabel = 'Wind Y';
cscs.YLabel = 'Wind X';
cscs.Colormap = flipud(jet);
cscs.ColorLimits = [0 1];
cscs.CellLabelColor = 'none';
cscs.GridVisible = 'off';


figure();
mm = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_max_xyz_error_original);
mm.Title = strcat(titlename4, ' original');
mm.XLabel = 'Wind Y';
mm.YLabel = 'Wind X';
mm.Colormap = jet;
mm.ColorLimits = [0 5];
mm.CellLabelColor = 'none';
mm.GridVisible = 'off';




figure();
pp = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_avg_FCM_in_range_orginal);
pp.Title = strcat(titlename5, ' original');
pp.XLabel = 'Wind Y';
pp.YLabel = 'Wind X';
pp.Colormap = flipud(jet);
pp.ColorLimits = [0 1];
pp.CellLabelColor = 'none';
pp.GridVisible = 'off';

figure();
qq = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_avg_FCM_saturated_in_range_orginal);
qq.Title = strcat(titlename6, ' original');
qq.XLabel = 'Wind Y';
qq.YLabel = 'Wind X';
qq.Colormap = flipud(jet);
qq.ColorLimits = [0 1];
qq.CellLabelColor = 'none';
qq.GridVisible = 'off';

figure();
rr = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_min_avg_array_FCM_saturated_original);
rr.Title = strcat(titlename7, ' original');
rr.XLabel = 'Wind Y';
rr.YLabel = 'Wind X';
rr.Colormap = flipud(jet);
rr.ColorLimits = [0 1];
rr.CellLabelColor = 'none';
rr.GridVisible = 'off';

figure();
ss = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper,heatmap_mat_format_max_avg_xyz_error_original);
ss.Title = strcat(titlename8, ' original');
ss.XLabel = 'Wind Y';
ss.YLabel = 'Wind X';
ss.Colormap = jet;
ss.ColorLimits = [0 5];
ss.CellLabelColor = 'none';
ss.GridVisible = 'off';

%% 3D plot에서 xy 평면은 xy error 히트맵 이고 z축은 FCM
% 범위 정의
rowVec = wind_lower:increment:wind_upper;  % Heatmap의 행 = Wind X
colVec = wind_lower:increment:wind_upper;  % Heatmap의 열 = Wind Y

% meshgrid 생성 (열/행 순서 맞추기)
[WindY, WindX] = meshgrid(colVec, rowVec);

figure;
hSurface = surf(WindY, WindX, zeros(size(WindX)));  
% 평면을 생성한 후, 평면의 FaceColor를 texture mapping 방식으로 설정
set(hSurface, 'FaceColor', 'texturemap', 'CData', heatmap_mat_format_max_xy_error_original, ...
    'EdgeColor', 'none');
colormap(jet);
caxis([0 5]);
colorbar;
hold on;

% 동일한 (WindY, WindX) 위치에서, FCM 값 (min_avg_array_FCM)을 z좌표로 하는 점 표시
scatter3(WindY(:), WindX(:), heatmap_mat_format_min_avg_array_FCM_original(:), 11, 'k', 'filled');

xlabel('Wind Y'); ylabel('Wind X'); zlabel('FCM Value');
title(sprintf('3D XY error vs FCM (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
axis tight;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정


%% 3D plot에서 xy 평면은 xyz error 히트맵 이고 z축은 FCM
% 범위 정의
rowVec = wind_lower:increment:wind_upper;  % Heatmap의 행 = Wind X
colVec = wind_lower:increment:wind_upper;  % Heatmap의 열 = Wind Y

% meshgrid 생성 (열/행 순서 맞추기)
[WindY, WindX] = meshgrid(colVec, rowVec);

figure;
hSurface = surf(WindY, WindX, zeros(size(WindX)));  
% 평면을 생성한 후, 평면의 FaceColor를 texture mapping 방식으로 설정
set(hSurface, 'FaceColor', 'texturemap', 'CData', heatmap_mat_format_max_xyz_error_original, ...
    'EdgeColor', 'none');
colormap(jet);
caxis([0 5]);
colorbar;
hold on;

% 동일한 (WindY, WindX) 위치에서, FCM 값 (min_avg_array_FCM)을 z좌표로 하는 점 표시
scatter3(WindY(:), WindX(:), heatmap_mat_format_min_avg_array_FCM_original(:), 11, 'k', 'filled');

xlabel('Wind Y'); ylabel('Wind X'); zlabel('FCM Value');
title(sprintf('3D XYZ error vs FCM (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
axis tight;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정


%% 3D plot: 곡면 높이 = FCM, 곡면 색상 = xyz error heatmap orginal , 연속적인 형상
[rowVec, colVec] = deal(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper);
[WindY, WindX]  = meshgrid(colVec, rowVec);

% Z 값: FCM (min_avg_array_FCM)
Z_surf = heatmap_mat_format_min_avg_array_FCM_original;

% CData: xyz error heatmap (원본)
C_surf = heatmap_mat_format_max_xyz_error_original;

figure;
hSurf = surf( WindY, WindX, Z_surf, ...      % X, Y, 높이(Z)
              C_surf, ...                     % 색상 매핑할 값
              'EdgeColor','none', ...         % 매끄러운 면
              'FaceColor','interp' );         % 색상 보간
colormap(jet);
caxis([0 5]);   % 에러 범위에 맞춰 컬러바 스케일
colorbar;
hold on;

% FCM 점도 곡면 위에 표시 (선택)
scatter3( WindY(:), WindX(:), Z_surf(:), 11, 'k', 'filled' );

xlabel('Wind Y');  ylabel('Wind X');  zlabel('FCM Value');
title(sprintf('3D XYZ error vs FCM (Color : orginal) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
axis tight;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3);


%% 3D plot: 곡면 높이 = FCM, 색상 = XYZ error heatmap orginal, 연속 α 그라데이션 (interp)
rowVec = wind_lower:increment:wind_upper;
colVec = wind_lower:increment:wind_upper;
[WindY, WindX] = meshgrid(colVec, rowVec);

Z_surf = heatmap_mat_format_min_avg_array_FCM_original;      % 높이: FCM
C_surf = heatmap_mat_format_max_xyz_error_original; % 색상: XYZ error

% AlphaData: Z_surf 값 자체를 0~1 사이로 정규화 → 연속 그라데이션
% 1) min–max 정규화 (전체 범위 기준)
alphaData = mat2gray(Z_surf); % 또는, Image Processing Toolbox가 있으면 mat2gray 한 줄로

figure;
hSurf = surf( ...
    WindY, WindX, Z_surf, ...   % X, Y, Z
    C_surf, ...                  % CData
    'FaceColor',    'interp',    ... % 면 색 보간
    'EdgeColor',    'none',    ... % 경계선 보간
    'FaceAlpha',    'interp',    ... % 투명도 보간
    'AlphaData',    alphaData,   ... % 연속 그라데이션 α
    'AlphaDataMapping','scaled'  ... % Z 값 범위 → α 값 선형 매핑
);
set(gca, 'ALim', [0 1]);         % Z 값 범위 지정

colormap(jet);
caxis([0 5]);
colorbar;

hold on;
scatter3(WindY(:), WindX(:), Z_surf(:), 11, 'k', 'filled');

xlabel('Wind Y');
ylabel('Wind X');
zlabel('FCM Value');
title(sprintf('3D XYZ error vs FCM (Color : orginal) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));

axis tight;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3);

%% 3D plot: 곡면 높이 = FCM, 곡면 색상 = xyz error heatmap orginal , 스무딩 FCM , 연속적인 형상
% ── 기존 그리드 정의 ──
[rowVec, colVec] = deal(wind_lower:increment:wind_upper);
[WindY, WindX]   = meshgrid(colVec, rowVec);

Z_surf = heatmap_mat_format_min_avg_array_FCM_original;        % FCM (0~1)
C_surf = heatmap_mat_format_max_xyz_error_original;   % XYZ error

% ── 여기부터 추가: 고해상도 격자 + 보간 + 스무딩 ──
fine = 0.5;                                           % 세분화 간격
[rowF, colF] = deal(wind_lower:fine:wind_upper);
[WYf, WXf]   = meshgrid(colF, rowF);

% 보간 함수 정의
F_fcm = scatteredInterpolant(WindY(:), -WindX(:), Z_surf(:), 'natural', 'linear');
F_err = scatteredInterpolant(WindY(:), -WindX(:), C_surf(:), 'natural', 'linear');

% 고해상도 데이터
Z_fine   = F_fcm(WYf, -WXf);
Err_fine = F_err(WYf, -WXf);

% 2차원 데이터 가우스 필터링
sigma      = 1;           % 표준편차
filterSize = [5 5];       % 홀수×홀수 크기
Z_smooth = imgaussfilt(Z_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정


% ── 여기까지 추가 ──

% ── 이후 원래대로 surf 호출하되, 그리드와 데이터 변수를 바꿔줌 ──
figure;
hSurf = surf(WYf, WXf, Z_smooth, Err_fine, ...
             'EdgeColor','none','FaceColor','interp');
colormap(jet);  colorbar; caxis([0 5]);
xlabel('Wind Y');  ylabel('Wind X');  zlabel('Smoothed FCM');
title(sprintf('3D XYZ error vs FCM (Color : orginal) (Smooth : FCM) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
shading interp;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3); 

% ── 원본 FCM 점 찍고 싶으면 (선택) ──
hold on;
scatter3(WindY(:), WindX(:), Z_surf(:), 7, 'k', 'filled');
hold on;
scatter3(WYf(:), WXf(:), Z_fine(:), 7, 'm+');
hold on;
scatter3(WYf(:), WXf(:), Z_smooth(:), 7, 'cx');



%% 3D plot: 곡면 높이 = FCM, 곡면 색상 = xyz error heatmap orginal , 스무딩 FCM xyz_error, 연속적인 형상
% ── 기존 그리드 정의 ──
[rowVec, colVec] = deal(wind_lower:increment:wind_upper);
[WindY, WindX]   = meshgrid(colVec, rowVec);

Z_surf = heatmap_mat_format_min_avg_array_FCM_original;        % FCM (0~1)
C_surf = heatmap_mat_format_max_xyz_error_original;   % XYZ error

% ── 여기부터 추가: 고해상도 격자 + 보간 + 스무딩 ──
fine = 0.5;                                           % 세분화 간격
[rowF, colF] = deal(wind_lower:fine:wind_upper);
[WYf, WXf]   = meshgrid(colF, rowF);

% 보간 함수 정의
F_fcm = scatteredInterpolant(WindY(:), -WindX(:), Z_surf(:), 'natural', 'linear');
F_err = scatteredInterpolant(WindY(:), -WindX(:), C_surf(:), 'natural', 'linear');

% 고해상도 데이터
Z_fine   = F_fcm(WYf, -WXf);
Err_fine = F_err(WYf, -WXf);

% 2차원 데이터 가우스 필터링
sigma      = 1;           % 표준편차
filterSize = [5 5];       % 홀수×홀수 크기
Z_smooth = imgaussfilt(Z_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정
Err_smooth = imgaussfilt(Err_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정


% ── 여기까지 추가 ──

% ── 이후 원래대로 surf 호출하되, 그리드와 데이터 변수를 바꿔줌 ──
figure;
hSurf = surf(WYf, WXf, Z_smooth, Err_smooth, ...
             'EdgeColor','none','FaceColor','interp');
colormap(jet);  colorbar; caxis([0 5]);
xlabel('Wind Y');  ylabel('Wind X');  zlabel('Smoothed FCM');
title(sprintf('3D XYZ error vs FCM (Color : orginal) (Smooth : FCM, XYZ error) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
shading interp;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3); 

% ── 원본 FCM 점 찍고 싶으면 (선택) ──
hold on;
scatter3(WindY(:), WindX(:), Z_surf(:), 7, 'k', 'filled');
hold on;
scatter3(WYf(:), WXf(:), Z_fine(:), 7, 'm+');
hold on;
scatter3(WYf(:), WXf(:), Z_smooth(:), 7, 'cx');


%% 3D plot: 곡면 높이 = avg FCM in range, 곡면 색상 = xyz error heatmap orginal , 연속적인 형상
[rowVec, colVec] = deal(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper);
[WindY, WindX]  = meshgrid(colVec, rowVec);

% Z 값: FCM (avg_FCM_in_range)
Z_surf = heatmap_mat_format_avg_FCM_in_range_orginal;

% CData: xyz error heatmap (원본)
C_surf = heatmap_mat_format_max_xyz_error_original;

figure;
hSurf = surf( WindY, WindX, Z_surf, ...      % X, Y, 높이(Z)
              C_surf, ...                     % 색상 매핑할 값
              'EdgeColor','none', ...         % 매끄러운 면
              'FaceColor','interp' );         % 색상 보간
colormap(jet);
caxis([0 5]);   % 에러 범위에 맞춰 컬러바 스케일
colorbar;
hold on;

% FCM 점도 곡면 위에 표시 (선택)
scatter3( WindY(:), WindX(:), Z_surf(:), 11, 'k', 'filled' );

xlabel('Wind Y');  ylabel('Wind X');  zlabel('FCM Value');
title(sprintf('3D XYZ error vs avg FCM in range (Color : orginal) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
axis tight;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3);



%% 3D plot: 곡면 높이 = avg FCM in range, 곡면 색상 = xyz error heatmap orginal , 스무딩 FCM , 연속적인 형상
% ── 기존 그리드 정의 ──
[rowVec, colVec] = deal(wind_lower:increment:wind_upper);
[WindY, WindX]   = meshgrid(colVec, rowVec);

Z_surf = heatmap_mat_format_avg_FCM_in_range_orginal;        % FCM (0~1)
C_surf = heatmap_mat_format_max_xyz_error_original;   % XYZ error

% ── 여기부터 추가: 고해상도 격자 + 보간 + 스무딩 ──
fine = 0.5;                                           % 세분화 간격
[rowF, colF] = deal(wind_lower:fine:wind_upper);
[WYf, WXf]   = meshgrid(colF, rowF);

% 보간 함수 정의
F_fcm = scatteredInterpolant(WindY(:), -WindX(:), Z_surf(:), 'natural', 'linear');
F_err = scatteredInterpolant(WindY(:), -WindX(:), C_surf(:), 'natural', 'linear');

% 고해상도 데이터
Z_fine   = F_fcm(WYf, -WXf);
Err_fine = F_err(WYf, -WXf);

% 2차원 데이터 가우스 필터링
sigma      = 1;           % 표준편차
filterSize = [5 5];       % 홀수×홀수 크기
Z_smooth = imgaussfilt(Z_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정


% ── 여기까지 추가 ──

% ── 이후 원래대로 surf 호출하되, 그리드와 데이터 변수를 바꿔줌 ──
figure;
hSurf = surf(WYf, WXf, Z_smooth, Err_fine, ...
             'EdgeColor','none','FaceColor','interp');
colormap(jet);  colorbar; caxis([0 5]);
xlabel('Wind Y');  ylabel('Wind X');  zlabel('Smoothed FCM');
title(sprintf('3D XYZ error vs avg FCM in range (Color : orginal) (Smooth : FCM) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
shading interp;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3); 

% ── 원본 FCM 점 찍고 싶으면 (선택) ──
hold on;
scatter3(WindY(:), WindX(:), Z_surf(:), 7, 'k', 'filled');
hold on;
scatter3(WYf(:), WXf(:), Z_fine(:), 7, 'm+');
hold on;
scatter3(WYf(:), WXf(:), Z_smooth(:), 7, 'cx');



%% 3D plot: 곡면 높이 = avg FCM in range, 곡면 색상 = xyz error heatmap orginal , 스무딩 FCM xyz_error, 연속적인 형상
% ── 기존 그리드 정의 ──
[rowVec, colVec] = deal(wind_lower:increment:wind_upper);
[WindY, WindX]   = meshgrid(colVec, rowVec);

Z_surf = heatmap_mat_format_avg_FCM_in_range_orginal;        % FCM (0~1)
C_surf = heatmap_mat_format_max_xyz_error_original;   % XYZ error

% ── 여기부터 추가: 고해상도 격자 + 보간 + 스무딩 ──
fine = 0.5;                                           % 세분화 간격
[rowF, colF] = deal(wind_lower:fine:wind_upper);
[WYf, WXf]   = meshgrid(colF, rowF);

% 보간 함수 정의
F_fcm = scatteredInterpolant(WindY(:), -WindX(:), Z_surf(:), 'natural', 'linear');
F_err = scatteredInterpolant(WindY(:), -WindX(:), C_surf(:), 'natural', 'linear');

% 고해상도 데이터
Z_fine   = F_fcm(WYf, -WXf);
Err_fine = F_err(WYf, -WXf);

% 2차원 데이터 가우스 필터링
sigma      = 1;           % 표준편차
filterSize = [5 5];       % 홀수×홀수 크기
Z_smooth = imgaussfilt(Z_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정
Err_smooth = imgaussfilt(Err_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정


% ── 여기까지 추가 ──

% ── 이후 원래대로 surf 호출하되, 그리드와 데이터 변수를 바꿔줌 ──
figure;
hSurf = surf(WYf, WXf, Z_smooth, Err_smooth, ...
             'EdgeColor','none','FaceColor','interp');
colormap(jet);  colorbar; caxis([0 5]);
xlabel('Wind Y');  ylabel('Wind X');  zlabel('Smoothed FCM');
title(sprintf('3D XYZ error vs avg FCM in range (Color : orginal) (Smooth : FCM, XYZ error) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
shading interp;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3); 

% ── 원본 FCM 점 찍고 싶으면 (선택) ──
hold on;
scatter3(WindY(:), WindX(:), Z_surf(:), 7, 'k', 'filled');
hold on;
scatter3(WYf(:), WXf(:), Z_fine(:), 7, 'm+');
hold on;
scatter3(WYf(:), WXf(:), Z_smooth(:), 7, 'cx');






%% 3D plot: 곡면 높이 = FCM, 색상 = FCM값
rowVec = wind_lower:increment:wind_upper;  % Heatmap의 행 = Wind X
colVec = wind_lower:increment:wind_upper;  % Heatmap의 열 = Wind Y
[WindY, WindX] = meshgrid(colVec, rowVec);


figure;
% 2) FCM 점들 (scatter)
scatter3( ...
    WindY(:), WindX(:), heatmap_mat_format_min_avg_array_FCM_original(:), ...  % X,Y,Z=FCM
    36, 'k', 'filled' );
hold on;
% 3) FCM 값을 연결하는 3D surface
hSurf = surf( ...
    WindY, WindX, heatmap_mat_format_min_avg_array_FCM_original, ...       % Z=FCM
    'EdgeColor','none', 'FaceColor','interp', ...                  % 선만 보이고 면은 투명
    'LineWidth',1 );

xlabel('Wind Y');  ylabel('Wind X');  zlabel('FCM Value');
title(sprintf('3D FCM (Color : FCM value) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
axis tight;
colormap(jet);
caxis([0 1]);
colorbar;
hold on;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3);


%% 3D plot: 곡면 높이 = avg FCM saturated in range, 곡면 색상 = xyz error heatmap orginal , 연속적인 형상
[rowVec, colVec] = deal(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper);
[WindY, WindX]  = meshgrid(colVec, rowVec);

% Z 값: FCM (avg_FCM_saturated_in_range)
Z_surf = heatmap_mat_format_avg_FCM_saturated_in_range_orginal;

% CData: xyz error heatmap (원본)
C_surf = heatmap_mat_format_max_xyz_error_original;

figure;
hSurf = surf( WindY, WindX, Z_surf, ...      % X, Y, 높이(Z)
              C_surf, ...                     % 색상 매핑할 값
              'EdgeColor','none', ...         % 매끄러운 면
              'FaceColor','interp' );         % 색상 보간
colormap(jet);
caxis([0 5]);   % 에러 범위에 맞춰 컬러바 스케일
colorbar;
hold on;

% FCM 점도 곡면 위에 표시 (선택)
scatter3( WindY(:), WindX(:), Z_surf(:), 11, 'k', 'filled' );

xlabel('Wind Y');  ylabel('Wind X');  zlabel('FCM Value');
title(sprintf('3D XYZ error vs avg FCM saturated in range (Color : orginal) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
axis tight;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3);



%% 3D plot: 곡면 높이 = avg FCM saturated in range, 곡면 색상 = xyz error heatmap orginal , 스무딩 FCM , 연속적인 형상
% ── 기존 그리드 정의 ──
[rowVec, colVec] = deal(wind_lower:increment:wind_upper);
[WindY, WindX]   = meshgrid(colVec, rowVec);

Z_surf = heatmap_mat_format_avg_FCM_saturated_in_range_orginal;        % FCM (0~1)
C_surf = heatmap_mat_format_max_xyz_error_original;   % XYZ error

% ── 여기부터 추가: 고해상도 격자 + 보간 + 스무딩 ──
fine = 0.5;                                           % 세분화 간격
[rowF, colF] = deal(wind_lower:fine:wind_upper);
[WYf, WXf]   = meshgrid(colF, rowF);

% 보간 함수 정의
F_fcm = scatteredInterpolant(WindY(:), -WindX(:), Z_surf(:), 'natural', 'linear');
F_err = scatteredInterpolant(WindY(:), -WindX(:), C_surf(:), 'natural', 'linear');

% 고해상도 데이터
Z_fine   = F_fcm(WYf, -WXf);
Err_fine = F_err(WYf, -WXf);

% 2차원 데이터 가우스 필터링
sigma      = 1;           % 표준편차
filterSize = [5 5];       % 홀수×홀수 크기
Z_smooth = imgaussfilt(Z_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정


% ── 여기까지 추가 ──

% ── 이후 원래대로 surf 호출하되, 그리드와 데이터 변수를 바꿔줌 ──
figure;
hSurf = surf(WYf, WXf, Z_smooth, Err_fine, ...
             'EdgeColor','none','FaceColor','interp');
colormap(jet);  colorbar; caxis([0 5]);
xlabel('Wind Y');  ylabel('Wind X');  zlabel('Smoothed FCM');
title(sprintf('3D XYZ error vs avg FCM saturated in range (Color : orginal) (Smooth : FCM) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
shading interp;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3); 

% ── 원본 FCM 점 찍고 싶으면 (선택) ──
hold on;
scatter3(WindY(:), WindX(:), Z_surf(:), 7, 'k', 'filled');
hold on;
scatter3(WYf(:), WXf(:), Z_fine(:), 7, 'm+');
hold on;
scatter3(WYf(:), WXf(:), Z_smooth(:), 7, 'cx');



%% 3D plot: 곡면 높이 = avg FCM saturated in range, 곡면 색상 = xyz error heatmap orginal , 스무딩 FCM xyz_error, 연속적인 형상
% ── 기존 그리드 정의 ──
[rowVec, colVec] = deal(wind_lower:increment:wind_upper);
[WindY, WindX]   = meshgrid(colVec, rowVec);

Z_surf = heatmap_mat_format_avg_FCM_saturated_in_range_orginal;        % FCM (0~1)
C_surf = heatmap_mat_format_max_xyz_error_original;   % XYZ error

% ── 여기부터 추가: 고해상도 격자 + 보간 + 스무딩 ──
fine = 0.5;                                           % 세분화 간격
[rowF, colF] = deal(wind_lower:fine:wind_upper);
[WYf, WXf]   = meshgrid(colF, rowF);

% 보간 함수 정의
F_fcm = scatteredInterpolant(WindY(:), -WindX(:), Z_surf(:), 'natural', 'linear');
F_err = scatteredInterpolant(WindY(:), -WindX(:), C_surf(:), 'natural', 'linear');

% 고해상도 데이터
Z_fine   = F_fcm(WYf, -WXf);
Err_fine = F_err(WYf, -WXf);

% 2차원 데이터 가우스 필터링
sigma      = 1;           % 표준편차
filterSize = [5 5];       % 홀수×홀수 크기
Z_smooth = imgaussfilt(Z_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정
Err_smooth = imgaussfilt(Err_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정


% ── 여기까지 추가 ──

% ── 이후 원래대로 surf 호출하되, 그리드와 데이터 변수를 바꿔줌 ──
figure;
hSurf = surf(WYf, WXf, Z_smooth, Err_smooth, ...
             'EdgeColor','none','FaceColor','interp');
colormap(jet);  colorbar; caxis([0 5]);
xlabel('Wind Y');  ylabel('Wind X');  zlabel('Smoothed FCM');
title(sprintf('3D XYZ error vs avg FCM saturated in range (Color : orginal) (Smooth : FCM, XYZ error) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
shading interp;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3); 

% ── 원본 FCM 점 찍고 싶으면 (선택) ──
hold on;
scatter3(WindY(:), WindX(:), Z_surf(:), 7, 'k', 'filled');
hold on;
scatter3(WYf(:), WXf(:), Z_fine(:), 7, 'm+');
hold on;
scatter3(WYf(:), WXf(:), Z_smooth(:), 7, 'cx');

%% 3D plot: 곡면 높이 = min avg FCM saturated, 곡면 색상 = xyz error heatmap orginal , 연속적인 형상
[rowVec, colVec] = deal(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper);
[WindY, WindX]  = meshgrid(colVec, rowVec);

% Z 값: FCM (min_avg_array_FCM_saturated)
Z_surf = heatmap_mat_format_min_avg_array_FCM_saturated_original;

% CData: xyz error heatmap (원본)
C_surf = heatmap_mat_format_max_xyz_error_original;

figure;
hSurf = surf( WindY, WindX, Z_surf, ...      % X, Y, 높이(Z)
              C_surf, ...                     % 색상 매핑할 값
              'EdgeColor','none', ...         % 매끄러운 면
              'FaceColor','interp' );         % 색상 보간
colormap(jet);
caxis([0 5]);   % 에러 범위에 맞춰 컬러바 스케일
colorbar;
hold on;

% FCM 점도 곡면 위에 표시 (선택)
scatter3( WindY(:), WindX(:), Z_surf(:), 11, 'k', 'filled' );

xlabel('Wind Y');  ylabel('Wind X');  zlabel('FCM Value');
title(sprintf('3D XYZ error vs min avg FCM saturated (Color : orginal) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
axis tight;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3);



%% 3D plot: 곡면 높이 = min avg FCM saturated, 곡면 색상 = xyz error heatmap orginal , 스무딩 FCM , 연속적인 형상
% ── 기존 그리드 정의 ──
[rowVec, colVec] = deal(wind_lower:increment:wind_upper);
[WindY, WindX]   = meshgrid(colVec, rowVec);

Z_surf = heatmap_mat_format_min_avg_array_FCM_saturated_original;        % FCM (0~1)
C_surf = heatmap_mat_format_max_xyz_error_original;   % XYZ error

% ── 여기부터 추가: 고해상도 격자 + 보간 + 스무딩 ──
fine = 0.5;                                           % 세분화 간격
[rowF, colF] = deal(wind_lower:fine:wind_upper);
[WYf, WXf]   = meshgrid(colF, rowF);

% 보간 함수 정의
F_fcm = scatteredInterpolant(WindY(:), -WindX(:), Z_surf(:), 'natural', 'linear');
F_err = scatteredInterpolant(WindY(:), -WindX(:), C_surf(:), 'natural', 'linear');

% 고해상도 데이터
Z_fine   = F_fcm(WYf, -WXf);
Err_fine = F_err(WYf, -WXf);

% 2차원 데이터 가우스 필터링
sigma      = 1;           % 표준편차
filterSize = [5 5];       % 홀수×홀수 크기
Z_smooth = imgaussfilt(Z_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정


% ── 여기까지 추가 ──

% ── 이후 원래대로 surf 호출하되, 그리드와 데이터 변수를 바꿔줌 ──
figure;
hSurf = surf(WYf, WXf, Z_smooth, Err_fine, ...
             'EdgeColor','none','FaceColor','interp');
colormap(jet);  colorbar; caxis([0 5]);
xlabel('Wind Y');  ylabel('Wind X');  zlabel('Smoothed FCM');
title(sprintf('3D XYZ error vs min avg FCM saturated (Color : orginal) (Smooth : FCM) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
shading interp;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3); 

% ── 원본 FCM 점 찍고 싶으면 (선택) ──
hold on;
scatter3(WindY(:), WindX(:), Z_surf(:), 7, 'k', 'filled');
hold on;
scatter3(WYf(:), WXf(:), Z_fine(:), 7, 'm+');
hold on;
scatter3(WYf(:), WXf(:), Z_smooth(:), 7, 'cx');



%% 3D plot: 곡면 높이 = min avg FCM saturated, 곡면 색상 = xyz error heatmap orginal , 스무딩 FCM xyz_error, 연속적인 형상
% ── 기존 그리드 정의 ──
[rowVec, colVec] = deal(wind_lower:increment:wind_upper);
[WindY, WindX]   = meshgrid(colVec, rowVec);

Z_surf = heatmap_mat_format_min_avg_array_FCM_saturated_original;        % FCM (0~1)
C_surf = heatmap_mat_format_max_xyz_error_original;   % XYZ error

% ── 여기부터 추가: 고해상도 격자 + 보간 + 스무딩 ──
fine = 0.5;                                           % 세분화 간격
[rowF, colF] = deal(wind_lower:fine:wind_upper);
[WYf, WXf]   = meshgrid(colF, rowF);

% 보간 함수 정의
F_fcm = scatteredInterpolant(WindY(:), -WindX(:), Z_surf(:), 'natural', 'linear');
F_err = scatteredInterpolant(WindY(:), -WindX(:), C_surf(:), 'natural', 'linear');

% 고해상도 데이터
Z_fine   = F_fcm(WYf, -WXf);
Err_fine = F_err(WYf, -WXf);

% 2차원 데이터 가우스 필터링
sigma      = 1;           % 표준편차
filterSize = [5 5];       % 홀수×홀수 크기
Z_smooth = imgaussfilt(Z_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정
Err_smooth = imgaussfilt(Err_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정


% ── 여기까지 추가 ──

% ── 이후 원래대로 surf 호출하되, 그리드와 데이터 변수를 바꿔줌 ──
figure;
hSurf = surf(WYf, WXf, Z_smooth, Err_smooth, ...
             'EdgeColor','none','FaceColor','interp');
colormap(jet);  colorbar; caxis([0 5]);
xlabel('Wind Y');  ylabel('Wind X');  zlabel('Smoothed FCM');
title(sprintf('3D XYZ error vs min avg FCM saturated (Color : orginal) (Smooth : FCM, XYZ error) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
shading interp;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3); 

% ── 원본 FCM 점 찍고 싶으면 (선택) ──
hold on;
scatter3(WindY(:), WindX(:), Z_surf(:), 7, 'k', 'filled');
hold on;
scatter3(WYf(:), WXf(:), Z_fine(:), 7, 'm+');
hold on;
scatter3(WYf(:), WXf(:), Z_smooth(:), 7, 'cx');


%% 3D plot: 곡면 높이 = min avg FCM saturated, 곡면 색상 = max avg xyz error heatmap orginal , 연속적인 형상
[rowVec, colVec] = deal(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper);
[WindY, WindX]  = meshgrid(colVec, rowVec);

% Z 값: FCM (min_avg_array_FCM_saturated)
Z_surf = heatmap_mat_format_min_avg_array_FCM_saturated_original;

% CData: max avg xyz error heatmap (원본)
C_surf = heatmap_mat_format_max_avg_xyz_error_original;

figure;
hSurf = surf( WindY, WindX, Z_surf, ...      % X, Y, 높이(Z)
              C_surf, ...                     % 색상 매핑할 값
              'EdgeColor','none', ...         % 매끄러운 면
              'FaceColor','interp' );         % 색상 보간
colormap(jet);
caxis([0 5]);   % 에러 범위에 맞춰 컬러바 스케일
colorbar;
hold on;

% FCM 점도 곡면 위에 표시 (선택)
scatter3( WindY(:), WindX(:), Z_surf(:), 11, 'k', 'filled' );

xlabel('Wind Y');  ylabel('Wind X');  zlabel('FCM Value');
title(sprintf('3D max avg XYZ error vs min avg FCM saturated (Color : orginal) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
axis tight;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3);



%% 3D plot: 곡면 높이 = min avg FCM saturated, 곡면 색상 = max avg xyz error heatmap orginal , 스무딩 FCM , 연속적인 형상
% ── 기존 그리드 정의 ──
[rowVec, colVec] = deal(wind_lower:increment:wind_upper);
[WindY, WindX]   = meshgrid(colVec, rowVec);

Z_surf = heatmap_mat_format_min_avg_array_FCM_saturated_original;        % FCM (0~1)
C_surf = heatmap_mat_format_max_avg_xyz_error_original;   % max avg XYZ error

% ── 여기부터 추가: 고해상도 격자 + 보간 + 스무딩 ──
fine = 0.5;                                           % 세분화 간격
[rowF, colF] = deal(wind_lower:fine:wind_upper);
[WYf, WXf]   = meshgrid(colF, rowF);

% 보간 함수 정의
F_fcm = scatteredInterpolant(WindY(:), -WindX(:), Z_surf(:), 'natural', 'linear');
F_err = scatteredInterpolant(WindY(:), -WindX(:), C_surf(:), 'natural', 'linear');

% 고해상도 데이터
Z_fine   = F_fcm(WYf, -WXf);
Err_fine = F_err(WYf, -WXf);

% 2차원 데이터 가우스 필터링
sigma      = 1;           % 표준편차
filterSize = [5 5];       % 홀수×홀수 크기
Z_smooth = imgaussfilt(Z_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정


% ── 여기까지 추가 ──

% ── 이후 원래대로 surf 호출하되, 그리드와 데이터 변수를 바꿔줌 ──
figure;
hSurf = surf(WYf, WXf, Z_smooth, Err_fine, ...
             'EdgeColor','none','FaceColor','interp');
colormap(jet);  colorbar; caxis([0 5]);
xlabel('Wind Y');  ylabel('Wind X');  zlabel('Smoothed FCM');
title(sprintf('3D max avg XYZ error vs min avg FCM saturated (Color : orginal) (Smooth : FCM) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
shading interp;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3); 

% ── 원본 FCM 점 찍고 싶으면 (선택) ──
hold on;
scatter3(WindY(:), WindX(:), Z_surf(:), 7, 'k', 'filled');
hold on;
scatter3(WYf(:), WXf(:), Z_fine(:), 7, 'm+');
hold on;
scatter3(WYf(:), WXf(:), Z_smooth(:), 7, 'cx');



%% 3D plot: 곡면 높이 = min avg FCM saturated, 곡면 색상 = max avg xyz error heatmap orginal , 스무딩 FCM xyz_error, 연속적인 형상
% ── 기존 그리드 정의 ──
[rowVec, colVec] = deal(wind_lower:increment:wind_upper);
[WindY, WindX]   = meshgrid(colVec, rowVec);

Z_surf = heatmap_mat_format_min_avg_array_FCM_saturated_original;        % FCM (0~1)
C_surf = heatmap_mat_format_max_avg_xyz_error_original;   % max avg XYZ error

% ── 여기부터 추가: 고해상도 격자 + 보간 + 스무딩 ──
fine = 0.5;                                           % 세분화 간격
[rowF, colF] = deal(wind_lower:fine:wind_upper);
[WYf, WXf]   = meshgrid(colF, rowF);

% 보간 함수 정의
F_fcm = scatteredInterpolant(WindY(:), -WindX(:), Z_surf(:), 'natural', 'linear');
F_err = scatteredInterpolant(WindY(:), -WindX(:), C_surf(:), 'natural', 'linear');

% 고해상도 데이터
Z_fine   = F_fcm(WYf, -WXf);
Err_fine = F_err(WYf, -WXf);

% 2차원 데이터 가우스 필터링
sigma      = 1;           % 표준편차
filterSize = [5 5];       % 홀수×홀수 크기
Z_smooth = imgaussfilt(Z_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정
Err_smooth = imgaussfilt(Err_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정


% ── 여기까지 추가 ──

% ── 이후 원래대로 surf 호출하되, 그리드와 데이터 변수를 바꿔줌 ──
figure;
hSurf = surf(WYf, WXf, Z_smooth, Err_smooth, ...
             'EdgeColor','none','FaceColor','interp');
colormap(jet);  colorbar; caxis([0 5]);
xlabel('Wind Y');  ylabel('Wind X');  zlabel('Smoothed FCM');
title(sprintf('3D max avg XYZ error vs min avg FCM saturated (Color : orginal) (Smooth : FCM, max avg XYZ error) (Fault %d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, ...
      ftc_status_str, wind_type_str));
shading interp;
set(gca, ...
    'YDir', 'reverse', ...                % Y축 증가 방향을 아래로
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3); 

% ── 원본 FCM 점 찍고 싶으면 (선택) ──
hold on;
scatter3(WindY(:), WindX(:), Z_surf(:), 7, 'k', 'filled');
hold on;
scatter3(WYf(:), WXf(:), Z_fine(:), 7, 'm+');
hold on;
scatter3(WYf(:), WXf(:), Z_smooth(:), 7, 'cx');

toc;



%% Z_surf >= ** 인 C_surf의 2D 시각화

% --- 1단계: 소스 데이터와 임계값 정의 ---
% 3D 플롯 중 하나를 예로 들어 Z_surf와 C_surf를 정의합니다.
Z_surf = heatmap_mat_format_min_avg_array_FCM_saturated_original;
C_surf = heatmap_mat_format_max_avg_xyz_error_original;
fcm_threshold = 0.5;

% --- 2단계: Z_surf 조건에 기반한 논리 마스크 생성 ---
logical_mask = Z_surf >= fcm_threshold;

% --- 3단계: 마스크를 사용해 C_surf 값을 담을 새 행렬 생성 ---
% 새 행렬을 NaN으로 초기화합니다. NaN 값은 히트맵에서 무시되거나 다르게 색칠됩니다.
filtered_C_surf = NaN(size(C_surf)); 
% 마스크가 true인 위치의 C_surf 요소만 새 행렬로 복사합니다.
filtered_C_surf(logical_mask) = C_surf(logical_mask);

% --- 4단계: 필터링된 데이터로 2D 히트맵 생성 ---
figure; % 새 Figure 창 생성
h_filtered = heatmap(wind_lower:increment:wind_upper, wind_lower:increment:wind_upper, filtered_C_surf);

% --- 히트맵 모양 사용자 정의 ---
title_str = sprintf('Max Avg XYZ Error when Min Avg Saturated FCM >= %.2f', fcm_threshold);
h_filtered.Title = title_str;
h_filtered.XLabel = 'Wind Y';
h_filtered.YLabel = 'Wind X';
h_filtered.Colormap = jet;
h_filtered.ColorLimits = [0 5]; % 일관성을 위해 기존 오차 플롯과 동일한 색상 범위 사용
h_filtered.CellLabelColor = 'none';
h_filtered.GridVisible = 'off';

% 필터링되어 제외된 (NaN) 데이터의 표시 방법 처리
h_filtered.MissingDataColor = [0.8 0.8 0.8]; % 임계값을 만족하지 않는 셀은 밝은 회색으로 설정
h_filtered.MissingDataLabel = sprintf('FCM < %.2f', fcm_threshold); % 범례에 표시될 레이블

%% 3D Trajectory Animation (Time Progress) 설명: 시간순으로 그려가며 trajectory 애니메이션

% heatmap_mat_format_postion_xyz_data = heatmap_mat_format_postion_xyz{a,b};
% t = heatmap_mat_format_postion_xyz_data(:,1);
% x = heatmap_mat_format_postion_xyz_data(:,2);
% y = heatmap_mat_format_postion_xyz_data(:,3);
% z = heatmap_mat_format_postion_xyz_data(:,4);
% 
% 
% cmap = jet(length(t));  % 시간에 따른 색
% figure;
% for i = 1:length(t)
%     plot3(x(1:i), y(1:i), z(1:i), 'b-')
%     hold on
%     plot3(x(i), y(i), z(i), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r')
%     hold off
%     xlabel('X'); ylabel('Y'); zlabel('Z'); grid on
%     title(sprintf('Time = %.2f sec', t(i)))
%     axis equal
%     pause(0.01)
% end

%% 3D Trajectory with Time-Colored Path 설명: 전체 경로를 한 번에 그리고 시간은 색으로 표현
% heatmap_mat_format_postion_xyz_data = heatmap_mat_format_postion_xyz{a,b};
% t = heatmap_mat_format_postion_xyz_data(:,1);
% x = heatmap_mat_format_postion_xyz_data(:,2);
% y = heatmap_mat_format_postion_xyz_data(:,3);
% z = heatmap_mat_format_postion_xyz_data(:,4);
% 
% 
% % 궤적을 시간에 따라 색상 입혀서 그리기
% figure;
% hold on;
% 
% % surface를 이용한 선 + 색 표현
% % NaN을 통해 연결 끊음 (줄 단위로 선 만듦)
% for i = 1:length(t)-1
%     xx = [x(i), x(i+1)];
%     yy = [y(i), y(i+1)];
%     zz = [z(i), z(i+1)];
%     tt = [t(i), t(i+1)];
% 
%     % 하나의 선분을 surface로 그려서 색상 입힘
%     surface([xx; xx], [yy; yy], [zz; zz], [tt; tt], ...
%         'EdgeColor', 'interp', 'FaceColor', 'none', 'LineWidth', 2);
% end
% 
% colormap(jet); colorbar;
% xlabel('X'); ylabel('Y'); zlabel('Z');
% title('3D Trajectory colored by Time');
% grid on;
% view(3);