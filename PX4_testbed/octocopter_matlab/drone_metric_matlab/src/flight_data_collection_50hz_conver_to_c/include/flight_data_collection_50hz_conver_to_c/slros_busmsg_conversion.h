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
#include "flight_data_collection_50hz_conver_to_c_types.h"
#include "slros_msgconvert_utils.h"


void convertFromBus(geometry_msgs::Point* msgPtr, SL_Bus_flight_data_collection_50_Point_hdvd0e const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_50_Point_hdvd0e* busPtr, geometry_msgs::Point const* msgPtr);

void convertFromBus(geometry_msgs::Pose* msgPtr, SL_Bus_flight_data_collection_50_Pose_9q50g1 const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_50_Pose_9q50g1* busPtr, geometry_msgs::Pose const* msgPtr);

void convertFromBus(geometry_msgs::PoseStamped* msgPtr, SL_Bus_flight_data_collection_50_PoseStamped_6r2eot const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_50_PoseStamped_6r2eot* busPtr, geometry_msgs::PoseStamped const* msgPtr);

void convertFromBus(geometry_msgs::Quaternion* msgPtr, SL_Bus_flight_data_collection_50_Quaternion_yfhbo const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_50_Quaternion_yfhbo* busPtr, geometry_msgs::Quaternion const* msgPtr);

void convertFromBus(geometry_msgs::Twist* msgPtr, SL_Bus_flight_data_collection_50_Twist_hbj2mf const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_50_Twist_hbj2mf* busPtr, geometry_msgs::Twist const* msgPtr);

void convertFromBus(geometry_msgs::TwistStamped* msgPtr, SL_Bus_flight_data_collection_50_TwistStamped_696dt5 const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_50_TwistStamped_696dt5* busPtr, geometry_msgs::TwistStamped const* msgPtr);

void convertFromBus(geometry_msgs::Vector3* msgPtr, SL_Bus_flight_data_collection_50_Vector3_2t2yce const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_50_Vector3_2t2yce* busPtr, geometry_msgs::Vector3 const* msgPtr);

void convertFromBus(ros::Time* msgPtr, SL_Bus_flight_data_collection_50_Time_7hrhbs const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_50_Time_7hrhbs* busPtr, ros::Time const* msgPtr);

void convertFromBus(sensor_msgs::Imu* msgPtr, SL_Bus_flight_data_collection_50_Imu_67taaj const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_50_Imu_67taaj* busPtr, sensor_msgs::Imu const* msgPtr);

void convertFromBus(std_msgs::Float64* msgPtr, SL_Bus_flight_data_collection_50_Float64_ks6u09 const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_50_Float64_ks6u09* busPtr, std_msgs::Float64 const* msgPtr);

void convertFromBus(std_msgs::Float64MultiArray* msgPtr, SL_Bus_flight_data_collection_50_Float64MultiArray_qu48lz const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_50_Float64MultiArray_qu48lz* busPtr, std_msgs::Float64MultiArray const* msgPtr);

void convertFromBus(std_msgs::Header* msgPtr, SL_Bus_flight_data_collection_50_Header_5uxkg const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_50_Header_5uxkg* busPtr, std_msgs::Header const* msgPtr);

void convertFromBus(std_msgs::MultiArrayDimension* msgPtr, SL_Bus_flight_data_collection_50_MultiArrayDimension_7sti8z const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_50_MultiArrayDimension_7sti8z* busPtr, std_msgs::MultiArrayDimension const* msgPtr);

void convertFromBus(std_msgs::MultiArrayLayout* msgPtr, SL_Bus_flight_data_collection_50_MultiArrayLayout_pc68el const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_50_MultiArrayLayout_pc68el* busPtr, std_msgs::MultiArrayLayout const* msgPtr);


#endif
