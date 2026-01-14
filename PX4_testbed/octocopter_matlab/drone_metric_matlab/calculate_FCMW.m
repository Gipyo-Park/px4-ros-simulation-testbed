function [FCMW,avg_array_FCM] = calculate_FCMW(FCM,window_size_)
    
    % smulation get a sample every 0.01 sec.
    % 윈도우 크기 설정

    persistent array_FCM initialized;

    % 초기화가 필요할 때만 실행
    if isempty(initialized)
        % array_FCM = [];
        initialized = true; % 초기화 완료 표시
    end

    window_size = window_size_;


    % FCM 값을 배열에 추가 (FIFO 방식)
    if length(array_FCM) < window_size
        array_FCM = [array_FCM, FCM];  % 배열 크기가 작으면 FCM 추가
    else
        array_FCM = [array_FCM(2:end), FCM];  % FIFO 방식으로 업데이트
    end

    % 배열 평균 계산
    avg_array_FCM = sum(array_FCM) / length(array_FCM);

    % FCMW 계산
    if avg_array_FCM < 0.5
        FCMW = 0;
    else
        FCMW = 1;
    end
    
    % disp('array_FCM = ')
    % disp(array_FCM)

    disp('avg_array_FCM = ')
    disp(avg_array_FCM)

    
end