#!/bin/bash
# 파일명: build_faults.sh (버그 수정됨)
# 설명: 'sils_faults' 세션을 백그라운드에서 구축합니다.
#       [수정] 'exec' 버그를 제거하고, Pane이 닫히지 않도록 'exec bash'로 변경합니다.

# --- 동적 경로 설정 ---
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_ROOT=$(cd -- "${SCRIPT_DIR}/.." &> /dev/null && pwd)
ROS_SOURCE="source ~/.bashrc; source /opt/ros/noetic/setup.bash; source ${PROJECT_ROOT}/catkin_ws/devel/setup.bash;"

SESSION_NAME="sils_faults"

# --- 명령줄 인자(Arguments)를 배열로 직접 읽기 ---
FAULT_LIST=("$@")

# 실행할 명령어들을 임시 배열에 저장
CMD_LIST=()

for i in "${!FAULT_LIST[@]}"; do
    FAULT_NUM=${FAULT_LIST[$i]}
    
    if [ "$FAULT_NUM" -ne 0 ]; then
        echo "Preparing fault: $FAULT_NUM"
        CMD="${ROS_SOURCE} rostopic pub /mavros/keyboard_command/failure_number std_msgs/Float32 \"data: $FAULT_NUM\" --once; \
             echo 'Injected fault $FAULT_NUM. This pane will stay open.'; exec bash"
        CMD_LIST+=("$CMD")
    fi
done

if [ ${#CMD_LIST[@]} -eq 0 ]; then
    echo "No non-zero faults found to inject."
    exit 0
fi

# 기존 세션 삭제
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    tmux kill-session -t $SESSION_NAME
fi

# 1. 첫 번째 명령어로 세션 생성 (Detached)
echo "Building fault session: Pane 0..."
tmux new-session -d -s $SESSION_NAME -n 'faults' "${CMD_LIST[0]}"
sleep 1 

# 2. 나머지 명령어들을 split-window로 추가
for (( i=1; i<${#CMD_LIST[@]}; i++ )); do
    echo "Building fault session: Pane $i..."
    # [수정] "exec"를 제거하여 버그 수정
    tmux split-window -v -t $SESSION_NAME "${CMD_LIST[$i]}"

    sleep 1
done

# 3. 레이아웃 정리
tmux select-layout -t $SESSION_NAME tiled

echo "Fault session build complete. This script will now exit."