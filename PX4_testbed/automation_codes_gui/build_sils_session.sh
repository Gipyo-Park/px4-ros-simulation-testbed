#!/bin/bash
# 파일명: build_sils_session.sh (명령어 분리 및 순서 수정)

# --- 1. 경로 및 변수 설정 (동일) ---
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_ROOT=$(cd -- "${SCRIPT_DIR}/.." &> /dev/null && pwd)
PX4_DIR="${PROJECT_ROOT}/PX4-Autopilot"
ROS_SOURCE="source ~/.bashrc; source /opt/ros/noetic/setup.bash; source ${PROJECT_ROOT}/catkin_ws/devel/setup.bash;"
GAZEBO_SOURCE="unset LD_LIBRARY_PATH; ${ROS_SOURCE} killall -9 gzserver && killall -9 gzclient; cd ${PX4_DIR};"
X_VAL=${SETPOINT_X:-0.0}
Y_VAL=${SETPOINT_Y:-0.0}
Z_VAL=${SETPOINT_Z:-20.0}
ORI_X_VAL=${SETPOINT_ORI_X:-0.0}
ORI_Y_VAL=${SETPOINT_ORI_Y:-0.0}
ORI_Z_VAL=${SETPOINT_ORI_Z:-0.0}
ORI_W_VAL=${SETPOINT_ORI_W:-1.0}
MODE_ARG=${REALLOC_ABLE:-102}

SESSION_NAME="sils_setup"

# --- 2. tmux 세션 생성 및 Pane 분할 (동일) ---
echo "Building new session in background: $SESSION_NAME"
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    tmux kill-session -t $SESSION_NAME
fi

tmux new-session -d -s $SESSION_NAME -n "main"
echo "Configuring 3x3 pane layout..."
# 3x3 레이아웃 설정
# --- 2. Pane 레이아웃 설정 (수정됨: 진짜 3x3 그리드) ---
tmux split-window -v -t $SESSION_NAME:0
tmux split-window -v -t $SESSION_NAME:0.0
tmux split-window -h -t $SESSION_NAME:0.0
tmux split-window -h -t $SESSION_NAME:0.1
tmux split-window -h -t $SESSION_NAME:0.3
tmux split-window -h -t $SESSION_NAME:0.4
tmux split-window -h -t $SESSION_NAME:0.6
tmux split-window -h -t $SESSION_NAME:0.7
sleep 1

# --- 3. 명령어 정의 (수정됨) ---
# [공통]
CMD_GAZEBO="${GAZEBO_SOURCE} make px4_sitl gazebo-classic_octocopter3__windy; exec bash"
CMD_MAVROS="${ROS_SOURCE} roslaunch mavros px4.launch fcu_url:=udp://:14540@; exec bash"
CMD_MAVPROXY="${ROS_SOURCE} mavproxy.py --master=udp:127.0.0.1:14550 --out=udp:127.0.0.1:14551 --out=udp:127.0.0.1:14552; exec bash"
CMD_BRIDGE="${ROS_SOURCE} rosrun px4_bridge_msgs mavlink_to_ros.py; exec bash"
CMD_POSE="${ROS_SOURCE} rostopic echo /mavros/local_position/pose -c; exec bash"
CMD_SET_MODE="${ROS_SOURCE} rosservice call /mavros/set_mode \"custom_mode: 'OFFBOARD'\"; echo 'OFFBOARD Set.'; exec bash"
CMD_ARMING="${ROS_SOURCE} echo 'Arming...'; rosservice call /mavros/cmd/arming \"value: true\"; echo 'Armed.'; exec bash"

# [수정] Setpoint가 Flag와 분리됨
CMD_SETPOINT="${ROS_SOURCE} rostopic pub -r 10 /mavros/setpoint_position/local geometry_msgs/PoseStamped \"{pose: {position: {x: $X_VAL, y: $Y_VAL, z: $Z_VAL}, orientation: {x: $ORI_X_VAL, y: $ORI_Y_VAL, z: $ORI_Z_VAL, w: $ORI_W_VAL}}}\"; exec bash"

# [수정] Failure Mode가 IF문을 통해 Pane 8번 명령어로 정의됨
if [ "$MODE_ARG" == "101" ]; then
    CMD_FAILURE_MODE="${ROS_SOURCE} echo 'Setting Mode 101 (Reallocation FTC)'; rostopic pub /mavros/keyboard_command/failure_mode std_msgs/Char \"data: 101\" --once; echo 'Mode 101 Set.'; exec bash"
elif [ "$MODE_ARG" == "102" ]; then
    CMD_FAILURE_MODE="${ROS_SOURCE} echo 'Setting Mode 102 (No FTC)'; rostopic pub /mavros/keyboard_command/failure_mode std_msgs/Char \"data: 102\" --once; echo 'Mode 102 Set.'; exec bash"
else
    CMD_FAILURE_MODE="${ROS_SOURCE} echo 'Warning: No valid MODE_ARG set. Skipping Failure Mode.'; exec bash"
fi


# --- 4. 각 Pane에 명령어 "순서대로" 실행 (수정됨) ---
# Gazebo/MAVROS 준비
tmux send-keys -t $SESSION_NAME:0.0 "$CMD_GAZEBO" C-m
sleep 20 # Gazebo/PX4가 뜰 최소 시간

tmux send-keys -t $SESSION_NAME:0.1 "$CMD_MAVROS" C-m
sleep 5

# # MAVROS 연결 확인
# WAIT_CMD="${ROS_SOURCE} rostopic list | grep -q '/mavros/state'"
# until bash -c "$WAIT_CMD"; do
#     echo "Waiting for /mavros/state topic... (retrying in 1s)"
#     sleep 1
# done

# --- gnome-terminal 스크립트 순서대로 나머지 실행 ---

# 1. Set Mode
tmux send-keys -t $SESSION_NAME:0.2 "$CMD_SET_MODE" C-m
sleep 1

# 2. Setpoint
tmux send-keys -t $SESSION_NAME:0.3 "$CMD_SETPOINT" C-m
sleep 1

# 3. Arming
tmux send-keys -t $SESSION_NAME:0.4 "$CMD_ARMING" C-m
# sleep 1

# 4. Mavproxy
tmux send-keys -t $SESSION_NAME:0.5 "$CMD_MAVPROXY" C-m
sleep 1

# 5. Bridge
tmux send-keys -t $SESSION_NAME:0.6 "$CMD_BRIDGE" C-m
sleep 5

# 6. Failure Mode
tmux send-keys -t $SESSION_NAME:0.7 "$CMD_FAILURE_MODE" C-m
sleep 0.5

# 7. Pose Echo
tmux send-keys -t $SESSION_NAME:0.8 "$CMD_POSE" C-m
sleep 1

# --- [핵심] 모든 Pane이 실행된 후, Flag 파일 생성 ---
echo "All nodes launched. Creating flag file..."
touch /tmp/mavros_script_finished.flag

echo "Session build complete. This script will now exit."