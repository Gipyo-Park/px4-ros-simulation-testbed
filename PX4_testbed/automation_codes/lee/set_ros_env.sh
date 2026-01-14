#!/bin/bash 
source ~/.bashrc

# Each command
#gnome-terminal --tab --title="ROSCORE" --working-directory /home/hmcl/PX4_testbed/automation_codes -e "/bin/bash -c './set_roscore.sh;bash'" --tab --title="test" -e "bash -c 'echo Please type kill; bash'"
#gnome-terminal --tab --title="test" -e "bash -c 'echo Please type kill; bash'"
#gnome-terminal --tab --title="KATECH SILS" --working-directory /home/hmcl/PX4_testbed/automation_codes -e "/bin/bash -c ' ./set_sils.sh $1 $2 $3 $4 $5 $6 ;bash'"

# Start roscore/ QGC / Kill
# need bashrc ---> alias kill='cd /home/hmcl/PX4_testbed/automation_codes && sudo ./kill.sh'
echo '[INFO] Start ROSCORE / QGC / Kill '
gnome-terminal --geometry 71x24+1248-4 --tab --title="ROSCORE" --working-directory /home/hmcl/PX4_testbed/automation_codes -e "/bin/bash -c 'roscore;bash'" --tab --title="QGC" --working-directory /home/hmcl -e "bash -c './QGroundControl.AppImage; bash'"  --tab --title="test" -e "bash -c 'echo Please type Kill; bash'" 
