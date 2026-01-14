#!/bin/bash
source ~/.bashrc
source /opt/ros/noetic/setup.bash
source /home/hmcl/catkin_ws/devel/setup.bash #mavros path
source /home/hmcl/catkin_ws_katech/devel/setup.bash #matlab path

# window size cmd 
#xwininfo -id $(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')  
# xwininfo -id $(xdotool getactivewindow) 




# RIVZ,RQT,QGC launch
gnome-terminal --window --title="all" --geometry 72x26+1245+26 --working-directory /home/hmcl/PX4_testbed/automation_codes -- /bin/bash -c "bash ./set_sils.sh $1 $2 $3 $4 $5 $6 ;bash"
