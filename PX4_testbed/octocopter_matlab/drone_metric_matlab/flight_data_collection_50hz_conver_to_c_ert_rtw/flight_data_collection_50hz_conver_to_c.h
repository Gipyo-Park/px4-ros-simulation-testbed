//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// File: flight_data_collection_50hz_conver_to_c.h
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
#ifndef flight_data_collection_50hz_conver_to_c_h_
#define flight_data_collection_50hz_conver_to_c_h_
#include "rtwtypes.h"
#include "slros_initialize.h"
#include "flight_data_collection_50hz_conver_to_c_types.h"

extern "C"
{

#include "rt_nonfinite.h"

}

extern "C"
{

#include "rtGetNaN.h"

}

#include <stddef.h>

// Macros for accessing real-time model data structure
#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

#define flight_data_collection_50hz_conver_to_c_M (flight_data_collection_50hz__M)

// Class declaration for model flight_data_collection_50hz_conver_to_c
class flight_data_collection
{
  // public data and function members
 public:
  // Block signals (default storage)
  struct B_flight_data_collection_50hz_T {
    SL_Bus_flight_data_collection_50_Float64MultiArray_qu48lz BusAssignment;// '<Root>/Bus Assignment' 
    SL_Bus_flight_data_collection_50_Imu_67taaj In1;// '<S37>/In1'
    SL_Bus_flight_data_collection_50_Imu_67taaj rtb_SourceBlock_o2_mb;
    real_T A[32];
    real_T U[32];
    real_T C[32];                      // '<S5>/octo geometricCalc'
    real_T b_A[32];
    SL_Bus_flight_data_collection_50_PoseStamped_6r2eot In1_j;// '<S35>/In1'
    SL_Bus_flight_data_collection_50_PoseStamped_6r2eot rtb_SourceBlock_o2_o_c;
    SL_Bus_flight_data_collection_50_TwistStamped_696dt5 In1_p;// '<S36>/In1'
    SL_Bus_flight_data_collection_50_TwistStamped_696dt5 rtb_SourceBlock_o2_ov_k;
    real_T V[16];
    real_T Vf[16];
    real_T b_b_tmp[9];
    real_T y[8];
    real_T rtb_TmpSignalConversionAtSFun_c[8];
    real_T work[8];
    char_T b_zeroDelimTopic[38];
    real_T c_actual_force_and_moment_actin[4];
    real_T b_s[4];
    real_T e[4];
    char_T b_zeroDelimTopic_b[30];
    char_T b_zeroDelimTopic_p[28];
    SL_Bus_flight_data_collection_50_Vector3_2t2yce In1_g;// '<S38>/In1'
    SL_Bus_flight_data_collection_50_Vector3_2t2yce In1_m;// '<S34>/In1'
    SL_Bus_flight_data_collection_50_Vector3_2t2yce In1_f;// '<S33>/In1'
    SL_Bus_flight_data_collection_50_Vector3_2t2yce rtb_SourceBlock_o2_b_c;
    real_T b_b[3];
    real_T FB[3];                      // '<S5>/motorForceMomentCalc'
    real_T MB[3];                      // '<S5>/motorForceMomentCalc'
    real_T TmpSignalConversionAtSFun_i[3];// '<Root>/MATLAB Function1'
    real_T rtb_TmpSignalConversionAtSFun_f[3];
    real_T absx;
    real_T r_dot;
    real_T Product3;                   // '<S25>/Product3'
    real_T Product2;                   // '<S25>/Product2'
    real_T Product1;                   // '<S25>/Product1'
    real_T fcn5;                       // '<S7>/fcn5'
    real_T fcn3;                       // '<S7>/fcn3'
    real_T rtb_VectorConcatenate_idx_0_tmp;
    real_T rtb_VectorConcatenate_idx_0_t_g;
    real_T rtb_VectorConcatenate_idx_0__g1;
    real_T cscale;
    real_T anrm;
    real_T nrm;
    real_T rt;
    real_T r;
    real_T smm1;
    real_T emm1;
    real_T sqds;
    real_T shift;
    real_T cfromc;
    real_T ctoc;
    real_T cfrom1;
    real_T cto1;
    real_T mul;
    real_T cfromc_m;
    real_T ctoc_n;
    real_T cfrom1_p;
    real_T cto1_l;
    real_T mul_j;
    real_T roe;
    real_T absa;
    real_T absb;
    real_T scale;
    real_T scale_d;
    real_T absxk;
    real_T scale_g;
    real_T absxk_l;
    real_T temp_tmp;
    SL_Bus_flight_data_collection_50_Float64_ks6u09 In1_gs;// '<S45>/In1'
    SL_Bus_flight_data_collection_50_Float64_ks6u09 In1_i;// '<S44>/In1'
    SL_Bus_flight_data_collection_50_Float64_ks6u09 In1_d;// '<S43>/In1'
    SL_Bus_flight_data_collection_50_Float64_ks6u09 In1_j3;// '<S42>/In1'
    SL_Bus_flight_data_collection_50_Float64_ks6u09 In1_c;// '<S41>/In1'
    SL_Bus_flight_data_collection_50_Float64_ks6u09 In1_a;// '<S40>/In1'
    SL_Bus_flight_data_collection_50_Float64_ks6u09 In1_im;// '<S39>/In1'
    SL_Bus_flight_data_collection_50_Float64_ks6u09 In1_l;// '<S32>/In1'
    SL_Bus_flight_data_collection_50_Float64_ks6u09 rtb_SourceBlock_o2_a_d;
  };

  // Block states (default storage) for system '<Root>'
  struct DW_flight_data_collection_50h_T {
    ros_slroscpp_internal_block_P_T obj;// '<S6>/SinkBlock'
    ros_slroscpp_internal_block_S_T obj_g;// '<S21>/SourceBlock'
    ros_slroscpp_internal_block_S_T obj_n;// '<S20>/SourceBlock'
    ros_slroscpp_internal_block_S_T obj_ng;// '<S19>/SourceBlock'
    ros_slroscpp_internal_block_S_T obj_b;// '<S18>/SourceBlock'
    ros_slroscpp_internal_block_S_T obj_i;// '<S17>/SourceBlock'
    ros_slroscpp_internal_block_S_T obj_o;// '<S16>/SourceBlock'
    ros_slroscpp_internal_block_S_T obj_gq;// '<S15>/SourceBlock'
    ros_slroscpp_internal_block_S_T obj_h;// '<S14>/SourceBlock'
    ros_slroscpp_internal_block_S_T obj_j;// '<S13>/SourceBlock'
    ros_slroscpp_internal_block_S_T obj_k;// '<S12>/SourceBlock'
    ros_slroscpp_internal_block_S_T obj_d;// '<S11>/SourceBlock'
    ros_slroscpp_internal_block_S_T obj_e;// '<S10>/SourceBlock'
    ros_slroscpp_internal_block_S_T obj_bm;// '<S9>/SourceBlock'
    ros_slroscpp_internal_block_S_T obj_a;// '<S8>/SourceBlock'
    real_T p_prev;                     // '<Root>/MATLAB Function'
    real_T q_prev;                     // '<Root>/MATLAB Function'
    real_T r_prev;                     // '<Root>/MATLAB Function'
    boolean_T initialized_not_empty;   // '<Root>/MATLAB Function'
  };

  // Parameters (default storage)
  struct P_flight_data_collection_50hz_T {
    real_T MotorForceCalculation_Cq; // Mask Parameter: MotorForceCalculation_Cq
                                        //  Referenced by: '<S5>/Constant5'

    real_T MotorForceCalculation_Ct; // Mask Parameter: MotorForceCalculation_Ct
                                        //  Referenced by: '<S5>/Constant4'

    real_T MotorForceCalculation_L1; // Mask Parameter: MotorForceCalculation_L1
                                        //  Referenced by: '<S5>/Constant'

    real_T MotorForceCalculation_L2; // Mask Parameter: MotorForceCalculation_L2
                                        //  Referenced by: '<S5>/Constant1'

    real_T MotorForceCalculation_L3; // Mask Parameter: MotorForceCalculation_L3
                                        //  Referenced by: '<S5>/Constant2'

    SL_Bus_flight_data_collection_50_Float64MultiArray_qu48lz Constant_Value;// Computed Parameter: Constant_Value
                                                                      //  Referenced by: '<S2>/Constant'

    SL_Bus_flight_data_collection_50_Imu_67taaj Out1_Y0;// Computed Parameter: Out1_Y0
                                                           //  Referenced by: '<S37>/Out1'

    SL_Bus_flight_data_collection_50_Imu_67taaj Constant_Value_n;// Computed Parameter: Constant_Value_n
                                                                    //  Referenced by: '<S13>/Constant'

    SL_Bus_flight_data_collection_50_PoseStamped_6r2eot Out1_Y0_m;// Computed Parameter: Out1_Y0_m
                                                                     //  Referenced by: '<S35>/Out1'

    SL_Bus_flight_data_collection_50_PoseStamped_6r2eot Constant_Value_j;// Computed Parameter: Constant_Value_j
                                                                      //  Referenced by: '<S11>/Constant'

    SL_Bus_flight_data_collection_50_TwistStamped_696dt5 Out1_Y0_g;// Computed Parameter: Out1_Y0_g
                                                                      //  Referenced by: '<S36>/Out1'

    SL_Bus_flight_data_collection_50_TwistStamped_696dt5 Constant_Value_h;// Computed Parameter: Constant_Value_h
                                                                      //  Referenced by: '<S12>/Constant'

    SL_Bus_flight_data_collection_50_Vector3_2t2yce Out1_Y0_l;// Computed Parameter: Out1_Y0_l
                                                                 //  Referenced by: '<S33>/Out1'

    SL_Bus_flight_data_collection_50_Vector3_2t2yce Constant_Value_jd;// Computed Parameter: Constant_Value_jd
                                                                      //  Referenced by: '<S9>/Constant'

    SL_Bus_flight_data_collection_50_Vector3_2t2yce Out1_Y0_gv;// Computed Parameter: Out1_Y0_gv
                                                                  //  Referenced by: '<S34>/Out1'

    SL_Bus_flight_data_collection_50_Vector3_2t2yce Constant_Value_d;// Computed Parameter: Constant_Value_d
                                                                      //  Referenced by: '<S10>/Constant'

    SL_Bus_flight_data_collection_50_Vector3_2t2yce Out1_Y0_d;// Computed Parameter: Out1_Y0_d
                                                                 //  Referenced by: '<S38>/Out1'

    SL_Bus_flight_data_collection_50_Vector3_2t2yce Constant_Value_hj;// Computed Parameter: Constant_Value_hj
                                                                      //  Referenced by: '<S14>/Constant'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Out1_Y0_lp;// Computed Parameter: Out1_Y0_lp
                                                                  //  Referenced by: '<S32>/Out1'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Constant_Value_nv;// Computed Parameter: Constant_Value_nv
                                                                      //  Referenced by: '<S8>/Constant'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Out1_Y0_gi;// Computed Parameter: Out1_Y0_gi
                                                                  //  Referenced by: '<S39>/Out1'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Constant_Value_f;// Computed Parameter: Constant_Value_f
                                                                      //  Referenced by: '<S15>/Constant'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Out1_Y0_b;// Computed Parameter: Out1_Y0_b
                                                                 //  Referenced by: '<S40>/Out1'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Constant_Value_dt;// Computed Parameter: Constant_Value_dt
                                                                      //  Referenced by: '<S16>/Constant'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Out1_Y0_a;// Computed Parameter: Out1_Y0_a
                                                                 //  Referenced by: '<S41>/Out1'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Constant_Value_c;// Computed Parameter: Constant_Value_c
                                                                      //  Referenced by: '<S17>/Constant'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Out1_Y0_j;// Computed Parameter: Out1_Y0_j
                                                                 //  Referenced by: '<S42>/Out1'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Constant_Value_e;// Computed Parameter: Constant_Value_e
                                                                      //  Referenced by: '<S18>/Constant'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Out1_Y0_f;// Computed Parameter: Out1_Y0_f
                                                                 //  Referenced by: '<S43>/Out1'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Constant_Value_o;// Computed Parameter: Constant_Value_o
                                                                      //  Referenced by: '<S19>/Constant'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Out1_Y0_h;// Computed Parameter: Out1_Y0_h
                                                                 //  Referenced by: '<S44>/Out1'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Constant_Value_k;// Computed Parameter: Constant_Value_k
                                                                      //  Referenced by: '<S20>/Constant'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Out1_Y0_fy;// Computed Parameter: Out1_Y0_fy
                                                                  //  Referenced by: '<S45>/Out1'

    SL_Bus_flight_data_collection_50_Float64_ks6u09 Constant_Value_cl;// Computed Parameter: Constant_Value_cl
                                                                      //  Referenced by: '<S21>/Constant'

    real_T Constant_Value_g;           // Expression: 1
                                          //  Referenced by: '<S27>/Constant'

    real_T Constant_Value_fx;          // Expression: 1
                                          //  Referenced by: '<S28>/Constant'

    uint32_T Constant_Value_i;         // Computed Parameter: Constant_Value_i
                                          //  Referenced by: '<Root>/Constant'

  };

  // Real-time Model Data Structure
  struct RT_MODEL_flight_data_collecti_T {
    const char_T * volatile errorStatus;
  };

  // Real-Time Model get method
  flight_data_collection::RT_MODEL_flight_data_collecti_T * getRTM();

  // model initialize function
  void initialize();

  // model step function
  void step();

  // model terminate function
  void terminate();

  // Constructor
  flight_data_collection();

  // Destructor
  ~flight_data_collection();

  // private data and function members
 private:
  // Block signals
  B_flight_data_collection_50hz_T flight_data_collection_50hz_c_B;

  // Block states
  DW_flight_data_collection_50h_T flight_data_collection_50hz__DW;

  // Tunable parameters
  static P_flight_data_collection_50hz_T flight_data_collection_50hz_c_P;

  // private member function(s) for subsystem '<Root>'
  real_T flight_data_collection_xzlangeM(const real_T x[32]);
  void flight_data_collection__xzlascl(real_T cfrom, real_T cto, int32_T m,
    int32_T n, real_T A[32], int32_T iA0, int32_T lda);
  real_T flight_data_collection_50_xnrm2(int32_T n, const real_T x[32], int32_T
    ix0);
  real_T flight_data_collection_50_xdotc(int32_T n, const real_T x[32], int32_T
    ix0, const real_T y[32], int32_T iy0);
  void flight_data_collection_50_xaxpy(int32_T n, real_T a, int32_T ix0, real_T
    y[32], int32_T iy0);
  real_T flight_data_collection__xnrm2_l(int32_T n, const real_T x[4], int32_T
    ix0);
  void flight_data_collection__xaxpy_b(int32_T n, real_T a, const real_T x[32],
    int32_T ix0, real_T y[8], int32_T iy0);
  void flight_data_collection_xaxpy_bl(int32_T n, real_T a, const real_T x[8],
    int32_T ix0, real_T y[32], int32_T iy0);
  real_T flight_data_collection__xdotc_i(int32_T n, const real_T x[16], int32_T
    ix0, const real_T y[16], int32_T iy0);
  void flight_data_collectio_xaxpy_bli(int32_T n, real_T a, int32_T ix0, real_T
    y[16], int32_T iy0);
  void flight_data_collectio_xzlascl_a(real_T cfrom, real_T cto, int32_T m,
    int32_T n, real_T A[4], int32_T iA0, int32_T lda);
  void flight_data_collection_50_xswap(real_T x[16], int32_T ix0, int32_T iy0);
  void flight_data_collection__xswap_l(real_T x[32], int32_T ix0, int32_T iy0);
  void flight_data_collection_50_xrotg(real_T *a, real_T *b, real_T *c, real_T
    *s);
  void flight_data_collection_50h_xrot(real_T x[16], int32_T ix0, int32_T iy0,
    real_T c, real_T s);
  void flight_data_collection_5_xrot_a(real_T x[32], int32_T ix0, int32_T iy0,
    real_T c, real_T s);
  void flight_data_collection_50hz_svd(const real_T A[32], real_T U[32], real_T
    s[4], real_T V[16]);

  // Real-Time Model
  RT_MODEL_flight_data_collecti_T flight_data_collection_50hz__M;
};

extern volatile boolean_T stopRequested;
extern volatile boolean_T runModel;

//-
//  These blocks were eliminated from the model due to optimizations:
//
//  Block '<S1>/Unit Conversion' : Unused code path elimination


//-
//  The generated code includes comments that allow you to trace directly
//  back to the appropriate location in the model.  The basic format
//  is <system>/block_name, where system is the system number (uniquely
//  assigned by Simulink) and block_name is the name of the block.
//
//  Use the MATLAB hilite_system command to trace the generated code back
//  to the model.  For example,
//
//  hilite_system('<S3>')    - opens system 3
//  hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
//
//  Here is the system hierarchy for this model
//
//  '<Root>' : 'flight_data_collection_50hz_conver_to_c'
//  '<S1>'   : 'flight_data_collection_50hz_conver_to_c/Angular Velocity Conversion1'
//  '<S2>'   : 'flight_data_collection_50hz_conver_to_c/Blank Message'
//  '<S3>'   : 'flight_data_collection_50hz_conver_to_c/MATLAB Function'
//  '<S4>'   : 'flight_data_collection_50hz_conver_to_c/MATLAB Function1'
//  '<S5>'   : 'flight_data_collection_50hz_conver_to_c/MotorForceCalculation'
//  '<S6>'   : 'flight_data_collection_50hz_conver_to_c/Publish'
//  '<S7>'   : 'flight_data_collection_50hz_conver_to_c/Quaternions to Rotation Angles1'
//  '<S8>'   : 'flight_data_collection_50hz_conver_to_c/Subscribe'
//  '<S9>'   : 'flight_data_collection_50hz_conver_to_c/Subscribe10'
//  '<S10>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe11'
//  '<S11>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe12'
//  '<S12>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe13'
//  '<S13>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe14'
//  '<S14>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe2'
//  '<S15>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe3'
//  '<S16>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe4'
//  '<S17>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe5'
//  '<S18>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe6'
//  '<S19>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe7'
//  '<S20>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe8'
//  '<S21>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe9'
//  '<S22>'  : 'flight_data_collection_50hz_conver_to_c/MotorForceCalculation/motorForceMomentCalc'
//  '<S23>'  : 'flight_data_collection_50hz_conver_to_c/MotorForceCalculation/octo geometricCalc'
//  '<S24>'  : 'flight_data_collection_50hz_conver_to_c/Quaternions to Rotation Angles1/Angle Calculation'
//  '<S25>'  : 'flight_data_collection_50hz_conver_to_c/Quaternions to Rotation Angles1/Quaternion Normalize'
//  '<S26>'  : 'flight_data_collection_50hz_conver_to_c/Quaternions to Rotation Angles1/Angle Calculation/Protect asincos input'
//  '<S27>'  : 'flight_data_collection_50hz_conver_to_c/Quaternions to Rotation Angles1/Angle Calculation/Protect asincos input/If Action Subsystem'
//  '<S28>'  : 'flight_data_collection_50hz_conver_to_c/Quaternions to Rotation Angles1/Angle Calculation/Protect asincos input/If Action Subsystem1'
//  '<S29>'  : 'flight_data_collection_50hz_conver_to_c/Quaternions to Rotation Angles1/Angle Calculation/Protect asincos input/If Action Subsystem2'
//  '<S30>'  : 'flight_data_collection_50hz_conver_to_c/Quaternions to Rotation Angles1/Quaternion Normalize/Quaternion Modulus'
//  '<S31>'  : 'flight_data_collection_50hz_conver_to_c/Quaternions to Rotation Angles1/Quaternion Normalize/Quaternion Modulus/Quaternion Norm'
//  '<S32>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe/Enabled Subsystem'
//  '<S33>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe10/Enabled Subsystem'
//  '<S34>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe11/Enabled Subsystem'
//  '<S35>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe12/Enabled Subsystem'
//  '<S36>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe13/Enabled Subsystem'
//  '<S37>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe14/Enabled Subsystem'
//  '<S38>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe2/Enabled Subsystem'
//  '<S39>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe3/Enabled Subsystem'
//  '<S40>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe4/Enabled Subsystem'
//  '<S41>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe5/Enabled Subsystem'
//  '<S42>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe6/Enabled Subsystem'
//  '<S43>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe7/Enabled Subsystem'
//  '<S44>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe8/Enabled Subsystem'
//  '<S45>'  : 'flight_data_collection_50hz_conver_to_c/Subscribe9/Enabled Subsystem'

#endif                            // flight_data_collection_50hz_conver_to_c_h_

//
// File trailer for generated code.
//
// [EOF]
//
