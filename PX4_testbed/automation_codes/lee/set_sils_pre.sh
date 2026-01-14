#!/bin/bash
source ~/.bashrc
source /opt/ros/noetic/setup.bash
source ~/catkin_ws/devel/setup.bash #mavros path
source ~/catkin_ws_katech/devel/setup.bash #matlab path

# 0.GAZEBO launch
gnome-terminal --window --title="GAZEBO" --geometry 69x27+3194-26 --working-directory /home/hmcl/PX4_testbed/automation_codes -- /bin/bash -c "bash ./set_gazebo.sh $1 $2 $3 $4 $5 $6 ;bash"

gnome-terminal --tab --title="rviz" -e "bash -c 'rosrun rviz rviz -d /home/hmcl/PX4_testbed/rviz/sils_rviz.rviz; bash'" --tab --title="rqt" -e "bash -c 'rqt --perspective-file "/home/hmcl/PX4_testbed/rviz/katech.perspective"; bash'"
# Wait for GAZEBO
sleep 10s

#1.Main Node
#(1).Camera_node
#cmd1="rosrun zed_depth_sub_tutorial zed_depth_sub"
#(2).Lidar_node
cmd2="rosrun velodyne_distance_22 Velodyne_distance_22"
#(3).Nodelet
cmd3="rosrun katech_nodelet_v7_2020b katech_nodelet_v7_2020b"
#(4).MAVROS
cmd4="roslaunch mavros px4.launch fcu_url:="udp://:14540@127.0.0.1:14557""
#(5).OFFBOARD_Control
cmd5="echo 'Offboard Command'"

#2.Data Monitoring
#(1) Actual data(Fault-injected)
#1)Camera_Front
#cmd6="rostopic echo /katech/depth_data_camera_front -c"
#2).Camera_Down
#cmd7="rostopic echo /katech/depth_data_camera_down -c"
#3).Lidar
cmd8="rostopic echo /katech/depth_data_lidar -c"

sleep 2s

## Modify terminator's config
sed -i.bak "s#CMD1#$cmd1#; s#CMD2#$cmd2#; s#CMD3#$cmd3#; s#CMD4#$cmd4#; s#CMD5#$cmd5#; s#CMD6#$cmd6#;; s#CMD7#$cmd7#; s#CMD8#$cmd8# " ~/.config/terminator/config

## Launch a terminator instance using the new layout
terminator --geometry=1186x451+4470-0 -l katech 

## Return the original config file
rm ~/.config/terminator/config
mv ~/.config/terminator/config.bak ~/.config/terminator/config

