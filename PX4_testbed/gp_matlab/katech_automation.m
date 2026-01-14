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
    run('octo_model/octocopter_model_for_agressive.m');
catch ME
    error('octo_model/octocopter_model_for_agressive.m 스크립트 실행에 실패했습니다. (%s)', ME.message);
end

% % Execute the bash script using the system command
% set_automation_env = '/home/hmcl/PX4_testbed/automation_codes/set_automation_env.sh'; % 드론이 하버링 하도록 SILS 환경을 자동화
% close_terminal = '/home/hmcl/PX4_testbed/automation_codes/close_terminal.sh'; % 자동화에서 사용된 모든 터미널을 닫음
% open_NoFTC_MotorFault_terminal = '/home/hmcl/PX4_testbed/automation_codes/open_NoFTC_MotorFault_terminal.sh'; % FTC_toggle 토글에 따라 고장 주입
% open_FTC_MotorFault_terminal = '/home/hmcl/PX4_testbed/automation_codes/open_FTC_MotorFault_terminal.sh'; % FTC_toggle 토글에 따라 고장 주입
% open_roscore_for_simulink = '/home/hmcl/PX4_testbed/automation_codes/open_roscore_for_simulink.sh'; % ROSCORE 실행
% addpath('/home/hmcl/PX4_testbed/gp_matlab/octo_model');

%시뮬레이션 돌린 날짜
currentDateTime = datetime('now');

% 날짜를 'yyyymmdd' 형식의 문자열로 변환
formattedDate = datestr(currentDateTime, 'yyyymmdd');

diary('diary.txt');   % 원하는 파일명 지정(확장자 포함)
diary on;             % 기록 시작

%% setup Parameter
 
% start_date automation돌린 날짜 하지만 원하는 날짜로 바꿔도 된다.
% ex) start_date = 20241225;  원하는 날짜
% ex) start_date = str2double(formattedDate);  현재를 자동입력 날짜
start_date = str2double(formattedDate);

% 이 변수는 폴더이름과 rostopic에 사용된다.
% ※ 토글별 의미 ※
% 1) Off FTC (FTC_toggle==0): open_NoFTC_MotorFault_terminal 자동화 코드를 사용하여
% FTC 없이 테스트 진행
% 2) On FTC (FTC_toggle==1): open_FTC_MotorFault_terminal 자동화 코드를 사용하여
% FTC 기반 테스트 진행
FTC_toggle = 0; % 1: OnFTC / 0 : OffFTC
motor_failure_number = 3;
motor_failure_number1 = 6;
motor_failure_number2 = 7;
motor_failure_number3 = 8;

% FCM window 사이즈 설정
% data_collection/Subsystem2/MATLAB Function3 에서 활용
window_size_ = Simulink.Parameter(100); % FCM의 구간 평균을 위한 윈도우 설정
omega_max = Simulink.Parameter(425.47); % 로터의 최대 회전 속도 rad/s, maxRotVelocity in sdf

% 바람 유형 토글 (1: 거스트/상수/층류 바람, 2: 정규분포/난류 바람)
wind_type_toggle = 2;


% [시뮬레이션 범위 설정 (바람 세기 루프 정의)]
% -----------------------------------------------------------------
% wind_lower부터 wind_upper까지 increment 간격으로 바람 세기를 바꿔가며 테스트.
% (예: -20:1:20 이면 X축 41회, Y축 41회 = 총 1681회 시뮬레이션)
%
% ※ 토글별 의미 ※
% 1) 층류 (wind_type_toggle==1): 이 범위의 값이 '상수' 바람 세기로 직접 사용됨.
% 2) 난류 (wind_type_toggle==2): 이 범위의 값이 난류의 '평균(Mean)' 값으로 사용됨.
% 정규 분포 일때 
% -----------------------------------------------------------------
wind_lower = -20; % 바람 루프 최소값 (m/s)
wind_upper = 20; % 바람 루프 최대값 (m/s)
increment = 1; % 바람 루프 증가 간격 (e.g., 0.1, 0.5, 1, etc.)

% [난류 전용 파라미터 (wind_type_toggle == 2 일 때만 사용됨), 층류일때는 default 0으로 설정]
% 정규분포일때 variance max 설정
wind_normal_distribution_Max = 5; % 난류의 'Max 오프셋'. (실제 Max = Mean + 5)
wind_normal_distribution_Variance = 5; % 난류의 '분산' 값. (값이 클수록 바람이 거칠어짐)

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
% 파일/제목에 사용할 문자열 (FTC 적용 여부)
if FTC_toggle
    ftc_status_str = 'with FTC';
else
    ftc_status_str = 'without FTC';
end

% 정규분포 바람에서 사용할 기본 Max, variance 범위 (없으면 0)
% wind_type_toggle 값에 따라 파일/제목용 문자열과 변수값 설정
if wind_type_toggle == 2
    % 2: 난류 모드 (Normal)
    default_Normal_Max = wind_normal_distribution_Max;
    default_Normal_Var = wind_normal_distribution_Variance;
    wind_type_str = sprintf('Normal Max%d Var%d', ...
        round(default_Normal_Max), ...
        round(default_Normal_Var));
else
    % 1: 층류 모드 (costant)
    default_Normal_Max = 0;
    default_Normal_Var = 0;
    wind_type_str = 'costant';
end

% 각 모터고장 값을 txt 파일에 저장
% (외부 스크립트나 Simulink에서 이 파일들을 읽어 고장 시나리오 적용)
fid = fopen('motor_failure_number.txt', 'w');
fprintf(fid, '%d', motor_failure_number);
fclose(fid);

fid = fopen('motor_failure_number1.txt', 'w');
fprintf(fid, '%d', motor_failure_number1);
fclose(fid);

fid = fopen('motor_failure_number2.txt', 'w');
fprintf(fid, '%d', motor_failure_number2);
fclose(fid);

fid = fopen('motor_failure_number3.txt', 'w');
fprintf(fid, '%d', motor_failure_number3);
fclose(fid);

% 시뮬레이션 루프용 변수 초기화
input_wind_x = 0; % don't touch
input_wind_y = 0; % don't touch

% 바람 세기(-20 ~ 20)에 따른 그리드 크기 계산 (예: 41x41)
num_x = ceil((wind_upper - wind_lower) / increment) + 1; % X축 격자점 개수
num_y = ceil((wind_upper - wind_lower) / increment) + 1; % Y축 격자점 개수

% 41x41 셀 배열 생성. 각 셀에는 [wind_x, wind_y] 값이 저장됨.
cell_format = cell(num_x, num_y);

% 중첩 루프: 모든 X, Y 바람 조합에 대해 반복
for wind_x = wind_lower:increment:wind_upper
    
    % X 인덱스 계산 (바깥쪽 루프에서 한 번만 계산)
    x = round((wind_x - wind_lower) / increment) + 1;
    
    for wind_y = wind_lower:increment:wind_upper
        
        % Y 인덱스 계산
        y = round((wind_y - wind_lower) / increment) + 1;
        
        % [wind_x, wind_y] 벡터를 생성하여 해당 셀에 저장
        mat = [wind_x, wind_y];
        cell_format{x, y} = mat;
        
        % 진행 상황 표시 (x, y 인덱스 기준)
        fprintf('mat row = %.1f , column = %.1f\n', x, y); 
    end
end
disp('Completed filling cell_format');



% ======================================================================
% %% 결과 저장을 위한 행렬 사전 할당 (Pre-allocation for Results)
% ======================================================================
%
% 목적: 메인 시뮬레이션 루프(예: 41x41)를 실행하기 전에
%       결과를 담을 모든 행렬/셀 배열의 공간을 미리 확보합니다.
%       (이유: 루프 내에서 행렬 크기를 동적으로 변경하는 것을 피해 성능 향상)
%
% --- 명명 규칙 ---
% [변수명]_original : Simulink에서 출력된 원본(raw) 데이터를 저장합니다.
% [변수명] (기본)   : 히트맵 시각화를 위해 임계값을 적용(clamping)한 데이터를 저장합니다.
%                   (예: 루프 내에서 max_roll > 50 이면 100으로 저장하는 로직)
% cell(num_x, num_y) : 'postion_xyz' 처럼 단순 숫자(scalar)가 아닌
%                   시계열 배열(array) 데이터를 저장할 때 사용합니다.
%
% ★ 새로운 데이터 지표(Metric)를 추가하려면 ★
% 1. 이 섹션에 `heatmap_mat_format_[새지표] = zeros(num_x, num_y);` 와
%    `heatmap_mat_format_[새지표]_original = zeros(num_x, num_y);` 를 추가합니다.
% 2. 메인 루프 내부의 'evalin' 섹션에서 Simulink로부터 새 지표 값을 읽어와
%    위에서 만든 행렬에 저장하는 로직을 추가하면 됩니다.
%
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
% ======================================================================



open_system("data_collection"); % 'data_collection.slx' Simulink 모델 열기
disp('Opening the simulink');
pause(10); % Simulink 모델이 완전히 로드될 때까지 10초간 대기

% ---------------------------------------------------------------------
% ★ 시뮬링크 블록 파라미터 초기화 (오류 방지) ★
% ---------------------------------------------------------------------
% 스크립트 실행 전, 모델 내부에 남아있을 수 있는 '이전 값'을 0으로 리셋합니다.
% (이유: 비정상 종료되었거나 수동으로 값을 변경했을 경우,
%  해당 값이 첫 번째 시뮬레이션에 영향을 미치는 것을 방지하기 위함)
if wind_type_toggle == 2
    % [난류 모드] (Subsystem1)에서 사용될 파라미터 블록들을 0으로 초기화
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
    % [거스트/층류 모드] (Subsystem)에서 사용될 파라미터 블록들을 0으로 초기화
    set_param('data_collection/Switch Case Action Subsystem/wind_x2','Value','0');
    set_param('data_collection/Switch Case Action Subsystem/wind_y2','Value','0');
end


% ==========================================================
% %% 메인 시뮬레이션 루프 (Main Simulation Loop)
% ==========================================================
% 모든 바람 조합(예: 41x41)에 대해 개별 시뮬레이션 실행
% (각 루프는 하나의 독립된 시뮬레이션 환경을 구성하고 실행한 뒤 종료됨)
total_simulations = num_x * num_y;
for b = 1:num_x
    for a = 1:num_y

        % --- 현재 시뮬레이션 진행 상황 표시 ---
        current_sim_number = (b-1) * num_y + a;
        fprintf('\n\n====================================================\n');
        fprintf('--- Starting Simulation %d / %d ---\n', current_sim_number, total_simulations);
        fprintf('====================================================\n');

        
        % --- 1. ROS 마스터(roscore) 실행 ---
        % (매 루프마다 roscore를 재시작하여 이전 시뮬레이션의 영향을 초기화)
        system(open_roscore_for_simulink); % 외부 쉘 스크립트를 통해 roscore 실행
        fprintf('-----ROSCORE-------- \n');
        pause(3); % roscore가 완전히 실행될 때까지 대기
        
        % --- 2. Simulink 모델 비동기 실행 ---
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


        % --- 3. PX4/Gazebo 시뮬레이션 환경 설정 ---
        % PX4 SITL 및 Gazebo 환경을 로드하는 쉘 스크립트 실행
        system(set_automation_env);
        fprintf('set_automation_env.sh is turning on. Please wait. \n');
        pause(25); % Gazebo 및 PX4가 완전히 로드되고 안정화될 때까지 대기
        
        % --- 4. 모터 고장 스크립트 실행 (FTC 토글에 따라 분기) ---
        if FTC_toggle
            % FTC가 활성화된 상태의 모터 고장 스크립트 실행
            system(open_FTC_MotorFault_terminal);
            fprintf('motor_failure!!!!!!!!!!! with FTC \n');
        else
            % FTC가 비활성화된 상태의 모터 고장 스크립트 실행
            system(open_NoFTC_MotorFault_terminal);
            fprintf('motor_failure!!!!!!!!!!! with NoFTC \n');
        end
        pause(15); % 고장 스크립트가 적용되고 시뮬레이션이 안정화될 시간 10초 대기

        % --- 5. 현재 루프의 바람 값 가져오기 ---
        % 루프 인덱스 (a, b)를 사용하여 
        % 미리 생성한 cell_format에서 [X, Y] 바람 값을 가져옴
        value = cell_format{a,b};
        input_wind_x = value(1); % 이 값을 Simulink 파라미터로 전달
        input_wind_y = value(2); % 이 값을 Simulink 파라미터로 전달

        % ====== 토글에 따라 바람 파라미터 설정 ======
        % 현재 루프의 바람 값을 'wind_type_toggle' 값에 따라 Simulink 모델의 적절한 블록에 주입
        if wind_type_toggle == 2
            % [Case 2: 난류/정규분포 바람]
            % input 값(예: -15)을 '방향'(예: -1)과 '평균'(예: 15)으로 분리하여 설정합니다.

            % sign 함수로 바람의 방향 (+1, -1, 0)을 결정
            wind_normal_distribution_Direction_X = sign(input_wind_x);
            wind_normal_distribution_Direction_Y = sign(input_wind_y);
            
            % abs 함수로 바람의 '평균(Mean)' 세기를 결정
            % '최대(Max)' 값은 (평균 + 스크립트 상단에서 정의한 Max 오프셋)
            % '분산(Variance)' 값은 스크립트 상단에서 정의한 값 사용
            wind_normal_distribution_X_Mean = abs(input_wind_x);
            wind_normal_distribution_X_Max = wind_normal_distribution_X_Mean + default_Normal_Max;
            wind_normal_distribution_X_Variance = default_Normal_Var;

            wind_normal_distribution_Y_Mean = abs(input_wind_y);
            wind_normal_distribution_Y_Max = wind_normal_distribution_Y_Mean + default_Normal_Max;
            wind_normal_distribution_Y_Variance = default_Normal_Var;

            % --- Simulink 파라미터 주입 (난류용 Subsystem1) ---
            % 'wind_toggle' 값을 2로 설정하여 모델 내 Switch Case가 난류 블록을 선택하도록 함
            set_param('data_collection/wind_toggle','Value','wind_type_toggle');

            % 계산된 난류 파라미터들을 모델의 해당 블록('Value')에 실시간으로 업데이트
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
            % [Case 1: 거스트/상수 바람]
            % 현재 루프의 바람 값을 '방향'이나 '평균' 구분 없이 '상수' 바람 값으로 모델에 직접 주입합니다.
            
            % --- Simulink 파라미터 주입 (거스트용 Subsystem) ---
            % 'wind_toggle' 값을 1로 설정하여 모델 내 Switch Case가 거스트 블록을 선택하도록 함
            set_param('data_collection/wind_toggle','Value','wind_type_toggle');

            % input 값을 모델의 해당 블록('Value')에 실시간으로 업데이트
            set_param('data_collection/Switch Case Action Subsystem/wind_x2','Value','input_wind_x');
            set_param('data_collection/Switch Case Action Subsystem/wind_y2','Value','input_wind_y');
        end
        % ====== 토글에 따른 파라미터 설정 끝 ======

        % --- 6. 시뮬레이션 실행 대기 및 결과 수집 ---
        % 현재 시뮬레이션 모드와 바람 값을 콘솔에 출력
        fprintf('Mode: %s, wind (X=%.1f, Y=%.1f)\n', wind_type_str, input_wind_x, input_wind_y);

        % Simulink 모델이 일정시간동안 데이터를 수집합니다.
        pause(30);




        % --- 7. 'base' 워크스페이스에서 결과 지표 수확 ---
        %
        % 'evalin'을 사용하여 현재 실행 중인 Simulink가 'base' 워크스페이스에
        % 생성한 변수(결과 지표)가 '존재하는지' 확인하고 값을 가져옵니다.
        %
        % [저장 로직]
        % 1. ..._original(a, b): Simulink에서 받은 원본(raw) 값을 그대로 저장합니다.
        % 2. ...(a, b)          : 히트맵 시각화를 위해 임계값(Threshold)을 적용합니다. (값이 너무 크거나(실패) 변수가 없으면 100으로 통일)

        % --- max_roll (최대 롤 각도) 수집 ---
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

        % --- max_xy_error (최대 수평 위치 오차) 수집 ---
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

        % --- endstep_xy_error (시뮬레이션 종료 시점 수평 오차) 수집 ---
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

        % --- endstep_x_error (종료 시점 X 오차) 수집 ---
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

        % --- endstep_y_error (종료 시점 Y 오차) 수집 ---
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

        % --- endstep_z_error (종료 시점 Z 오차) 수집 ---
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

        % --- max_x_error (최대 X 오차) 수집 ---
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

        % --- max_y_error (최대 Y 오차) 수집 ---
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

        % --- max_z_error (최대 Z 오차) 수집 ---
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

        % --- min_FCMW (FCM 윈도우 최소값) 수집 ---
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

        % --- min_avg_array_FCM (FCM 이동평균의 최소값) 수집 ---
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

        % --- max_xyz_error (최대 3D 위치 오차) 수집 ---
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

        % --- endstep_xyz_error (종료 시점 3D 위치 오차) 수집 ---
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
        
        % --- avg_FCM_in_range (특정 구간 FCM 평균) 수집 ---
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

        % --- avg_FCM_saturated_in_range (특정 구간 포화된 FCM 평균) 수집 ---
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

        % --- min_avg_array_FCM_saturated (포화된 FCM 이동평균의 최소값) 수집 ---
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

        % --- max_avg_xyz_error (3D 위치 오차의 이동평균 최대값) 수집 ---
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
        

        % --- 8. 시뮬레이션 환경 리셋 (다음 루프 준비) ---
        % Simulink 모델 내부의 바람 파라미터를 '0'으로 다시 초기화
        if wind_type_toggle == 2
            % [난류 모드] 파라미터 리셋
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
            % [층류 모드] 파라미터 리셋
            set_param('data_collection/Switch Case Action Subsystem/wind_x2','Value','0');
            set_param('data_collection/Switch Case Action Subsystem/wind_y2','Value','0');
        end

        % 현재 스텝(바람 조합)의 시뮬레이션이 완료되었음을 콘솔에 알림
        fprintf('This step test is finished. \n input_wind_x = %.1f , input_wind_y = %.1f measured wind \n', input_wind_x, input_wind_y);

        % --- 9. 외부 프로세스 및 Simulink 종료 ---
        % 'close_terminal' 쉘 스크립트를 실행하여
        % roscore, PX4, Gazebo 등 이번 루프에서 열었던 모든 터미널을 강제 종료
        system(close_terminal);

        % 'inf'로 실행 중이던 Simulink 모델('data_collection')에 'stop' 명령을 전송
        set_param(modelName, 'SimulationCommand', 'stop');
        fprintf('---------Terminals and simulink closed---------------- \n\n');

        % --- 10. 시계열 데이터(Array) 저장 ---
        % 'To Workspace' 블록을 통해 'out' 구조체에 저장된 시계열 데이터를
        % (a, b) 인덱스에 해당하는 셀(cell)에 저장
        % (참고: 'out' 변수는 Simulink 모델의 'Scope' 블록에 의해 생성됨)
        heatmap_mat_format_postion_xyz{a,b} = out.ScopeData_Postion;
        heatmap_mat_format_total_FCM{a,b} = out.ScopeData_FCM;
        pause(2); % 다음 루프 시작 전, 모든 프로세스가 완전히 종료될 수 있도록 2초 대기





    end
end

toc;
%% Save data after algorithm ends

% 폴더 이름 생성
save_folder = sprintf('%dby%d_increment_%d_fault_%d_%d_%d_%d_date_%d_%s_%s_window_%d', wind_upper * 2, wind_upper * 2, increment, motor_failure_number, motor_failure_number1,motor_failure_number2, motor_failure_number3, start_date, ftc_status_str, wind_type_str, window_size_.Value);

% 폴더가 존재하지 않으면 생성
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

% 파일 이름 생성
filename = sprintf('%s/%dby%d_increment_%d_fault_%d_%d_%d_%d_date_%d_%s_%s_window_%d.mat', save_folder, wind_upper * 2, wind_upper * 2, increment, motor_failure_number, motor_failure_number1, motor_failure_number2, motor_failure_number3, start_date, ftc_status_str, wind_type_str,window_size_.Value);

% 로그 파일 생성
diary off

% 경로(folder), 파일명(name), 확장자(ext) 분리
[folder, name, ext] = fileparts(filename);

% txt 확장자로 변경하여 logname 생성
logname = [name, '.txt'];

destPath = fullfile(folder,logname);
status = movefile('diary.txt', destPath);

if status
    fprintf('Log move and renaming successful.\n');
else
    fprintf('Log move and renaming failed.\n');
end

% 히트맵 제목
titlename  = sprintf('xy maximum error for No. %d, %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, motor_failure_number3, ftc_status_str, wind_type_str);

titlename1 = sprintf('roll maximum error for No. %d, %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, motor_failure_number3, ftc_status_str, wind_type_str);

titlename2 = sprintf('xy max error at Last Time Step for No. %d, %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, motor_failure_number3, ftc_status_str, wind_type_str);

titlename3 = sprintf('Min average FCM for No. %d, %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, motor_failure_number3, ftc_status_str, wind_type_str);

titlename4  = sprintf('xyz maximum error for No. %d, %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, motor_failure_number3, ftc_status_str, wind_type_str);

titlename5  = sprintf('Avg FCM in range for No. %d, %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, motor_failure_number3, ftc_status_str, wind_type_str);

titlename6  = sprintf('Avg FCM Saturated in range for No. %d, %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, motor_failure_number3, ftc_status_str, wind_type_str);

titlename7  = sprintf('Min average FCM Saturated for No. %d, %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, motor_failure_number3, ftc_status_str, wind_type_str);

titlename8  = sprintf('Max average xyz error for No. %d, %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, motor_failure_number3, ftc_status_str, wind_type_str);

titlename9  = sprintf('Smoothing Min average FCM Saturated for No. %d, %d, %d, %d fault (%s) (%s)', motor_failure_number, motor_failure_number1, motor_failure_number2, motor_failure_number3, ftc_status_str, wind_type_str);


% 변수들을 저장 (MAT 파일 형식 7.3 지정)
save(filename, '-v7.3');


%% Heatmap with value display

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
sigma      = 2;           % 표준편차
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
title(sprintf('3D max avg XYZ error vs min avg FCM saturated (Color : orginal) (Smooth : FCM, max avg XYZ error) (Fault %d,%d,%d,%d), (%s), (%s)', ...
      motor_failure_number, motor_failure_number1, motor_failure_number2, motor_failure_number3, ...
      ftc_status_str, wind_type_str));
shading interp;
set(gca, ...
    'YDir', 'normal', ...                % Y축 증가 방향을 아래로
    'XDir', 'reverse', ...
    'YLim', [wind_lower, wind_upper]);    % 한 번 더 범위 지정
view(3); 

% ── 원본 FCM 점 찍고 싶으면 (선택) ──
hold on;



%% 2D plot: min avg FCM saturated

figure();
rr = heatmap(wind_upper:-increment:wind_lower, wind_upper:-increment:wind_lower,heatmap_mat_format_min_avg_array_FCM_saturated_original);
rr.Title = strcat(titlename7, ' original');
rr.XLabel = 'Wind Y';
rr.YLabel = 'Wind X';
rr.Colormap = flipud(jet);
rr.ColorLimits = [0 1];
rr.CellLabelColor = 'none';
rr.GridVisible = 'off';


%% 2D 플롯: Min Avg Saturated FCM (스무딩 적용)
figure();
% --- 데이터 및 그리드 정의 ---
Z_surf = heatmap_mat_format_min_avg_array_FCM_saturated_original; % 사용할 데이터
[rowVec, colVec] = deal(wind_lower:increment:wind_upper);
[WindY, WindX]   = meshgrid(colVec, rowVec);

% --- 고해상도 격자 + 보간 + 스무딩 ---
fine = 0.5;
[rowF, colF] = deal(wind_lower:fine:wind_upper);
[WYf, WXf]   = meshgrid(colF, rowF);

F_fcm = scatteredInterpolant(WindY(:), -WindX(:), Z_surf(:), 'natural', 'linear');
Z_fine   = F_fcm(WYf, -WXf);

sigma      = 2;
filterSize = [5 5];
Z_smooth = imgaussfilt(Z_fine, sigma,"FilterSize", filterSize);

% --- 스무딩된 데이터로 히트맵 생성 ---
rr = heatmap(-colF, -rowF, Z_smooth);
rr.Title = strcat(titlename7, ' (Smoothed)');
rr.XLabel = 'Wind Y';
rr.YLabel = 'Wind X';
rr.Colormap = flipud(jet);
rr.ColorLimits = [0 1];
rr.CellLabelColor = 'none';
rr.GridVisible = 'off';

%% 2D plot: max avg xyz error
figure();
ss = heatmap(wind_upper:-increment:wind_lower, wind_upper:-increment:wind_lower,heatmap_mat_format_max_avg_xyz_error_original);
ss.Title = strcat(titlename8, ' original');
ss.XLabel = 'Wind Y';
ss.YLabel = 'Wind X';
ss.Colormap = jet;
ss.ColorLimits = [0 5];
ss.CellLabelColor = 'none';
ss.GridVisible = 'off';

%% 2D 플롯: Max Avg XYZ Error (스무딩 적용)
figure();
% --- 데이터 및 그리드 정의 ---
C_surf = heatmap_mat_format_max_avg_xyz_error_original; % 사용할 데이터
[rowVec, colVec] = deal(wind_lower:increment:wind_upper);
[WindY, WindX]   = meshgrid(colVec, rowVec);

% --- 고해상도 격자 + 보간 + 스무딩 ---
fine = 0.5;
[rowF, colF] = deal(wind_lower:fine:wind_upper);
[WYf, WXf]   = meshgrid(colF, rowF);

F_err = scatteredInterpolant(WindY(:), -WindX(:), C_surf(:), 'natural', 'linear');
Err_fine = F_err(WYf, -WXf);

sigma      = 2;
filterSize = [5 5];
Err_smooth = imgaussfilt(Err_fine, sigma,"FilterSize", filterSize);

% --- 스무딩된 데이터로 히트맵 생성 ---
ss = heatmap(-colF, -rowF, Err_smooth);
ss.Title = strcat(titlename8, ' (Smoothed)');
ss.XLabel = 'Wind Y';
ss.YLabel = 'Wind X';
ss.Colormap = jet;
ss.ColorLimits = [0 5];
ss.CellLabelColor = 'none';
ss.GridVisible = 'off';


%% Z_surf >= ** 인 C_surf의 2D 시각화


% --- 소스 데이터 정의 ---
Z_surf = heatmap_mat_format_min_avg_array_FCM_saturated_original;
C_surf = heatmap_mat_format_max_avg_xyz_error_original;

% --- [수정] 플롯할 임계값들을 별도의 변수로 정의 ---
threshold_range = 0.4 : 0.1 : 0.9;

variable_names = {'FCM_Threshold', 'Valid_Cell_Count', 'Area_Percentage', 'Mean_Error', 'Max_Error', 'Sum_Error'};
results_original = table('Size', [length(threshold_range), length(variable_names)], ...
                         'VariableTypes', repmat({'double'}, 1, length(variable_names)), ...
                         'VariableNames', variable_names);
results_original.FCM_Threshold = threshold_range'; % 임계값 열 미리 채우기



% --- [수정] 정의된 변수를 사용하여 순회 ---
for i = 1:length(threshold_range)
    
    fcm_threshold = threshold_range(i);

    % --- 현재 임계값(fcm_threshold)에 기반한 논리 마스크 생성 ---
    logical_mask = Z_surf >= fcm_threshold;

    % --- 1. 유효 영역 계산 ---
    valid_cells = nnz(logical_mask); % 조건이 참(true)인 셀의 개수 계산
    total_cells = numel(Z_surf);     % 그리드의 전체 셀 개수
    area_percent = (valid_cells / total_cells) * 100;



    % --- 결과를 테이블에 저장 ---
    results_original.Valid_Cell_Count(i) = valid_cells;
    results_original.Area_Percentage(i) = area_percent;

    % --- 2. 오차 통계량 계산 및 저장 ---
    if valid_cells > 0
        valid_errors = C_surf(logical_mask);
        
        % [수정] 동일한 테이블에 통계량 저장
        results_original.Mean_Error(i) = mean(valid_errors);
        results_original.Max_Error(i)  = max(valid_errors);
        results_original.Sum_Error(i)  = sum(valid_errors);
    else
        % [수정] 동일한 테이블에 NaN 또는 0 저장
        results_original.Mean_Error(i) = NaN;
        results_original.Max_Error(i)  = NaN;
        results_original.Sum_Error(i)  = 0;
    end

    
    % --- 마스크를 사용해 C_surf 값을 담을 새 행렬 생성 ---
    filtered_C_surf = NaN(size(C_surf)); 
    filtered_C_surf(logical_mask) = C_surf(logical_mask);
    
    % --- 필터링된 데이터로 2D 히트맵 생성 ---
    figure; % 새 Figure 창을 열어 플롯이 겹치지 않게 함
    
    % 원본 데이터이므로 저해상도 축을 사용
    h_filtered = heatmap(wind_upper:-increment:wind_lower, wind_upper:-increment:wind_lower, filtered_C_surf);
    
    % --- 히트맵 모양 사용자 정의 ---
    title_str = sprintf('Max Avg XYZ Error when Min Avg Saturated FCM >= %.2f (Original Data)', fcm_threshold);
    h_filtered.Title = title_str;
    h_filtered.XLabel = 'Wind Y';
    h_filtered.YLabel = 'Wind X';
    h_filtered.Colormap = jet;
    h_filtered.ColorLimits = [0 5];
    h_filtered.CellLabelColor = 'none';
    h_filtered.GridVisible = 'off';
    
    % --- 필터링되어 제외된 (NaN) 데이터의 표시 방법 처리 ---
    h_filtered.MissingDataColor = [0.8 0.8 0.8];
    h_filtered.MissingDataLabel = sprintf('FCM < %.2f', fcm_threshold);

end % for 반복문 종료

% --- 최종 결과 테이블 출력 ---
disp('Quantitative Comparison of Area and Error Statistics (Original Data):');
disp(results_original); % 하나의 테이블만 출력

% Figure 1: Valid Area Change (Original Data)
figure;

% 1. 플롯할 데이터를 새로운 변수에 복사합니다.
plot_data = results_original.Area_Percentage;

% 2. isnan 함수로 NaN 값의 위치를 찾아서 0으로 바꿉니다.
plot_data(isnan(plot_data)) = 0;

plot(results_original.FCM_Threshold, plot_data, '-o', 'LineWidth', 2, 'Color', 'b');
title('Change in Valid Area by FCM Threshold (Original Data)');
xlabel('Minimum FCM Threshold');
ylabel('Valid Area (%)');
xlim([threshold_range(1), threshold_range(end)]);
grid on;
legend('Original Data');

% Figure 2: Mean Error Change (Original Data)
figure;

% 1. 플롯할 데이터를 새로운 변수에 복사합니다.
plot_data = results_original.Mean_Error;

% 2. isnan 함수로 NaN 값의 위치를 찾아서 0으로 바꿉니다.
plot_data(isnan(plot_data)) = 0;

plot(results_original.FCM_Threshold, plot_data, '-s', 'LineWidth', 2, 'Color', 'r');
title('Mean XYZ Error in Valid Area (Original Data)');
xlabel('Minimum FCM Threshold');
ylabel('Mean Max Avg XYZ Error');
xlim([threshold_range(1), threshold_range(end)]);
grid on;
legend('Original Data');

%% Z_surf >= ** 인 C_surf의 2D 시각화, 스무딩한 데이터를 활용

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
sigma      = 2;           % 표준편차
filterSize = [5 5];       % 홀수×홀수 크기
Z_smooth = imgaussfilt(Z_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정
Err_smooth = imgaussfilt(Err_fine, sigma,"FilterSize", filterSize); % 원본 2D 데이터, σ 지정, 윈도우 크기 지정

% --- [수정] 플롯할 임계값들을 별도의 변수로 정의 ---
threshold_range = 0.4 : 0.1 : 0.9;

variable_names = {'FCM_Threshold', 'Valid_Cell_Count', 'Area_Percentage', 'Mean_Error', 'Max_Error', 'Sum_Error'};
results_smoothed = table('Size', [length(threshold_range), length(variable_names)], ...
                         'VariableTypes', repmat({'double'}, 1, length(variable_names)), ...
                         'VariableNames', variable_names);
results_smoothed.FCM_Threshold = threshold_range';

% --- fcm_threshold 값을 0.*부터 0.*까지 0.1 간격으로 순회 ---
for i = 1:length(threshold_range)
    fcm_threshold = threshold_range(i);
    
    % --- 현재 임계값(fcm_threshold)에 기반한 논리 마스크 생성 ---
    logical_mask = Z_smooth >= fcm_threshold;

    % --- 1. 유효 영역 계산 ---
    valid_cells = nnz(logical_mask); % 조건이 참(true)인 셀의 개수 계산
    total_cells = numel(Z_smooth);     % 그리드의 전체 셀 개수
    area_percent = (valid_cells / total_cells) * 100;


    % --- 결과를 테이블에 저장 ---
    results_smoothed.Valid_Cell_Count(i) = valid_cells;
    results_smoothed.Area_Percentage(i) = area_percent;

    % --- 2. 오차 통계량 계산 ---
    if valid_cells > 0
        % 유효한 영역의 오차 값들만 추출
        valid_errors = Err_smooth(logical_mask);

        % 통계량 계산 및 저장
        results_smoothed.Mean_Error(i) = mean(valid_errors);
        % FCM 값이 0.7 이상인, 즉 드론이 안정적으로 비행한다고 판단되는 영역에서의 평균적인 위치 오차는 약 1.11이라는 뜻입니다

        results_smoothed.Max_Error(i)  = max(valid_errors);
        % FCM이 0.7 이상인 안정적인 영역 내에서도, 특정 조건에서는 오차가 최대 6.22까지 튀는 경우가 존재한다는 의미입니다

        results_smoothed.Sum_Error(i)  = sum(valid_errors);
    else
        % 유효한 셀이 없을 경우, NaN 또는 0으로 채움
        results_smoothed.Mean_Error(i) = NaN;
        results_smoothed.Max_Error(i)  = NaN;
        results_smoothed.Sum_Error(i)  = 0;
    end

    % --- 마스크를 사용해 C_surf 값을 담을 새 행렬 생성 ---
    filtered_C_surf = NaN(size(Err_smooth)); 
    filtered_C_surf(logical_mask) = Err_smooth(logical_mask);

    
    % --- 필터링된 데이터로 2D 히트맵 생성 ---
    figure; % 새 Figure 창을 열어 플롯이 겹치지 않게 함
    
    h_filtered = heatmap(-colF, -rowF, filtered_C_surf);
    
    % --- 히트맵 모양 사용자 정의 (제목에 현재 threshold 값을 표시) ---
    title_str = sprintf('Max Avg XYZ Error when Min Avg Saturated FCM >= %.2f (Smoothing Data)', fcm_threshold);
    h_filtered.Title = title_str;
    h_filtered.XLabel = 'Wind Y';
    h_filtered.YLabel = 'Wind X';
    h_filtered.Colormap = jet;
    h_filtered.ColorLimits = [0 5];
    h_filtered.CellLabelColor = 'none';
    h_filtered.GridVisible = 'off';
    
    % --- 필터링되어 제외된 (NaN) 데이터의 표시 방법 처리 ---
    h_filtered.MissingDataColor = [0.8 0.8 0.8];
    h_filtered.MissingDataLabel = sprintf('FCM < %.2f', fcm_threshold);

end % for 반복문 종료

% --- [수정] 최종 결과 테이블 출력 ---
disp('Quantitative Comparison of Area and Error Statistics (Smoothed Data):');
disp(results_smoothed); % 하나의 테이블만 출력

% --- [수정] 플롯 코드 ---
% Figure 3: Valid Area Change (Smoothed Data)
figure;

% 1. 플롯할 데이터를 새로운 변수에 복사합니다.
plot_data = results_smoothed.Area_Percentage;

% 2. isnan 함수로 NaN 값의 위치를 찾아서 0으로 바꿉니다.
plot_data(isnan(plot_data)) = 0;

plot(results_smoothed.FCM_Threshold, plot_data, '-o', 'LineWidth', 2, 'Color', 'c');
title('Change in Valid Area by FCM Threshold (Smoothed Data)');
xlabel('Minimum FCM Threshold');
ylabel('Valid Area (%)');
xlim([threshold_range(1), threshold_range(end)]);
grid on;
legend('Smoothed Data');

% Figure 4: Mean Error Change (Smoothed Data)
figure;

% 1. 플롯할 데이터를 새로운 변수에 복사합니다.
plot_data = results_smoothed.Mean_Error;

% 2. isnan 함수로 NaN 값의 위치를 찾아서 0으로 바꿉니다.
plot_data(isnan(plot_data)) = 0;

plot(results_smoothed.FCM_Threshold, plot_data, '-s', 'LineWidth', 2, 'Color', 'm');
title('Mean XYZ Error in Valid Area (Smoothed Data)');
xlabel('Minimum FCM Threshold');
ylabel('Mean Max Avg XYZ Error');
xlim([threshold_range(1), threshold_range(end)]);
grid on;
legend('Smoothed Data');


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