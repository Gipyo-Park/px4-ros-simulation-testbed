%%
% 이거 실행시키기 
% mavproxy.py --master=udp:127.0.0.1:14550 --out=udp:127.0.0.1:14551 --out=udp:127.0.0.1:14552
% rosrun px4_bridge_msgs mavlink_to_ros.py
% 그래야 up uq ur 나옴

% 데이터 (예: out.flight_data_via_scope가 존재한다고 가정)
flight_data = out.flight_data_via_scope;

% 헤더 정의
% -------------------------------------------------------------------------
% 1. State Variables (상태 변수)
% -------------------------------------------------------------------------
%   Time            : 시뮬레이션 또는 비행 시간 [s]
%   X, Y, Z         : 관성 좌표계(NED) 기준 위치 [m]
%   u, v, w         : 기체 좌표계(Body) 기준 선속도 [m/s]
%   p, q, r         : 기체 좌표계 기준 각속도 (Gyro) [rad/s]
%   phi, theta, psi : 오일러 각 (Attitude) [rad]
%
% -------------------------------------------------------------------------
% 2. Controller Outputs (제어기 명령값)
% -------------------------------------------------------------------------
%   *_(controller)  : 제어기(Flight Controller) 내부에서 연산되어 출력된 최종 제어 신호
%     - u_p/q/r (controller): 제어 모멘트 명령
%     - f_x/y/z (controller): 제어 힘(Force) 명령
%
% -------------------------------------------------------------------------
% 3. Actuator-based Inputs (모터 RPM 기반 계산값)
% -------------------------------------------------------------------------
%   u_p, u_q, u_r   : 실제 모터 RPM을 바탕으로 믹서 방정식을 통해 역산한 제어 입력값
%   f_x, f_y, f_z   : 실제 모터 상태 또는 공력 모델을 기반으로 계산된 힘
%
% -------------------------------------------------------------------------
% 4. Moment Estimation & Validation (모멘트 추정 및 검증)
% -------------------------------------------------------------------------
%   nominal_Mx/y/z  : 이론적 모델 기반 모멘트
%                     [구성: 모터 RPM 기반 계산값 + 자이로스코프 효과 + 바람 영향]
%
%   backward_Mx/y/z : 역동역학(Inverse Dynamics) 기반 모멘트 
%                     [특징: 각가속도(Omega_dot) 계산 시 '후방 차분(Backward Difference)' 사용]
%
%   central_Mx/y/z  : 역동역학(Inverse Dynamics) 기반 모멘트 
%                     [특징: 각가속도(Omega_dot) 계산 시 '중앙 차분(Central Difference)' 사용]
% -------------------------------------------------------------------------
csv_headers = {'Time', 'X', 'Y', 'Z', 'u', 'v', 'w', 'p', 'q', 'r', 'phi (rad)', 'theta (rad)', 'psi (rad)', 'u_p (controller)', 'u_q (controller)', 'u_r (controller)', 'f_x (controller)', 'f_y (controller)', 'f_z (controller)', 'u_p', 'u_q', 'u_r', 'f_x', 'f_y', 'f_z','backward_Mx','backward_My','backward_Mz','nominal_Mx', 'nominal_My', 'nominal_Mz','central_Mx', 'central_My', 'central_Mz'};


% 헤더와 데이터를 결합
data_with_headers = [csv_headers; num2cell(flight_data)];

% CSV로 저장
writecell(data_with_headers, 'flight_data_for_lemni_yaw_alt.csv');
