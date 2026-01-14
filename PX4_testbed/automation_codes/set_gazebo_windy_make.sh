#!/bin/bash
unset LD_LIBRARY_PATH
#unset GAZEBO_MODEL_PATH
#unset GAZEBO_PLUGIN_PATH


source ~/.bashrc
source /opt/ros/noetic/setup.bash
source ~/catkin_ws/devel/setup.bash #mavros path



killall -9 gzserver && killall -9 gzclient

cd ~/PX4_testbed/PX4-Autopilot   #make px4_sitl gazebo_octocopter3

# Options
# HEADLESS=1 : Turn off the gazebo gui
# PX4_SIM_SPEED_FACTOR=2 : Simulation speed

# export PX4_HOME_LAT=28.452386
# export PX4_HOME_LON=-13.867138
# export PX4_HOME_ALT=28.5
make px4_sitl gazebo-classic_octocopter3__windy



# roslaunch px4 posix_sitl.launch world:=$(pwd)/Tools/simulation/gazebo-classic/sitl_gazebo-classic/worlds/windy.world


#roslaunch px4 posix_sitl.launch x:=$1 y:=$2 Y:=$3 x_car:=$4 y_car:=$5 yaw_car:=$6


# PX4_GZ_WORLD="windy.world" make px4_sitl gazebo-classic


