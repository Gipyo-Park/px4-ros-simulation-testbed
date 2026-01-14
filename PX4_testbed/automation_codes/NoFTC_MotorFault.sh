#!/bin/bash

open_terminal_tab() {
    local command=$1
    local title=$2
    gnome-terminal --tab --title="$title" -- bash -c "echo -ne '\033]0;$title\007'; $command; exec bash"
}

# Motor Failure 명령 실행
motor_failure_number=$(cat motor_failure_number.txt)
motor_failure_number1=$(cat motor_failure_number1.txt)
motor_failure_number2=$(cat motor_failure_number2.txt)
motor_failure_number3=$(cat motor_failure_number3.txt)
motor_failure_number4=$(cat motor_failure_number4.txt)

motor_failure_mode="rostopic pub /mavros/keyboard_command/failure_mode std_msgs/Char \"data: 102\""
open_terminal_tab "$motor_failure_mode" "No FTC mode"

sleep 2

# motor_failure_number가 0이 아니면 명령어 실행
if [ "$motor_failure_number" -ne 0 ]; then
    motor_failure_command="rostopic pub /mavros/keyboard_command/failure_number std_msgs/Float32 \"data: $motor_failure_number\""
    open_terminal_tab "$motor_failure_command" "Publish Motor Failure without FTC"
    sleep 3
fi

# motor_failure_number1가 0이 아니면 명령어 실행
if [ "$motor_failure_number1" -ne 0 ]; then
    motor_failure_command1="rostopic pub /mavros/keyboard_command/failure_number std_msgs/Float32 \"data: $motor_failure_number1\""
    open_terminal_tab "$motor_failure_command1" "Publish Motor Failure_1 without FTC"
    sleep 3
fi

# motor_failure_number2가 0이 아니면 명령어 실행
if [ "$motor_failure_number2" -ne 0 ]; then
    motor_failure_command2="rostopic pub /mavros/keyboard_command/failure_number std_msgs/Float32 \"data: $motor_failure_number2\""
    open_terminal_tab "$motor_failure_command2" "Publish Motor Failure_2 without FTC"
    sleep 3
fi

# motor_failure_number3가 0이 아니면 명령어 실행
if [ "$motor_failure_number3" -ne 0 ]; then
    motor_failure_command3="rostopic pub /mavros/keyboard_command/failure_number std_msgs/Float32 \"data: $motor_failure_number3\""
    open_terminal_tab "$motor_failure_command3" "Publish Motor Failure_3 without FTC"
    sleep 3
fi

# motor_failure_number4가 0이 아니면 명령어 실행
if [ "$motor_failure_number4" -ne 0 ]; then
    motor_failure_command4="rostopic pub /mavros/keyboard_command/failure_number std_msgs/Float32 \"data: $motor_failure_number4\""
    open_terminal_tab "$motor_failure_command4" "Publish Motor Failure_4 without FTC"
    sleep 3
fi
