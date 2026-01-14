#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# SCRIPT_DIR를 기준으로 대상 스크립트의 절대 경로를 만듭니다
TARGET_SCRIPT_PATH="$SCRIPT_DIR/set_gazebo_windy_make.sh"
TARGET_SCRIPT_PATH1="$SCRIPT_DIR/mavros_offboard_setpoint_arm.sh"

# 첫 번째 스크립트를 새로운 터미널에서 실행
# gnome-terminal -- bash -c "/home/hmcl/PX4_testbed/automation_codes/set_gazebo_windy_make.sh; exec bash" &
gnome-terminal -- bash -c "$TARGET_SCRIPT_PATH; exec bash" &
sleep 20
echo "Done set_gazebo_windy_make"

# 첫 번째 터미널 PID 확인
FIRST_TERMINAL_PID=$(pgrep -n gnome-terminal)
echo $FIRST_TERMINAL_PID > "${SCRIPT_DIR}/first_terminal_pid.txt"
echo "First terminal PID: $FIRST_TERMINAL_PID"

# sleep 5 #가제보 gui를 키면 슬립줄이 잇는게 낫다. 추후에 에러가 나온다.

# 두 번째 스크립트를 새로운 터미널에서 실행
# gnome-terminal -- bash -c "/home/hmcl/PX4_testbed/automation_codes/mavros_offboard_setpoint_arm.sh; exec bash" &
gnome-terminal -- bash -c "$TARGET_SCRIPT_PATH1; exec bash" &
echo "Done mavros_offboard_setpoint_arm"

# 두 번째 터미널 PID 확인
SECOND_TERMINAL_PID=$(pgrep -n gnome-terminal)
echo $SECOND_TERMINAL_PID > "${SCRIPT_DIR}/second_terminal_pid.txt"
echo "Second terminal PID: $SECOND_TERMINAL_PID"
