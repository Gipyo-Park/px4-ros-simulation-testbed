close all;

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