#!/bin/bash

# 스크립트 파일이 위치한 절대 경로를 찾습니다
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# SCRIPT_DIR를 기준으로 대상 스크립트의 절대 경로를 만듭니다
TARGET_SCRIPT_PATH="$SCRIPT_DIR/roscore_for_simulink.sh"

# 첫 번째 스크립트를 새로운 터미널에서 실행
# gnome-terminal -- bash -c "/home/hmcl/PX4_testbed/automation_codes/roscore_for_simulink.sh; exec bash" &
gnome-terminal -- bash -c "$TARGET_SCRIPT_PATH; exec bash" &
sleep 2

# 첫 번째 터미널 PID 확인
FOURTH_TERMINAL_PID=$(pgrep -n gnome-terminal)

# [수정] PID 파일을 스크립트 폴더($SCRIPT_DIR) 내에 저장합니다.
echo $FOURTH_TERMINAL_PID > "${SCRIPT_DIR}/fourth_terminal_pid.txt"
echo "Fourth terminal PID: $FOURTH_TERMINAL_PID written to ${SCRIPT_DIR}/fourth_terminal_pid.txt"
