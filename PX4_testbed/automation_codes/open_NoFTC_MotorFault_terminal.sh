#!/bin/bash

# 이 스크립트 파일이 위치한 절대 경로를 찾습니다
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# SCRIPT_DIR를 기준으로 대상 스크립트의 절대 경로를 만듭니다
TARGET_SCRIPT_PATH="$SCRIPT_DIR/NoFTC_MotorFault.sh"

# 스크립트를 새로운 터미널에서 실행
# gnome-terminal -- bash -c "/home/hmcl/PX4_testbed/automation_codes/NoFTC_MotorFault.sh; exec bash" &
gnome-terminal -- bash -c "$TARGET_SCRIPT_PATH; exec bash" &

# 터미널 PID 확인
THIRD_TERMINAL_PID=$(pgrep -n gnome-terminal)
echo $THIRD_TERMINAL_PID > third_terminal_pid.txt
echo "Third terminal PID: $THIRD_TERMINAL_PID"
