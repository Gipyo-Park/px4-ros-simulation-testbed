# --- 상수(Constants) 정의 ---
# 믹서 그룹(mixer group)을 위한 상수 값들입니다.
uint8 PX4_MIX_FLIGHT_CONTROL = 0
uint8 PX4_MIX_FLIGHT_CONTROL_VTOL_ALT = 1
uint8 PX4_MIX_PAYLOAD = 2
uint8 PX4_MIX_MANUAL_PASSTHROUGH = 3

uint64 timestamp # time since system start (microseconds)

uint8 group_mix        # 명령을 보낼 믹서 그룹을 지정합니다. (예: PX4_MIX_FLIGHT_CONTROL)

float32[8] controls    # 실제 제어 명령 값이 담기는 8개 크기의 배열.
                       # 값은 [-1, 1] 사이로 정규화되어야 합니다.
                       # [0]: Roll Torque, [1]: Pitch Torque, [2]: Yaw Torque, [3]: Thrust

# TOPICS actuator_controls actuator_controls_0 actuator_controls_1 actuator_controls_2 actuator_controls_3
