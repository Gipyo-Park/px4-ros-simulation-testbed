#!/bin/bash

echo '[INFO] Start ROS Parameter Initialization'
echo '[INFO] Delete all the Parameter'
rosparam delete / 
echo '[INFO] Re-upload all the Initial Parameter'
rosparam load /home/hmcl/PX4_testbed/Parameter/katech3.yaml 
