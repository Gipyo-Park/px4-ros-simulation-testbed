#!/bin/bash
# 파일명: kill_roscore.sh (수정됨)
# 설명: 'sils_roscore'라는 이름의 'tmux 세션'을 강제 종료합니다.

SESSION_NAME="sils_roscore"

echo "Attempting to shut down tmux session: $SESSION_NAME..."

# 'tmux has-session'으로 세션이 있는지 확인하고 'kill-session'으로 종료
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    tmux kill-session -t $SESSION_NAME
    echo "tmux session '$SESSION_NAME' successfully shut down."
else
    echo "tmux session '$SESSION_NAME' was not found running."
fi

# (혹시 모를) rosmaster 프로세스 확인 사살
killall -9 roscore 2>/dev/null
killall -9 rosmaster 2>/dev/null
echo "All ROS core processes are confirmed down."