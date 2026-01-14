//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// File: flight_data_collection_100hz_conver_to_c_types.h
//
// Code generated for Simulink model 'flight_data_collection_100hz_conver_to_c'.
//
// Model version                  : 2.374
// Simulink Coder version         : 24.1 (R2024a) 19-Nov-2023
// C/C++ source code generated on : Thu Dec  4 16:20:05 2025
//
// Target selection: ert.tlc
// Embedded hardware selection: Generic->Unspecified (assume 32-bit Generic)
// Code generation objectives: Unspecified
// Validation result: Not run
//
#ifndef flight_data_collection_100hz_conver_to_c_types_h_
#define flight_data_collection_100hz_conver_to_c_types_h_
#include "rtwtypes.h"
#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_ROSVariableLengthArrayInfo_
#define DEFINED_TYPEDEF_FOR_SL_Bus_ROSVariableLengthArrayInfo_

struct SL_Bus_ROSVariableLengthArrayInfo
{
  uint32_T CurrentLength;
  uint32_T ReceivedLength;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_MultiArrayDimension_fxqwlj_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_MultiArrayDimension_fxqwlj_

// MsgType=std_msgs/MultiArrayDimension
struct SL_Bus_flight_data_collection_10_MultiArrayDimension_fxqwlj
{
  // PrimitiveROSType=string:IsVarLen=1:VarLenCategory=data:VarLenElem=Label_SL_Info:TruncateAction=warn 
  uint8_T Label[128];

  // IsVarLen=1:VarLenCategory=length:VarLenElem=Label
  SL_Bus_ROSVariableLengthArrayInfo Label_SL_Info;
  uint32_T Size;
  uint32_T Stride;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_MultiArrayLayout_lx552v_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_MultiArrayLayout_lx552v_

// MsgType=std_msgs/MultiArrayLayout
struct SL_Bus_flight_data_collection_10_MultiArrayLayout_lx552v
{
  // MsgType=std_msgs/MultiArrayDimension:IsVarLen=1:VarLenCategory=data:VarLenElem=Dim_SL_Info:TruncateAction=warn 
  SL_Bus_flight_data_collection_10_MultiArrayDimension_fxqwlj Dim[16];

  // IsVarLen=1:VarLenCategory=length:VarLenElem=Dim
  SL_Bus_ROSVariableLengthArrayInfo Dim_SL_Info;
  uint32_T DataOffset;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Float64MultiArray_82pkib_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Float64MultiArray_82pkib_

// MsgType=std_msgs/Float64MultiArray
struct SL_Bus_flight_data_collection_10_Float64MultiArray_82pkib
{
  // MsgType=std_msgs/MultiArrayLayout
  SL_Bus_flight_data_collection_10_MultiArrayLayout_lx552v Layout;

  // IsVarLen=1:VarLenCategory=data:VarLenElem=Data_SL_Info:TruncateAction=warn
  real_T Data[30];

  // IsVarLen=1:VarLenCategory=length:VarLenElem=Data
  SL_Bus_ROSVariableLengthArrayInfo Data_SL_Info;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Float64_r0lkz1_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Float64_r0lkz1_

// MsgType=std_msgs/Float64
struct SL_Bus_flight_data_collection_10_Float64_r0lkz1
{
  real_T Data;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Vector3_vfutmc_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Vector3_vfutmc_

// MsgType=geometry_msgs/Vector3
struct SL_Bus_flight_data_collection_10_Vector3_vfutmc
{
  real_T X;
  real_T Y;
  real_T Z;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Time_vxijke_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Time_vxijke_

// MsgType=ros_time/Time
struct SL_Bus_flight_data_collection_10_Time_vxijke
{
  real_T Sec;
  real_T Nsec;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Header_qwqbiy_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Header_qwqbiy_

// MsgType=std_msgs/Header
struct SL_Bus_flight_data_collection_10_Header_qwqbiy
{
  uint32_T Seq;

  // MsgType=ros_time/Time
  SL_Bus_flight_data_collection_10_Time_vxijke Stamp;

  // PrimitiveROSType=string:IsVarLen=1:VarLenCategory=data:VarLenElem=FrameId_SL_Info:TruncateAction=warn 
  uint8_T FrameId[128];

  // IsVarLen=1:VarLenCategory=length:VarLenElem=FrameId
  SL_Bus_ROSVariableLengthArrayInfo FrameId_SL_Info;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Point_r08zbg_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Point_r08zbg_

// MsgType=geometry_msgs/Point
struct SL_Bus_flight_data_collection_10_Point_r08zbg
{
  real_T X;
  real_T Y;
  real_T Z;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Quaternion_ez0huq_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Quaternion_ez0huq_

// MsgType=geometry_msgs/Quaternion
struct SL_Bus_flight_data_collection_10_Quaternion_ez0huq
{
  real_T X;
  real_T Y;
  real_T Z;
  real_T W;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Pose_v7gmqz_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Pose_v7gmqz_

// MsgType=geometry_msgs/Pose
struct SL_Bus_flight_data_collection_10_Pose_v7gmqz
{
  // MsgType=geometry_msgs/Point
  SL_Bus_flight_data_collection_10_Point_r08zbg Position;

  // MsgType=geometry_msgs/Quaternion
  SL_Bus_flight_data_collection_10_Quaternion_ez0huq Orientation;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_PoseStamped_a63i0j_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_PoseStamped_a63i0j_

// MsgType=geometry_msgs/PoseStamped
struct SL_Bus_flight_data_collection_10_PoseStamped_a63i0j
{
  // MsgType=std_msgs/Header
  SL_Bus_flight_data_collection_10_Header_qwqbiy Header;

  // MsgType=geometry_msgs/Pose
  SL_Bus_flight_data_collection_10_Pose_v7gmqz Pose;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Twist_r2l9pf_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Twist_r2l9pf_

// MsgType=geometry_msgs/Twist
struct SL_Bus_flight_data_collection_10_Twist_r2l9pf
{
  // MsgType=geometry_msgs/Vector3
  SL_Bus_flight_data_collection_10_Vector3_vfutmc Linear;

  // MsgType=geometry_msgs/Vector3
  SL_Bus_flight_data_collection_10_Vector3_vfutmc Angular;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_TwistStamped_snnfb5_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_TwistStamped_snnfb5_

// MsgType=geometry_msgs/TwistStamped
struct SL_Bus_flight_data_collection_10_TwistStamped_snnfb5
{
  // MsgType=std_msgs/Header
  SL_Bus_flight_data_collection_10_Header_qwqbiy Header;

  // MsgType=geometry_msgs/Twist
  SL_Bus_flight_data_collection_10_Twist_r2l9pf Twist;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Imu_wyoo91_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_10_Imu_wyoo91_

// MsgType=sensor_msgs/Imu
struct SL_Bus_flight_data_collection_10_Imu_wyoo91
{
  // MsgType=std_msgs/Header
  SL_Bus_flight_data_collection_10_Header_qwqbiy Header;

  // MsgType=geometry_msgs/Quaternion
  SL_Bus_flight_data_collection_10_Quaternion_ez0huq Orientation;
  real_T OrientationCovariance[9];

  // MsgType=geometry_msgs/Vector3
  SL_Bus_flight_data_collection_10_Vector3_vfutmc AngularVelocity;
  real_T AngularVelocityCovariance[9];

  // MsgType=geometry_msgs/Vector3
  SL_Bus_flight_data_collection_10_Vector3_vfutmc LinearAcceleration;
  real_T LinearAccelerationCovariance[9];
};

#endif

#ifndef struct_ros_slroscpp_internal_block_P_T
#define struct_ros_slroscpp_internal_block_P_T

struct ros_slroscpp_internal_block_P_T
{
  boolean_T matlabCodegenIsDeleted;
  int32_T isInitialized;
  boolean_T isSetupComplete;
};

#endif                                // struct_ros_slroscpp_internal_block_P_T

#ifndef struct_ros_slroscpp_internal_block_S_T
#define struct_ros_slroscpp_internal_block_S_T

struct ros_slroscpp_internal_block_S_T
{
  boolean_T matlabCodegenIsDeleted;
  int32_T isInitialized;
  boolean_T isSetupComplete;
};

#endif                                // struct_ros_slroscpp_internal_block_S_T
#endif                     // flight_data_collection_100hz_conver_to_c_types_h_

//
// File trailer for generated code.
//
// [EOF]
//
