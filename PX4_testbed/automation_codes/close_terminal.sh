#!/bin/bash

# 이 스크립트 파일이 위치한 절대 경로를 찾습니다
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# --- 공통 파일 정의 ---
FIRST_PID_FILE="${SCRIPT_DIR}/first_terminal_pid.txt"
SECOND_PID_FILE="${SCRIPT_DIR}/second_terminal_pid.txt"

# --- Automation 전용 파일 정의 ---
THIRD_PID_FILE="${SCRIPT_DIR}/third_terminal_pid.txt"
FOURTH_PID_FILE="${SCRIPT_DIR}/fourth_terminal_pid.txt"

# --- [신규] PID를 확인하고 종료하는 공통 함수 ---
check_and_kill() {
  local pid_file=$1 # $1은 함수에 전달된 첫 번째 인자(파일 경로)

  # 1. PID 파일이 존재하고, 내용이 비어있지 않은지 확인
  if [ -s "$pid_file" ]; then
    local pid=$(cat "$pid_file")
    
    # 2. "kill -0"을 사용해 PID가 현재 실행 중인 프로세스인지 확인
    # "2>/dev/null"은 'No such process' 같은 에러 메시지를 숨깁니다.
    if kill -0 "$pid" 2>/dev/null; then
      # 3. 프로세스가 살아있으면 종료
      kill "$pid"
      # echo "Process $pid terminated."
    fi
  fi
}

# --- 메인 실행 ---
# 정의한 함수를 각 PID 파일에 대해 실행
check_and_kill "$FIRST_PID_FILE"
check_and_kill "$SECOND_PID_FILE"
check_and_kill "$THIRD_PID_FILE"
# check_and_kill "$FOURTH_PID_FILE"