#!/bin/bash 
source ~/.bashrc

# 이 스크립트 파일이 위치한 절대 경로를 찾습니다
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)


echo '[INFO] Start ROSCORE'
echo "SCRIPT_DIR: $SCRIPT_DIR"
# gnome-terminal --geometry 71x24+1248-4 --tab --title="ROSCORE" --working-directory /home/hmcl/PX4_testbed/automation_codes -e "/bin/bash -c 'roscore;bash'"
gnome-terminal --geometry 71x24+1248-4 --tab --title="ROSCORE" --working-directory "$SCRIPT_DIR" -e "/bin/bash -c 'roscore;bash'"
