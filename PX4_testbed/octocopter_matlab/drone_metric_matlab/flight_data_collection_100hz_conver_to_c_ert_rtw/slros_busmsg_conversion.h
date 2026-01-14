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
#include "flight_data_collection_100hz_conver_to_c_types.h"
#include "slros_msgconvert_utils.h"


void convertFromBus(geometry_msgs::Point* msgPtr, SL_Bus_flight_data_collection_10_Point_r08zbg const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Point_r08zbg* busPtr, geometry_msgs::Point const* msgPtr);

void convertFromBus(geometry_msgs::Pose* msgPtr, SL_Bus_flight_data_collection_10_Pose_v7gmqz const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Pose_v7gmqz* busPtr, geometry_msgs::Pose const* msgPtr);

void convertFromBus(geometry_msgs::PoseStamped* msgPtr, SL_Bus_flight_data_collection_10_PoseStamped_a63i0j const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_PoseStamped_a63i0j* busPtr, geometry_msgs::PoseStamped const* msgPtr);

void convertFromBus(geometry_msgs::Quaternion* msgPtr, SL_Bus_flight_data_collection_10_Quaternion_ez0huq const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Quaternion_ez0huq* busPtr, geometry_msgs::Quaternion const* msgPtr);

void convertFromBus(geometry_msgs::Twist* msgPtr, SL_Bus_flight_data_collection_10_Twist_r2l9pf const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Twist_r2l9pf* busPtr, geometry_msgs::Twist const* msgPtr);

void convertFromBus(geometry_msgs::TwistStamped* msgPtr, SL_Bus_flight_data_collection_10_TwistStamped_snnfb5 const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_TwistStamped_snnfb5* busPtr, geometry_msgs::TwistStamped const* msgPtr);

void convertFromBus(geometry_msgs::Vector3* msgPtr, SL_Bus_flight_data_collection_10_Vector3_vfutmc const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Vector3_vfutmc* busPtr, geometry_msgs::Vector3 const* msgPtr);

void convertFromBus(ros::Time* msgPtr, SL_Bus_flight_data_collection_10_Time_vxijke const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Time_vxijke* busPtr, ros::Time const* msgPtr);

void convertFromBus(sensor_msgs::Imu* msgPtr, SL_Bus_flight_data_collection_10_Imu_wyoo91 const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Imu_wyoo91* busPtr, sensor_msgs::Imu const* msgPtr);

void convertFromBus(std_msgs::Float64* msgPtr, SL_Bus_flight_data_collection_10_Float64_r0lkz1 const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Float64_r0lkz1* busPtr, std_msgs::Float64 const* msgPtr);

void convertFromBus(std_msgs::Float64MultiArray* msgPtr, SL_Bus_flight_data_collection_10_Float64MultiArray_82pkib const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Float64MultiArray_82pkib* busPtr, std_msgs::Float64MultiArray const* msgPtr);

void convertFromBus(std_msgs::Header* msgPtr, SL_Bus_flight_data_collection_10_Header_qwqbiy const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_Header_qwqbiy* busPtr, std_msgs::Header const* msgPtr);

void convertFromBus(std_msgs::MultiArrayDimension* msgPtr, SL_Bus_flight_data_collection_10_MultiArrayDimension_fxqwlj const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_MultiArrayDimension_fxqwlj* busPtr, std_msgs::MultiArrayDimension const* msgPtr);

void convertFromBus(std_msgs::MultiArrayLayout* msgPtr, SL_Bus_flight_data_collection_10_MultiArrayLayout_lx552v const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_10_MultiArrayLayout_lx552v* busPtr, std_msgs::MultiArrayLayout const* msgPtr);


#endif
