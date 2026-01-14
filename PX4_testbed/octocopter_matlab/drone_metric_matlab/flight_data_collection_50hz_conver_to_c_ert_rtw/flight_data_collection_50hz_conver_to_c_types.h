//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// File: flight_data_collection_50hz_conver_to_c_types.h
//
// Code generated for Simulink model 'flight_data_collection_50hz_conver_to_c'.
//
// Model version                  : 2.374
// Simulink Coder version         : 24.1 (R2024a) 19-Nov-2023
// C/C++ source code generated on : Thu Dec  4 16:19:23 2025
//
// Target selection: ert.tlc
// Embedded hardware selection: Generic->Unspecified (assume 32-bit Generic)
// Code generation objectives: Unspecified
// Validation result: Not run
//
#ifndef flight_data_collection_50hz_conver_to_c_types_h_
#define flight_data_collection_50hz_conver_to_c_types_h_
#include "rtwtypes.h"
#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_ROSVariableLengthArrayInfo_
#define DEFINED_TYPEDEF_FOR_SL_Bus_ROSVariableLengthArrayInfo_

struct SL_Bus_ROSVariableLengthArrayInfo
{
  uint32_T CurrentLength;
  uint32_T ReceivedLength;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_MultiArrayDimension_7sti8z_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_MultiArrayDimension_7sti8z_

// MsgType=std_msgs/MultiArrayDimension
struct SL_Bus_flight_data_collection_50_MultiArrayDimension_7sti8z
{
  // PrimitiveROSType=string:IsVarLen=1:VarLenCategory=data:VarLenElem=Label_SL_Info:TruncateAction=warn 
  uint8_T Label[128];

  // IsVarLen=1:VarLenCategory=length:VarLenElem=Label
  SL_Bus_ROSVariableLengthArrayInfo Label_SL_Info;
  uint32_T Size;
  uint32_T Stride;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_MultiArrayLayout_pc68el_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_MultiArrayLayout_pc68el_

// MsgType=std_msgs/MultiArrayLayout
struct SL_Bus_flight_data_collection_50_MultiArrayLayout_pc68el
{
  // MsgType=std_msgs/MultiArrayDimension:IsVarLen=1:VarLenCategory=data:VarLenElem=Dim_SL_Info:TruncateAction=warn 
  SL_Bus_flight_data_collection_50_MultiArrayDimension_7sti8z Dim[16];

  // IsVarLen=1:VarLenCategory=length:VarLenElem=Dim
  SL_Bus_ROSVariableLengthArrayInfo Dim_SL_Info;
  uint32_T DataOffset;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Float64MultiArray_qu48lz_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Float64MultiArray_qu48lz_

// MsgType=std_msgs/Float64MultiArray
struct SL_Bus_flight_data_collection_50_Float64MultiArray_qu48lz
{
  // MsgType=std_msgs/MultiArrayLayout
  SL_Bus_flight_data_collection_50_MultiArrayLayout_pc68el Layout;

  // IsVarLen=1:VarLenCategory=data:VarLenElem=Data_SL_Info:TruncateAction=warn
  real_T Data[30];

  // IsVarLen=1:VarLenCategory=length:VarLenElem=Data
  SL_Bus_ROSVariableLengthArrayInfo Data_SL_Info;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Float64_ks6u09_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Float64_ks6u09_

// MsgType=std_msgs/Float64
struct SL_Bus_flight_data_collection_50_Float64_ks6u09
{
  real_T Data;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Vector3_2t2yce_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Vector3_2t2yce_

// MsgType=geometry_msgs/Vector3
struct SL_Bus_flight_data_collection_50_Vector3_2t2yce
{
  real_T X;
  real_T Y;
  real_T Z;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Time_7hrhbs_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Time_7hrhbs_

// MsgType=ros_time/Time
struct SL_Bus_flight_data_collection_50_Time_7hrhbs
{
  real_T Sec;
  real_T Nsec;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Header_5uxkg_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Header_5uxkg_

// MsgType=std_msgs/Header
struct SL_Bus_flight_data_collection_50_Header_5uxkg
{
  uint32_T Seq;

  // MsgType=ros_time/Time
  SL_Bus_flight_data_collection_50_Time_7hrhbs Stamp;

  // PrimitiveROSType=string:IsVarLen=1:VarLenCategory=data:VarLenElem=FrameId_SL_Info:TruncateAction=warn 
  uint8_T FrameId[128];

  // IsVarLen=1:VarLenCategory=length:VarLenElem=FrameId
  SL_Bus_ROSVariableLengthArrayInfo FrameId_SL_Info;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Point_hdvd0e_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Point_hdvd0e_

// MsgType=geometry_msgs/Point
struct SL_Bus_flight_data_collection_50_Point_hdvd0e
{
  real_T X;
  real_T Y;
  real_T Z;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Quaternion_yfhbo_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Quaternion_yfhbo_

// MsgType=geometry_msgs/Quaternion
struct SL_Bus_flight_data_collection_50_Quaternion_yfhbo
{
  real_T X;
  real_T Y;
  real_T Z;
  real_T W;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Pose_9q50g1_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Pose_9q50g1_

// MsgType=geometry_msgs/Pose
struct SL_Bus_flight_data_collection_50_Pose_9q50g1
{
  // MsgType=geometry_msgs/Point
  SL_Bus_flight_data_collection_50_Point_hdvd0e Position;

  // MsgType=geometry_msgs/Quaternion
  SL_Bus_flight_data_collection_50_Quaternion_yfhbo Orientation;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_PoseStamped_6r2eot_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_PoseStamped_6r2eot_

// MsgType=geometry_msgs/PoseStamped
struct SL_Bus_flight_data_collection_50_PoseStamped_6r2eot
{
  // MsgType=std_msgs/Header
  SL_Bus_flight_data_collection_50_Header_5uxkg Header;

  // MsgType=geometry_msgs/Pose
  SL_Bus_flight_data_collection_50_Pose_9q50g1 Pose;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Twist_hbj2mf_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Twist_hbj2mf_

// MsgType=geometry_msgs/Twist
struct SL_Bus_flight_data_collection_50_Twist_hbj2mf
{
  // MsgType=geometry_msgs/Vector3
  SL_Bus_flight_data_collection_50_Vector3_2t2yce Linear;

  // MsgType=geometry_msgs/Vector3
  SL_Bus_flight_data_collection_50_Vector3_2t2yce Angular;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_TwistStamped_696dt5_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_TwistStamped_696dt5_

// MsgType=geometry_msgs/TwistStamped
struct SL_Bus_flight_data_collection_50_TwistStamped_696dt5
{
  // MsgType=std_msgs/Header
  SL_Bus_flight_data_collection_50_Header_5uxkg Header;

  // MsgType=geometry_msgs/Twist
  SL_Bus_flight_data_collection_50_Twist_hbj2mf Twist;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Imu_67taaj_
#define DEFINED_TYPEDEF_FOR_SL_Bus_flight_data_collection_50_Imu_67taaj_

// MsgType=sensor_msgs/Imu
struct SL_Bus_flight_data_collection_50_Imu_67taaj
{
  // MsgType=std_msgs/Header
  SL_Bus_flight_data_collection_50_Header_5uxkg Header;

  // MsgType=geometry_msgs/Quaternion
  SL_Bus_flight_data_collection_50_Quaternion_yfhbo Orientation;
  real_T OrientationCovariance[9];

  // MsgType=geometry_msgs/Vector3
  SL_Bus_flight_data_collection_50_Vector3_2t2yce AngularVelocity;
  real_T AngularVelocityCovariance[9];

  // MsgType=geometry_msgs/Vector3
  SL_Bus_flight_data_collection_50_Vector3_2t2yce LinearAcceleration;
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
#endif                      // flight_data_collection_50hz_conver_to_c_types_h_

//
// File trailer for generated code.
//
// [EOF]
//
