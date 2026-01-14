function [FCMW_saturated, avg_array_FCM_saturated] = calculate_FCMW_saturated(FCM_saturated, window_size_)
    % simulation get a sample every 0.01 sec.
    % saturated 윈도우 크기 관리용

    % persistent 변수 및 현재 채워진 요소 수를 관리할 카운터 선언
    persistent array_FCM_saturated currentCount_saturated maxWindow_saturated;

    % 최초 호출 시 고정 크기 배열을 할당하고, 카운터를 0으로 초기화
    if isempty(array_FCM_saturated)
        maxWindow_saturated = window_size_;  % 최대 배열 크기
        array_FCM_saturated = zeros(1, maxWindow_saturated);  % 고정 크기 배열 할당
        currentCount_saturated = 0;
    end

    % 현재 배열에 채워진 요소 수가 window_size_ 미만이면 새 값 추가
    % 아니면 FIFO 방식으로 업데이트: 좌측 이동 후 새 값 삽입
    if currentCount_saturated < window_size_
        currentCount_saturated = currentCount_saturated + 1;
        array_FCM_saturated(currentCount_saturated) = FCM_saturated;
    else
        array_FCM_saturated(1:window_size_-1) = array_FCM_saturated(2:window_size_);
        array_FCM_saturated(window_size_) = FCM_saturated;
    end

    % 채워진 요소만 고려하여 평균 계산
    avg_array_FCM_saturated = sum(array_FCM_saturated(1:currentCount_saturated)) / currentCount_saturated;

    % FCMW_saturated 계산: 평균이 0.5 미만이면 0, 아니면 1
    if avg_array_FCM_saturated < 0.5
        FCMW_saturated = 0;
    else
        FCMW_saturated = 1;
    end

    % % (옵션) 디버깅 메시지
    % disp('Current FIFO array (saturated):');
    % disp(array_FCM_saturated(1:currentCount_saturated));
end
