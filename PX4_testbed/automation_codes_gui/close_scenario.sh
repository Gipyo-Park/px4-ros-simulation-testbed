#!/bin/bash
# 파일명: close_scenario.sh
# 설명: roscore를 제외한 시뮬레이션 및 고장 세션을 종료합니다.

echo "Closing scenario and fault sessions..."

# 이름으로 세션을 지정하여 종료 ('sils_roscore' 세션은 건드리지 않음)
tmux kill-session -t "sils_setup" 2>/dev/null
tmux kill-session -t "sils_faults" 2>/dev/null

# Gazebo 프로세스가 세션 종료 후에도 남아있을 경우를 대비해 강제 종료
killall -9 gzserver 2>/dev/null
killall -9 gzclient 2>/dev/null

echo "Scenario sessions closed. 'sils_roscore' session remains."