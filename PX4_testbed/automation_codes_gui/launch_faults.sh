#!/bin/bash
# 파일명: launch_faults.sh (SILS 방식과 동일하게 수정)
# 설명: 1. MATLAB에서 받은 인자(고장 번호)로 'build_faults.sh'를 먼저 실행합니다.
#      2. 'terminator'를 띄워서 해당 세션에 접속합니다.

SESSION_NAME="sils_faults"

# MATLAB에서 받은 모든 인자(고장 번호)를 $BUILD_ARGS 변수에 저장
BUILD_ARGS=("$@")

echo "Building fault session in background..."

# 1. 'build_faults.sh'를 '기다리면서' 실행
#    (이 스크립트가 있는 동일한 폴더에 있다고 가정)
#    "$@"를 사용해 모든 고장 번호(e.g., 0 0 0 3 8)를 그대로 넘겨줍니다.
$(dirname "$0")/build_faults.sh "${BUILD_ARGS[@]}"

echo "Build complete. Launching new terminal to attach..."

# 2. 'terminator'를 띄우고 attach 실행
terminator -e "tmux attach-session -t $SESSION_NAME"

echo "Fault viewer launched. This script will now exit."