#!/bin/bash
# 파일명: start_roscore.sh (수정됨)
# 설명: roscore 세션을 띄우고, 세션 종료 시 터미널도 닫히게 합니다.

# --- 동적 경로 설정 ---
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_ROOT=$(cd -- "${SCRIPT_DIR}/.." &> /dev/null && pwd)
ROS_SOURCE="source ~/.bashrc; source /opt/ros/noetic/setup.bash; source ${PROJECT_ROOT}/catkin_ws/devel/setup.bash;"

SESSION_NAME="sils_roscore"

# 'sils_roscore' 세션이 이미 실행 중인지 확인
if ! tmux has-session -t $SESSION_NAME 2>/dev/null; then
    echo "Starting roscore session: $SESSION_NAME in new terminal."
    
    # [수정] 
    # 1. roscore용 tmux 세션을 '백그라운드(-d)'에서 먼저 만듭니다.
    tmux new-session -d -s $SESSION_NAME -n 'roscore' "${ROS_SOURCE} roscore; exec bash"
    
    # 2. 'gnome-terminal'은 'attach'만 하도록 합니다.
    #    "tmux ...; exit"로 감싸서, 'kill-session' 당하면 창이 닫히게 합니다.
    gnome-terminal -- bash -c "tmux attach-session -t $SESSION_NAME; exit" &

else
    echo "roscore session: $SESSION_NAME already running."
    
    # [수정] 여기도 "tmux ...; exit"로 감싸서 창이 닫히게 합니다.
    gnome-terminal -- bash -c "tmux attach-session -t $SESSION_NAME; exit" &
fi