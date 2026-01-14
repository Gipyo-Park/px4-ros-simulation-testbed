#!/bin/bash
unset LD_LIBRARY_PATH
#unset GAZEBO_MODEL_PATH
#unset GAZEBO_PLUGIN_PATH


source ~/.bashrc
source /opt/ros/noetic/setup.bash
source ~/catkin_ws/devel/setup.bash #mavros path

#gnome-terminal --tab -- /bin/bash -c "ls;bash"

killall -9 gzserver && killall -9 gzclient

cd ~/PX4_testbed/PX4-Autopilot  #make px4_sitl gazebo_octocopter3
DONT_RUN=1 make px4_sitl_default gazebo-classic  #make px4_sitl gazebo-classic_iris or
source ~/catkin_ws/devel/setup.bash    # (optional)
source Tools/simulation/gazebo-classic/setup_gazebo.bash $(pwd) $(pwd)/build/px4_sitl_default
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$(pwd)
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$(pwd)/Tools/simulation/gazebo-classic/sitl_gazebo-classic
# PX4_SIM_SPEED_FACTOR=2 
roslaunch px4 posix_sitl.launch

# roslaunch px4 posix_sitl.launch world:=$(pwd)/Tools/simulation/gazebo-classic/sitl_gazebo-classic/worlds/windy.world


#roslaunch px4 posix_sitl.launch x:=$1 y:=$2 Y:=$3 x_car:=$4 y_car:=$5 yaw_car:=$6


# PX4_GZ_WORLD="windy.world" make px4_sitl gazebo-classic


