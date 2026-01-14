#!/bin/bash
# 파일명: launch_sils.sh

echo "Building SILS session... (Approx 20 seconds)"
# 1. 'build' 스크립트를 '기다리면서' 실행 ( & 없음 )
#    이 작업이 20초간 멈춰있습니다. (MATLAB도 멈춰있음)
$(dirname "$0")/build_sils_session.sh

echo "Build complete. Launching new terminal to attach..."
# 2. 새 터미널 창을 띄우라는 '명령'을 내림
terminator -e "tmux attach-session -t sils_setup"

echo "End launch_sils.sh."
# 3. 스크립트 종료