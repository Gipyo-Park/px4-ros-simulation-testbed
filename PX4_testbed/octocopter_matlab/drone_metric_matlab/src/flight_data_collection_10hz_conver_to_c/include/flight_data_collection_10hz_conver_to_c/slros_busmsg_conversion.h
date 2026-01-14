#ifndef _SLROS_BUSMSG_CONVERSION_H_
#define _SLROS_BUSMSG_CONVERSION_H_

#include <ros/ros.h>
#include <geometry_msgs/Point.h>
#include <geometry_msgs/Pose.h>
#include <geometry_msgs/PoseStamped.h>
#include <geometry_msgs/Quaternion.h>
#include <geometry_msgs/Twist.h>
#include <geometry_msgs/TwistStamped.h>
#include <geometry_msgs/Vector3.h>
#include <ros/time.h>
#include <sensor_msgs/Imu.h>
#include <std_msgs/Float64.h>
#include <std_msgs/Float64MultiArray.h>
#include <std_msgs/Header.h>
#include <std_msgs/MultiArrayDimension.h>
#include <std_msgs/MultiArrayLayout.h>
#include "flight_data_collection_10hz_conver_to_c_types.h"
#include "slros_msgconvert_utils.h"


void convertFromBus(geometry_msgs::Point* msgPtr, SL_Bus_flight_data_collection_10_Point_4ca2ai const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Point_4ca2ai* busPtr, geometry_msgs::Point const* msgPtr);

void convertFromBus(geometry_msgs::Pose* msgPtr, SL_Bus_flight_data_collection_10_Pose_i6ux6j const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Pose_i6ux6j* busPtr, geometry_msgs::Pose const* msgPtr);

void convertFromBus(geometry_msgs::PoseStamped* msgPtr, SL_Bus_flight_data_collection_10_PoseStamped_eyjot5 const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_PoseStamped_eyjot5* busPtr, geometry_msgs::PoseStamped const* msgPtr);

void convertFromBus(geometry_msgs::Quaternion* msgPtr, SL_Bus_flight_data_collection_10_Quaternion_eyvx4o const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Quaternion_eyvx4o* busPtr, geometry_msgs::Quaternion const* msgPtr);

void convertFromBus(geometry_msgs::Twist* msgPtr, SL_Bus_flight_data_collection_10_Twist_49xrwj const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Twist_49xrwj* busPtr, geometry_msgs::Twist const* msgPtr);

void convertFromBus(geometry_msgs::TwistStamped* msgPtr, SL_Bus_flight_data_collection_10_TwistStamped_z3d5zv const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_TwistStamped_z3d5zv* busPtr, geometry_msgs::TwistStamped const* msgPtr);

void convertFromBus(geometry_msgs::Vector3* msgPtr, SL_Bus_flight_data_collection_10_Vector3_v8mj3a const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Vector3_v8mj3a* busPtr, geometry_msgs::Vector3 const* msgPtr);

void convertFromBus(ros::Time* msgPtr, SL_Bus_flight_data_collection_10_Time_88pnn8 const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Time_88pnn8* busPtr, ros::Time const* msgPtr);

void convertFromBus(sensor_msgs::Imu* msgPtr, SL_Bus_flight_data_collection_10_Imu_2vctgh const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Imu_2vctgh* busPtr, sensor_msgs::Imu const* msgPtr);

void convertFromBus(std_msgs::Float64* msgPtr, SL_Bus_flight_data_collection_10_Float64_idzuct const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Float64_idzuct* busPtr, std_msgs::Float64 const* msgPtr);

void convertFromBus(std_msgs::Float64MultiArray* msgPtr, SL_Bus_flight_data_collection_10_Float64MultiArray_eifb71 const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Float64MultiArray_eifb71* busPtr, std_msgs::Float64MultiArray const* msgPtr);

void convertFromBus(std_msgs::Header* msgPtr, SL_Bus_flight_data_collection_10_Header_8xb66k const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Header_8xb66k* busPtr, std_msgs::Header const* msgPtr);

void convertFromBus(std_msgs::MultiArrayDimension* msgPtr, SL_Bus_flight_data_collection_10_MultiArrayDimension_lr3iox const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_MultiArrayDimension_lr3iox* busPtr, std_msgs::MultiArrayDimension const* msgPtr);

void convertFromBus(std_msgs::MultiArrayLayout* msgPtr, SL_Bus_flight_data_collection_10_MultiArrayLayout_h4oya9 const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_MultiArrayLayout_h4oya9* busPtr, std_msgs::MultiArrayLayout const* msgPtr);


#endif
