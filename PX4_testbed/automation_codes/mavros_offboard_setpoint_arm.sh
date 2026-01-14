#!/bin/bash

# MATLAB에서 설정한 환경 변수를 읽어옵니다.
X_VAL=${SETPOINT_X:-0.0}
Y_VAL=${SETPOINT_Y:-0.0}
Z_VAL=${SETPOINT_Z:-20.0}

ORI_X_VAL=${SETPOINT_ORI_X:-0.0}
ORI_Y_VAL=${SETPOINT_ORI_Y:-0.0}
ORI_Z_VAL=${SETPOINT_ORI_Z:-0.0}
ORI_W_VAL=${SETPOINT_ORI_W:-1.0}

MODE_ARG=${REALLOC_ABLE:-102}



open_terminal_tab() {
    local command=$1
    local title=$2
    gnome-terminal --tab --title="$title" -- bash -c "$command; exec bash"
}

# Step 1: Start MAVROS
mavros_command="roslaunch mavros px4.launch fcu_url:=udp://:14540@"
open_terminal_tab "$mavros_command" "MAVROS"

# Wait a few seconds to ensure MAVROS is fully started
sleep 3

# Step 2: Set Mode to OFFBOARD
offboard_command="rosservice call /mavros/set_mode \"custom_mode: 'OFFBOARD'\""
open_terminal_tab "$offboard_command" "Set OFFBOARD Mode"
#
sleep 1

# Step 3: Publish Takeoff Setpoint
setpoint_command="rostopic pub -r 10 /mavros/setpoint_position/local geometry_msgs/PoseStamped \"{
   header: {
     seq: 0,
    stamp: {
      secs: 0,
      nsecs: 0
    },
    frame_id: ''
  },
  pose: {
    position: {
      x: $X_VAL,   
      y: $Y_VAL,   
      z: $Z_VAL    
    },
    orientation: {
      x: $ORI_X_VAL,  
      y: $ORI_Y_VAL,  
      z: $ORI_Z_VAL,  
      w: $ORI_W_VAL   
    }
  }
}\""
open_terminal_tab "$setpoint_command" "Publish Setpoint"

sleep 1

# Step 4: Arm the Vehicle
arm_command="rosservice call /mavros/cmd/arming \"value: true\""
open_terminal_tab "$arm_command" "Arm Vehicle"

# sleep 1

mavproxyUdpDivider="mavproxy.py --master=udp:127.0.0.1:14550 --out=udp:127.0.0.1:14551 --out=udp:127.0.0.1:14552"
open_terminal_tab "$mavproxyUdpDivider" "Divide udp port with mavproxy"

sleep 0.5

mavlinkToRosBridge="rosrun px4_bridge_msgs mavlink_to_ros.py"
open_terminal_tab "$mavlinkToRosBridge" "Get mavros data"


sleep 5

if [ "$MODE_ARG" == "101" ]; then
    motor_failure_mode="rostopic pub /mavros/keyboard_command/failure_mode std_msgs/Char \"data: 101\""
    open_terminal_tab "$motor_failure_mode" "reallocation FTC mode"

elif [ "$MODE_ARG" == "102" ]; then
    motor_failure_mode="rostopic pub /mavros/keyboard_command/failure_mode std_msgs/Char \"data: 102\""
    open_terminal_tab "$motor_failure_mode" "No FTC mode"

fi


sleep 0.5

pose_echo="rostopic echo /mavros/local_position/pose -c"
open_terminal_tab "$pose_echo" "Pose Echo"

sleep 1


echo "Debug: Step 4 completed"

touch /tmp/mavros_script_finished.flag
echo "Debug: Step 5 completed"


