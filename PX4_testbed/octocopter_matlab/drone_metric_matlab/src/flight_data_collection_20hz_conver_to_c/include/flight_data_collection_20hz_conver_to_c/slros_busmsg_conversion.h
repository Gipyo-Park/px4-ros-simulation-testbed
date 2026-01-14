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
#include "flight_data_collection_20hz_conver_to_c_types.h"
#include "slros_msgconvert_utils.h"


void convertFromBus(geometry_msgs::Point* msgPtr, SL_Bus_flight_data_collection_20_Point_rwvn0l const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_20_Point_rwvn0l* busPtr, geometry_msgs::Point const* msgPtr);

void convertFromBus(geometry_msgs::Pose* msgPtr, SL_Bus_flight_data_collection_20_Pose_oay37o const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_20_Pose_oay37o* busPtr, geometry_msgs::Pose const* msgPtr);

void convertFromBus(geometry_msgs::PoseStamped* msgPtr, SL_Bus_flight_data_collection_20_PoseStamped_cwoda2 const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_20_PoseStamped_cwoda2* busPtr, geometry_msgs::PoseStamped const* msgPtr);

void convertFromBus(geometry_msgs::Quaternion* msgPtr, SL_Bus_flight_data_collection_20_Quaternion_o1s7t5 const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_20_Quaternion_o1s7t5* busPtr, geometry_msgs::Quaternion const* msgPtr);

void convertFromBus(geometry_msgs::Twist* msgPtr, SL_Bus_flight_data_collection_20_Twist_rz7xek const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_20_Twist_rz7xek* busPtr, geometry_msgs::Twist const* msgPtr);

void convertFromBus(geometry_msgs::TwistStamped* msgPtr, SL_Bus_flight_data_collection_20_TwistStamped_silrfq const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_20_TwistStamped_silrfq* busPtr, geometry_msgs::TwistStamped const* msgPtr);

void convertFromBus(geometry_msgs::Vector3* msgPtr, SL_Bus_flight_data_collection_20_Vector3_cscv97 const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_20_Vector3_cscv97* busPtr, geometry_msgs::Vector3 const* msgPtr);

void convertFromBus(ros::Time* msgPtr, SL_Bus_flight_data_collection_20_Time_81z42d const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_20_Time_81z42d* busPtr, ros::Time const* msgPtr);

void convertFromBus(sensor_msgs::Imu* msgPtr, SL_Bus_flight_data_collection_20_Imu_ywzqgu const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_20_Imu_ywzqgu* busPtr, sensor_msgs::Imu const* msgPtr);

void convertFromBus(std_msgs::Float64* msgPtr, SL_Bus_flight_data_collection_20_Float64_gj0fpw const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_20_Float64_gj0fpw* busPtr, std_msgs::Float64 const* msgPtr);

void convertFromBus(std_msgs::Float64MultiArray* msgPtr, SL_Bus_flight_data_collection_20_Float64MultiArray_lxkfqk const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_20_Float64MultiArray_lxkfqk* busPtr, std_msgs::Float64MultiArray const* msgPtr);

void convertFromBus(std_msgs::Header* msgPtr, SL_Bus_flight_data_collection_20_Header_sv1dqr const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_20_Header_sv1dqr* busPtr, std_msgs::Header const* msgPtr);

void convertFromBus(std_msgs::MultiArrayDimension* msgPtr, SL_Bus_flight_data_collection_20_MultiArrayDimension_l5frj4 const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_20_MultiArrayDimension_l5frj4* busPtr, std_msgs::MultiArrayDimension const* msgPtr);

void convertFromBus(std_msgs::MultiArrayLayout* msgPtr, SL_Bus_flight_data_collection_20_MultiArrayLayout_j6k9tc const* busPtr);
void convertToBus(SL_Bus_flight_data_collection_20_MultiArrayLayout_j6k9tc* busPtr, std_msgs::MultiArrayLayout const* msgPtr);


#endif
