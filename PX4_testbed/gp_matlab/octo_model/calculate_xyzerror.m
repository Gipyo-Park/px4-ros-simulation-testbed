function [one_or_zero,avg_array_xyz_error] = calculate_xyzerror(xyz_error,window_size_)
    
    % smulation get a sample every 0.01 sec.
    % 윈도우 크기 설정

    % persistent 변수 및 현재 채워진 요소 수를 관리할 카운터 선언
    persistent array_xyz_error currentCount maxWindow;
    
    % 최초 호출 시 고정 크기 배열을 할당하고, 카운터를 0으로 초기화.
    if isempty(array_xyz_error)
        maxWindow = window_size_;  % 최대 배열 크기를 window_size_로 정함.
        array_xyz_error = zeros(1, maxWindow);  % 고정 크기 배열 할당
        currentCount = 0;
    end
    
    % 만약 현재 배열에 채워진 요소 수가 window_size_ 미만이면 새 값을 추가
    % 아니라면 FIFO 방식으로 업데이트: 좌측 이동 후 새 값 삽입.
    if currentCount < window_size_
        currentCount = currentCount + 1;
        array_xyz_error(currentCount) = xyz_error;
    else
        array_xyz_error(1:window_size_-1) = array_xyz_error(2:window_size_);
        array_xyz_error(window_size_) = xyz_error;
    end
    
    % 채워진 요소만 고려하여 평균 계산
    avg_array_xyz_error = sum(array_xyz_error(1:currentCount)) / currentCount;
    
    % one_or_zero 계산: 평균이 0.5 미만이면 0, 아니면 1로 설정
    if avg_array_xyz_error < 0.5
        one_or_zero = 0;
    else
        one_or_zero = 1;
    end
    
    % % (옵션) 디버깅 메시지 출력
    % disp('Current FIFO array:');
    % disp(array_xyz_error(1:currentCount));
    

end