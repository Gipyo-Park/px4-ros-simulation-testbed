#!/bin/bash 
source ~/.bashrc

#gnome-terminal --tab -- /bin/bash -c "ls;bash"

killall -9 gzserver && killall -9 gzclient

cd /home/hmcl/PX4_testbed/PX4-Autopilot   #make px4_sitl gazebo_octocopter3
DONT_RUN=1 make px4_sitl gazebo-classic_octocopter3  #make px4_sitl gazebo-classic_iris or 
source ~/catkin_ws/devel/setup.bash    # (optional)
source Tools/simulation/gazebo-classic/setup_gazebo.bash $(pwd) $(pwd)/build/px4_sitl_default
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$(pwd)
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$(pwd)/Tools/simulation/gazebo-classic/sitl_gazebo-classic
roslaunch px4 posix_sitl.launch x:=$1 y:=$2 Y:=$3 x_car:=$4 y_car:=$5 yaw_car:=$6

#roslaunch px4 posix_sitl.launch world:=~/PX4_testbed/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic/worlds/windy.world

# PX4_GZ_WORLD="windy.world" make px4_sitl gazebo-classic


#roslaunch px4 posix_sitl.launch world:=/Tools/simulation/gazebo-classic/sitl_gazebo-classic/worlds/windy.world
