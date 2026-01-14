//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// File: flight_data_collection_100hz_conver_to_c.cpp
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
#include "flight_data_collection_100hz_conver_to_c.h"
#include "rtwtypes.h"
#include <math.h>

extern "C"
{

#include "rt_nonfinite.h"

}

#include "flight_data_collection_100hz_conver_to_c_private.h"
#include <string.h>
#include "rt_defines.h"

// Function for MATLAB Function: '<S5>/octo geometricCalc'
real_T flight_data_collection::flight_data_collection_xzlangeM(const real_T x[32])
{
  real_T y;
  int32_T k;
  boolean_T exitg1;
  y = 0.0;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 32)) {
    real_T absxk;
    absxk = fabs(x[k]);
    if (rtIsNaN(absxk)) {
      y = (rtNaN);
      exitg1 = true;
    } else {
      if (absxk > y) {
        y = absxk;
      }

      k++;
    }
  }

  return y;
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
void flight_data_collection::flight_data_collection__xzlascl(real_T cfrom,
  real_T cto, int32_T m, int32_T n, real_T A[32], int32_T iA0, int32_T lda)
{
  boolean_T notdone;
  flight_data_collection_100hz__B.cfromc_m = cfrom;
  flight_data_collection_100hz__B.ctoc_n = cto;
  notdone = true;
  while (notdone) {
    flight_data_collection_100hz__B.cfrom1_p =
      flight_data_collection_100hz__B.cfromc_m * 2.0041683600089728E-292;
    flight_data_collection_100hz__B.cto1_l =
      flight_data_collection_100hz__B.ctoc_n / 4.9896007738368E+291;
    if ((fabs(flight_data_collection_100hz__B.cfrom1_p) > fabs
         (flight_data_collection_100hz__B.ctoc_n)) &&
        (flight_data_collection_100hz__B.ctoc_n != 0.0)) {
      flight_data_collection_100hz__B.mul_j = 2.0041683600089728E-292;
      flight_data_collection_100hz__B.cfromc_m =
        flight_data_collection_100hz__B.cfrom1_p;
    } else if (fabs(flight_data_collection_100hz__B.cto1_l) > fabs
               (flight_data_collection_100hz__B.cfromc_m)) {
      flight_data_collection_100hz__B.mul_j = 4.9896007738368E+291;
      flight_data_collection_100hz__B.ctoc_n =
        flight_data_collection_100hz__B.cto1_l;
    } else {
      flight_data_collection_100hz__B.mul_j =
        flight_data_collection_100hz__B.ctoc_n /
        flight_data_collection_100hz__B.cfromc_m;
      notdone = false;
    }

    for (int32_T j = 0; j < n; j++) {
      int32_T offset;
      offset = (j * lda + iA0) - 2;
      for (int32_T b_i = 0; b_i < m; b_i++) {
        int32_T tmp;
        tmp = (b_i + offset) + 1;
        A[tmp] *= flight_data_collection_100hz__B.mul_j;
      }
    }
  }
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
real_T flight_data_collection::flight_data_collection_10_xnrm2(int32_T n, const
  real_T x[32], int32_T ix0)
{
  real_T y;
  y = 0.0;
  if (n >= 1) {
    if (n == 1) {
      y = fabs(x[ix0 - 1]);
    } else {
      int32_T kend;
      flight_data_collection_100hz__B.scale_g = 3.3121686421112381E-170;
      kend = (ix0 + n) - 1;
      for (int32_T k = ix0; k <= kend; k++) {
        flight_data_collection_100hz__B.absxk_l = fabs(x[k - 1]);
        if (flight_data_collection_100hz__B.absxk_l >
            flight_data_collection_100hz__B.scale_g) {
          real_T t;
          t = flight_data_collection_100hz__B.scale_g /
            flight_data_collection_100hz__B.absxk_l;
          y = y * t * t + 1.0;
          flight_data_collection_100hz__B.scale_g =
            flight_data_collection_100hz__B.absxk_l;
        } else {
          real_T t;
          t = flight_data_collection_100hz__B.absxk_l /
            flight_data_collection_100hz__B.scale_g;
          y += t * t;
        }
      }

      y = flight_data_collection_100hz__B.scale_g * sqrt(y);
    }
  }

  return y;
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
real_T flight_data_collection::flight_data_collection_10_xdotc(int32_T n, const
  real_T x[32], int32_T ix0, const real_T y[32], int32_T iy0)
{
  real_T d;
  d = 0.0;
  if (n >= 1) {
    for (int32_T k = 0; k < n; k++) {
      d += x[(ix0 + k) - 1] * y[(iy0 + k) - 1];
    }
  }

  return d;
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
void flight_data_collection::flight_data_collection_10_xaxpy(int32_T n, real_T a,
  int32_T ix0, real_T y[32], int32_T iy0)
{
  if ((n >= 1) && (!(a == 0.0))) {
    for (int32_T k = 0; k < n; k++) {
      int32_T tmp;
      tmp = (iy0 + k) - 1;
      y[tmp] += y[(ix0 + k) - 1] * a;
    }
  }
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
real_T flight_data_collection::flight_data_collection__xnrm2_l(int32_T n, const
  real_T x[4], int32_T ix0)
{
  real_T y;
  y = 0.0;
  if (n >= 1) {
    if (n == 1) {
      y = fabs(x[ix0 - 1]);
    } else {
      int32_T kend;
      flight_data_collection_100hz__B.scale_d = 3.3121686421112381E-170;
      kend = (ix0 + n) - 1;
      for (int32_T k = ix0; k <= kend; k++) {
        flight_data_collection_100hz__B.absxk = fabs(x[k - 1]);
        if (flight_data_collection_100hz__B.absxk >
            flight_data_collection_100hz__B.scale_d) {
          real_T t;
          t = flight_data_collection_100hz__B.scale_d /
            flight_data_collection_100hz__B.absxk;
          y = y * t * t + 1.0;
          flight_data_collection_100hz__B.scale_d =
            flight_data_collection_100hz__B.absxk;
        } else {
          real_T t;
          t = flight_data_collection_100hz__B.absxk /
            flight_data_collection_100hz__B.scale_d;
          y += t * t;
        }
      }

      y = flight_data_collection_100hz__B.scale_d * sqrt(y);
    }
  }

  return y;
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
void flight_data_collection::flight_data_collection__xaxpy_b(int32_T n, real_T a,
  const real_T x[32], int32_T ix0, real_T y[8], int32_T iy0)
{
  if ((n >= 1) && (!(a == 0.0))) {
    for (int32_T k = 0; k < n; k++) {
      int32_T tmp;
      tmp = (iy0 + k) - 1;
      y[tmp] += x[(ix0 + k) - 1] * a;
    }
  }
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
void flight_data_collection::flight_data_collection_xaxpy_bl(int32_T n, real_T a,
  const real_T x[8], int32_T ix0, real_T y[32], int32_T iy0)
{
  if ((n >= 1) && (!(a == 0.0))) {
    for (int32_T k = 0; k < n; k++) {
      int32_T tmp;
      tmp = (iy0 + k) - 1;
      y[tmp] += x[(ix0 + k) - 1] * a;
    }
  }
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
real_T flight_data_collection::flight_data_collection__xdotc_i(int32_T n, const
  real_T x[16], int32_T ix0, const real_T y[16], int32_T iy0)
{
  real_T d;
  d = 0.0;
  if (n >= 1) {
    for (int32_T k = 0; k < n; k++) {
      d += x[(ix0 + k) - 1] * y[(iy0 + k) - 1];
    }
  }

  return d;
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
void flight_data_collection::flight_data_collectio_xaxpy_bli(int32_T n, real_T a,
  int32_T ix0, real_T y[16], int32_T iy0)
{
  if ((n >= 1) && (!(a == 0.0))) {
    for (int32_T k = 0; k < n; k++) {
      int32_T tmp;
      tmp = (iy0 + k) - 1;
      y[tmp] += y[(ix0 + k) - 1] * a;
    }
  }
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
void flight_data_collection::flight_data_collectio_xzlascl_a(real_T cfrom,
  real_T cto, int32_T m, int32_T n, real_T A[4], int32_T iA0, int32_T lda)
{
  boolean_T notdone;
  flight_data_collection_100hz__B.cfromc = cfrom;
  flight_data_collection_100hz__B.ctoc = cto;
  notdone = true;
  while (notdone) {
    flight_data_collection_100hz__B.cfrom1 =
      flight_data_collection_100hz__B.cfromc * 2.0041683600089728E-292;
    flight_data_collection_100hz__B.cto1 = flight_data_collection_100hz__B.ctoc /
      4.9896007738368E+291;
    if ((fabs(flight_data_collection_100hz__B.cfrom1) > fabs
         (flight_data_collection_100hz__B.ctoc)) &&
        (flight_data_collection_100hz__B.ctoc != 0.0)) {
      flight_data_collection_100hz__B.mul = 2.0041683600089728E-292;
      flight_data_collection_100hz__B.cfromc =
        flight_data_collection_100hz__B.cfrom1;
    } else if (fabs(flight_data_collection_100hz__B.cto1) > fabs
               (flight_data_collection_100hz__B.cfromc)) {
      flight_data_collection_100hz__B.mul = 4.9896007738368E+291;
      flight_data_collection_100hz__B.ctoc =
        flight_data_collection_100hz__B.cto1;
    } else {
      flight_data_collection_100hz__B.mul = flight_data_collection_100hz__B.ctoc
        / flight_data_collection_100hz__B.cfromc;
      notdone = false;
    }

    for (int32_T j = 0; j < n; j++) {
      int32_T offset;
      offset = (j * lda + iA0) - 2;
      for (int32_T b_i = 0; b_i < m; b_i++) {
        int32_T tmp;
        tmp = (b_i + offset) + 1;
        A[tmp] *= flight_data_collection_100hz__B.mul;
      }
    }
  }
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
void flight_data_collection::flight_data_collection_10_xswap(real_T x[16],
  int32_T ix0, int32_T iy0)
{
  real_T temp;
  temp = x[ix0 - 1];
  x[ix0 - 1] = x[iy0 - 1];
  x[iy0 - 1] = temp;
  temp = x[ix0];
  x[ix0] = x[iy0];
  x[iy0] = temp;
  temp = x[ix0 + 1];
  x[ix0 + 1] = x[iy0 + 1];
  x[iy0 + 1] = temp;
  temp = x[ix0 + 2];
  x[ix0 + 2] = x[iy0 + 2];
  x[iy0 + 2] = temp;
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
void flight_data_collection::flight_data_collection__xswap_l(real_T x[32],
  int32_T ix0, int32_T iy0)
{
  for (int32_T k = 0; k < 8; k++) {
    real_T temp;
    int32_T temp_tmp;
    int32_T tmp;
    temp_tmp = (ix0 + k) - 1;
    temp = x[temp_tmp];
    tmp = (iy0 + k) - 1;
    x[temp_tmp] = x[tmp];
    x[tmp] = temp;
  }
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
void flight_data_collection::flight_data_collection_10_xrotg(real_T *a, real_T
  *b, real_T *c, real_T *s)
{
  flight_data_collection_100hz__B.roe = *b;
  flight_data_collection_100hz__B.absa = fabs(*a);
  flight_data_collection_100hz__B.absb = fabs(*b);
  if (flight_data_collection_100hz__B.absa >
      flight_data_collection_100hz__B.absb) {
    flight_data_collection_100hz__B.roe = *a;
  }

  flight_data_collection_100hz__B.scale = flight_data_collection_100hz__B.absa +
    flight_data_collection_100hz__B.absb;
  if (flight_data_collection_100hz__B.scale == 0.0) {
    *s = 0.0;
    *c = 1.0;
    *a = 0.0;
    *b = 0.0;
  } else {
    real_T ads;
    real_T bds;
    ads = flight_data_collection_100hz__B.absa /
      flight_data_collection_100hz__B.scale;
    bds = flight_data_collection_100hz__B.absb /
      flight_data_collection_100hz__B.scale;
    flight_data_collection_100hz__B.scale *= sqrt(ads * ads + bds * bds);
    if (flight_data_collection_100hz__B.roe < 0.0) {
      flight_data_collection_100hz__B.scale =
        -flight_data_collection_100hz__B.scale;
    }

    *c = *a / flight_data_collection_100hz__B.scale;
    *s = *b / flight_data_collection_100hz__B.scale;
    if (flight_data_collection_100hz__B.absa >
        flight_data_collection_100hz__B.absb) {
      *b = *s;
    } else if (*c != 0.0) {
      *b = 1.0 / *c;
    } else {
      *b = 1.0;
    }

    *a = flight_data_collection_100hz__B.scale;
  }
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
void flight_data_collection::flight_data_collection_100_xrot(real_T x[16],
  int32_T ix0, int32_T iy0, real_T c, real_T s)
{
  real_T temp;
  real_T temp_tmp;
  temp = x[iy0 - 1];
  temp_tmp = x[ix0 - 1];
  x[iy0 - 1] = temp * c - temp_tmp * s;
  x[ix0 - 1] = temp_tmp * c + temp * s;
  temp = x[ix0] * c + x[iy0] * s;
  x[iy0] = x[iy0] * c - x[ix0] * s;
  x[ix0] = temp;
  temp = x[iy0 + 1];
  temp_tmp = x[ix0 + 1];
  x[iy0 + 1] = temp * c - temp_tmp * s;
  x[ix0 + 1] = temp_tmp * c + temp * s;
  temp = x[iy0 + 2];
  temp_tmp = x[ix0 + 2];
  x[iy0 + 2] = temp * c - temp_tmp * s;
  x[ix0 + 2] = temp_tmp * c + temp * s;
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
void flight_data_collection::flight_data_collection_1_xrot_a(real_T x[32],
  int32_T ix0, int32_T iy0, real_T c, real_T s)
{
  for (int32_T k = 0; k < 8; k++) {
    real_T temp_tmp;
    int32_T temp_tmp_tmp;
    int32_T temp_tmp_tmp_0;
    temp_tmp_tmp = (iy0 + k) - 1;
    flight_data_collection_100hz__B.temp_tmp = x[temp_tmp_tmp];
    temp_tmp_tmp_0 = (ix0 + k) - 1;
    temp_tmp = x[temp_tmp_tmp_0];
    x[temp_tmp_tmp] = flight_data_collection_100hz__B.temp_tmp * c - temp_tmp *
      s;
    x[temp_tmp_tmp_0] = temp_tmp * c + flight_data_collection_100hz__B.temp_tmp *
      s;
  }
}

// Function for MATLAB Function: '<S5>/octo geometricCalc'
void flight_data_collection::flight_data_collection_100h_svd(const real_T A[32],
  real_T U[32], real_T s[4], real_T V[16])
{
  int32_T e_k;
  int32_T i;
  int32_T qjj;
  int32_T qp1;
  int32_T qp1jj;
  int32_T qp1q;
  int32_T qq;
  boolean_T apply_transform;
  boolean_T doscale;
  boolean_T exitg1;
  memcpy(&flight_data_collection_100hz__B.b_A[0], &A[0], sizeof(real_T) << 5U);
  flight_data_collection_100hz__B.b_s[0] = 0.0;
  flight_data_collection_100hz__B.e[0] = 0.0;
  flight_data_collection_100hz__B.b_s[1] = 0.0;
  flight_data_collection_100hz__B.e[1] = 0.0;
  flight_data_collection_100hz__B.b_s[2] = 0.0;
  flight_data_collection_100hz__B.e[2] = 0.0;
  flight_data_collection_100hz__B.b_s[3] = 0.0;
  flight_data_collection_100hz__B.e[3] = 0.0;
  memset(&flight_data_collection_100hz__B.work[0], 0, sizeof(real_T) << 3U);
  memset(&U[0], 0, sizeof(real_T) << 5U);
  memset(&flight_data_collection_100hz__B.Vf[0], 0, sizeof(real_T) << 4U);
  doscale = false;
  flight_data_collection_100hz__B.anrm = flight_data_collection_xzlangeM(A);
  flight_data_collection_100hz__B.cscale = flight_data_collection_100hz__B.anrm;
  if ((flight_data_collection_100hz__B.anrm > 0.0) &&
      (flight_data_collection_100hz__B.anrm < 6.7178761075670888E-139)) {
    doscale = true;
    flight_data_collection_100hz__B.cscale = 6.7178761075670888E-139;
    flight_data_collection__xzlascl(flight_data_collection_100hz__B.anrm,
      flight_data_collection_100hz__B.cscale, 8, 4,
      flight_data_collection_100hz__B.b_A, 1, 8);
  } else if (flight_data_collection_100hz__B.anrm > 1.4885657073574029E+138) {
    doscale = true;
    flight_data_collection_100hz__B.cscale = 1.4885657073574029E+138;
    flight_data_collection__xzlascl(flight_data_collection_100hz__B.anrm,
      flight_data_collection_100hz__B.cscale, 8, 4,
      flight_data_collection_100hz__B.b_A, 1, 8);
  }

  for (i = 0; i < 4; i++) {
    qp1 = i + 2;
    qp1jj = i << 3;
    qp1q = qp1jj + i;
    qq = qp1q + 1;
    apply_transform = false;
    flight_data_collection_100hz__B.nrm = flight_data_collection_10_xnrm2(8 - i,
      flight_data_collection_100hz__B.b_A, qp1q + 1);
    if (flight_data_collection_100hz__B.nrm > 0.0) {
      apply_transform = true;
      if (flight_data_collection_100hz__B.b_A[qp1q] < 0.0) {
        flight_data_collection_100hz__B.nrm =
          -flight_data_collection_100hz__B.nrm;
      }

      flight_data_collection_100hz__B.b_s[i] =
        flight_data_collection_100hz__B.nrm;
      if (fabs(flight_data_collection_100hz__B.nrm) >= 1.0020841800044864E-292)
      {
        flight_data_collection_100hz__B.nrm = 1.0 /
          flight_data_collection_100hz__B.nrm;
        qjj = (qp1q - i) + 8;
        for (e_k = qq; e_k <= qjj; e_k++) {
          flight_data_collection_100hz__B.b_A[e_k - 1] *=
            flight_data_collection_100hz__B.nrm;
        }
      } else {
        qjj = (qp1q - i) + 8;
        for (e_k = qq; e_k <= qjj; e_k++) {
          flight_data_collection_100hz__B.b_A[e_k - 1] /=
            flight_data_collection_100hz__B.b_s[i];
        }
      }

      flight_data_collection_100hz__B.b_A[qp1q]++;
      flight_data_collection_100hz__B.b_s[i] =
        -flight_data_collection_100hz__B.b_s[i];
    } else {
      flight_data_collection_100hz__B.b_s[i] = 0.0;
    }

    for (qq = qp1; qq < 5; qq++) {
      qjj = ((qq - 1) << 3) + i;
      if (apply_transform) {
        flight_data_collection_10_xaxpy(8 - i, -(flight_data_collection_10_xdotc
          (8 - i, flight_data_collection_100hz__B.b_A, qp1q + 1,
           flight_data_collection_100hz__B.b_A, qjj + 1) /
          flight_data_collection_100hz__B.b_A[qp1q]), qp1q + 1,
          flight_data_collection_100hz__B.b_A, qjj + 1);
      }

      flight_data_collection_100hz__B.e[qq - 1] =
        flight_data_collection_100hz__B.b_A[qjj];
    }

    for (qp1q = i + 1; qp1q < 9; qp1q++) {
      qjj = (qp1jj + qp1q) - 1;
      U[qjj] = flight_data_collection_100hz__B.b_A[qjj];
    }

    if (i + 1 <= 2) {
      flight_data_collection_100hz__B.nrm = flight_data_collection__xnrm2_l(3 -
        i, flight_data_collection_100hz__B.e, i + 2);
      if (flight_data_collection_100hz__B.nrm == 0.0) {
        flight_data_collection_100hz__B.e[i] = 0.0;
      } else {
        if (flight_data_collection_100hz__B.e[i + 1] < 0.0) {
          flight_data_collection_100hz__B.e[i] =
            -flight_data_collection_100hz__B.nrm;
        } else {
          flight_data_collection_100hz__B.e[i] =
            flight_data_collection_100hz__B.nrm;
        }

        flight_data_collection_100hz__B.nrm =
          flight_data_collection_100hz__B.e[i];
        if (fabs(flight_data_collection_100hz__B.e[i]) >=
            1.0020841800044864E-292) {
          flight_data_collection_100hz__B.nrm = 1.0 /
            flight_data_collection_100hz__B.e[i];
          for (qp1q = qp1; qp1q < 5; qp1q++) {
            flight_data_collection_100hz__B.e[qp1q - 1] *=
              flight_data_collection_100hz__B.nrm;
          }
        } else {
          for (qp1q = qp1; qp1q < 5; qp1q++) {
            flight_data_collection_100hz__B.e[qp1q - 1] /=
              flight_data_collection_100hz__B.nrm;
          }
        }

        flight_data_collection_100hz__B.e[i + 1]++;
        flight_data_collection_100hz__B.e[i] =
          -flight_data_collection_100hz__B.e[i];
        for (qp1q = qp1; qp1q < 9; qp1q++) {
          flight_data_collection_100hz__B.work[qp1q - 1] = 0.0;
        }

        for (qp1q = qp1; qp1q < 5; qp1q++) {
          flight_data_collection__xaxpy_b(7 - i,
            flight_data_collection_100hz__B.e[qp1q - 1],
            flight_data_collection_100hz__B.b_A, (i + ((qp1q - 1) << 3)) + 2,
            flight_data_collection_100hz__B.work, i + 2);
        }

        for (qp1q = qp1; qp1q < 5; qp1q++) {
          flight_data_collection_xaxpy_bl(7 - i,
            -flight_data_collection_100hz__B.e[qp1q - 1] /
            flight_data_collection_100hz__B.e[i + 1],
            flight_data_collection_100hz__B.work, i + 2,
            flight_data_collection_100hz__B.b_A, (i + ((qp1q - 1) << 3)) + 2);
        }
      }

      for (qp1q = qp1; qp1q < 5; qp1q++) {
        flight_data_collection_100hz__B.Vf[(qp1q + (i << 2)) - 1] =
          flight_data_collection_100hz__B.e[qp1q - 1];
      }
    }
  }

  i = 2;
  flight_data_collection_100hz__B.e[2] = flight_data_collection_100hz__B.b_A[26];
  flight_data_collection_100hz__B.e[3] = 0.0;
  for (qp1 = 3; qp1 >= 0; qp1--) {
    qp1q = qp1 << 3;
    qq = qp1q + qp1;
    if (flight_data_collection_100hz__B.b_s[qp1] != 0.0) {
      for (qp1jj = qp1 + 2; qp1jj < 5; qp1jj++) {
        qjj = (((qp1jj - 1) << 3) + qp1) + 1;
        flight_data_collection_10_xaxpy(8 - qp1,
          -(flight_data_collection_10_xdotc(8 - qp1, U, qq + 1, U, qjj) / U[qq]),
          qq + 1, U, qjj);
      }

      for (qp1jj = qp1 + 1; qp1jj < 9; qp1jj++) {
        qjj = (qp1q + qp1jj) - 1;
        U[qjj] = -U[qjj];
      }

      U[qq]++;
      for (qq = 0; qq < qp1; qq++) {
        U[qq + qp1q] = 0.0;
      }
    } else {
      memset(&U[qp1q], 0, sizeof(real_T) << 3U);
      U[qq] = 1.0;
    }
  }

  for (qp1 = 3; qp1 >= 0; qp1--) {
    if ((qp1 + 1 <= 2) && (flight_data_collection_100hz__B.e[qp1] != 0.0)) {
      qp1q = ((qp1 << 2) + qp1) + 2;
      for (qq = qp1 + 2; qq < 5; qq++) {
        qp1jj = (((qq - 1) << 2) + qp1) + 2;
        flight_data_collectio_xaxpy_bli(3 - qp1,
          -(flight_data_collection__xdotc_i(3 - qp1,
          flight_data_collection_100hz__B.Vf, qp1q,
          flight_data_collection_100hz__B.Vf, qp1jj) /
            flight_data_collection_100hz__B.Vf[qp1q - 1]), qp1q,
          flight_data_collection_100hz__B.Vf, qp1jj);
      }
    }

    qp1q = qp1 << 2;
    flight_data_collection_100hz__B.Vf[qp1q] = 0.0;
    flight_data_collection_100hz__B.Vf[qp1q + 1] = 0.0;
    flight_data_collection_100hz__B.Vf[qp1q + 2] = 0.0;
    flight_data_collection_100hz__B.Vf[qp1q + 3] = 0.0;
    flight_data_collection_100hz__B.Vf[qp1 + qp1q] = 1.0;
  }

  qp1 = 0;
  flight_data_collection_100hz__B.nrm = 0.0;
  for (qp1q = 0; qp1q < 4; qp1q++) {
    flight_data_collection_100hz__B.r = flight_data_collection_100hz__B.b_s[qp1q];
    if (flight_data_collection_100hz__B.r != 0.0) {
      flight_data_collection_100hz__B.rt = fabs
        (flight_data_collection_100hz__B.r);
      flight_data_collection_100hz__B.r /= flight_data_collection_100hz__B.rt;
      flight_data_collection_100hz__B.b_s[qp1q] =
        flight_data_collection_100hz__B.rt;
      if (qp1q + 1 < 4) {
        flight_data_collection_100hz__B.e[qp1q] /=
          flight_data_collection_100hz__B.r;
      }

      qq = (qp1q << 3) + 1;
      for (qp1jj = qq; qp1jj <= qq + 7; qp1jj++) {
        U[qp1jj - 1] *= flight_data_collection_100hz__B.r;
      }
    }

    if (qp1q + 1 < 4) {
      flight_data_collection_100hz__B.r = flight_data_collection_100hz__B.e[qp1q];
      if (flight_data_collection_100hz__B.r != 0.0) {
        flight_data_collection_100hz__B.rt = fabs
          (flight_data_collection_100hz__B.r);
        flight_data_collection_100hz__B.r = flight_data_collection_100hz__B.rt /
          flight_data_collection_100hz__B.r;
        flight_data_collection_100hz__B.e[qp1q] =
          flight_data_collection_100hz__B.rt;
        flight_data_collection_100hz__B.b_s[qp1q + 1] *=
          flight_data_collection_100hz__B.r;
        qq = ((qp1q + 1) << 2) + 1;
        for (qp1jj = qq; qp1jj <= qq + 3; qp1jj++) {
          flight_data_collection_100hz__B.Vf[qp1jj - 1] *=
            flight_data_collection_100hz__B.r;
        }
      }
    }

    flight_data_collection_100hz__B.r = fabs
      (flight_data_collection_100hz__B.b_s[qp1q]);
    flight_data_collection_100hz__B.rt = fabs
      (flight_data_collection_100hz__B.e[qp1q]);
    if ((flight_data_collection_100hz__B.r >= flight_data_collection_100hz__B.rt)
        || rtIsNaN(flight_data_collection_100hz__B.rt)) {
      flight_data_collection_100hz__B.rt = flight_data_collection_100hz__B.r;
    }

    if ((!(flight_data_collection_100hz__B.nrm >=
           flight_data_collection_100hz__B.rt)) && (!rtIsNaN
         (flight_data_collection_100hz__B.rt))) {
      flight_data_collection_100hz__B.nrm = flight_data_collection_100hz__B.rt;
    }
  }

  while ((i + 2 > 0) && (qp1 < 75)) {
    qp1q = i + 1;
    exitg1 = false;
    while (!(exitg1 || (qp1q == 0))) {
      flight_data_collection_100hz__B.rt = fabs
        (flight_data_collection_100hz__B.e[qp1q - 1]);
      if (flight_data_collection_100hz__B.rt <= (fabs
           (flight_data_collection_100hz__B.b_s[qp1q - 1]) + fabs
           (flight_data_collection_100hz__B.b_s[qp1q])) * 2.2204460492503131E-16)
      {
        flight_data_collection_100hz__B.e[qp1q - 1] = 0.0;
        exitg1 = true;
      } else if ((flight_data_collection_100hz__B.rt <= 1.0020841800044864E-292)
                 || ((qp1 > 20) && (flight_data_collection_100hz__B.rt <=
                   2.2204460492503131E-16 * flight_data_collection_100hz__B.nrm)))
      {
        flight_data_collection_100hz__B.e[qp1q - 1] = 0.0;
        exitg1 = true;
      } else {
        qp1q--;
      }
    }

    if (i + 1 == qp1q) {
      qp1jj = 4;
    } else {
      qq = i + 2;
      qp1jj = i + 2;
      exitg1 = false;
      while ((!exitg1) && (qp1jj >= qp1q)) {
        qq = qp1jj;
        if (qp1jj == qp1q) {
          exitg1 = true;
        } else {
          flight_data_collection_100hz__B.rt = 0.0;
          if (qp1jj < i + 2) {
            flight_data_collection_100hz__B.rt = fabs
              (flight_data_collection_100hz__B.e[qp1jj - 1]);
          }

          if (qp1jj > qp1q + 1) {
            flight_data_collection_100hz__B.rt += fabs
              (flight_data_collection_100hz__B.e[qp1jj - 2]);
          }

          flight_data_collection_100hz__B.r = fabs
            (flight_data_collection_100hz__B.b_s[qp1jj - 1]);
          if ((flight_data_collection_100hz__B.r <= 2.2204460492503131E-16 *
               flight_data_collection_100hz__B.rt) ||
              (flight_data_collection_100hz__B.r <= 1.0020841800044864E-292)) {
            flight_data_collection_100hz__B.b_s[qp1jj - 1] = 0.0;
            exitg1 = true;
          } else {
            qp1jj--;
          }
        }
      }

      if (qq == qp1q) {
        qp1jj = 3;
      } else if (i + 2 == qq) {
        qp1jj = 1;
      } else {
        qp1jj = 2;
        qp1q = qq;
      }
    }

    switch (qp1jj) {
     case 1:
      flight_data_collection_100hz__B.rt = flight_data_collection_100hz__B.e[i];
      flight_data_collection_100hz__B.e[i] = 0.0;
      for (qq = i + 1; qq >= qp1q + 1; qq--) {
        flight_data_collection_10_xrotg(&flight_data_collection_100hz__B.b_s[qq
          - 1], &flight_data_collection_100hz__B.rt,
          &flight_data_collection_100hz__B.sqds,
          &flight_data_collection_100hz__B.smm1);
        if (qq > qp1q + 1) {
          flight_data_collection_100hz__B.r =
            flight_data_collection_100hz__B.e[qq - 2];
          flight_data_collection_100hz__B.rt =
            -flight_data_collection_100hz__B.smm1 *
            flight_data_collection_100hz__B.r;
          flight_data_collection_100hz__B.e[qq - 2] =
            flight_data_collection_100hz__B.r *
            flight_data_collection_100hz__B.sqds;
        }

        flight_data_collection_100_xrot(flight_data_collection_100hz__B.Vf, ((qq
          - 1) << 2) + 1, ((i + 1) << 2) + 1,
          flight_data_collection_100hz__B.sqds,
          flight_data_collection_100hz__B.smm1);
      }
      break;

     case 2:
      flight_data_collection_100hz__B.rt =
        flight_data_collection_100hz__B.e[qp1q - 1];
      flight_data_collection_100hz__B.e[qp1q - 1] = 0.0;
      for (qq = qp1q + 1; qq <= i + 2; qq++) {
        flight_data_collection_10_xrotg(&flight_data_collection_100hz__B.b_s[qq
          - 1], &flight_data_collection_100hz__B.rt,
          &flight_data_collection_100hz__B.sqds,
          &flight_data_collection_100hz__B.smm1);
        flight_data_collection_100hz__B.r = flight_data_collection_100hz__B.e[qq
          - 1];
        flight_data_collection_100hz__B.rt =
          -flight_data_collection_100hz__B.smm1 *
          flight_data_collection_100hz__B.r;
        flight_data_collection_100hz__B.e[qq - 1] =
          flight_data_collection_100hz__B.r *
          flight_data_collection_100hz__B.sqds;
        flight_data_collection_1_xrot_a(U, ((qq - 1) << 3) + 1, ((qp1q - 1) << 3)
          + 1, flight_data_collection_100hz__B.sqds,
          flight_data_collection_100hz__B.smm1);
      }
      break;

     case 3:
      flight_data_collection_100hz__B.sqds =
        flight_data_collection_100hz__B.b_s[i + 1];
      flight_data_collection_100hz__B.r = fabs
        (flight_data_collection_100hz__B.sqds);
      flight_data_collection_100hz__B.rt = fabs
        (flight_data_collection_100hz__B.b_s[i]);
      if ((flight_data_collection_100hz__B.r >=
           flight_data_collection_100hz__B.rt) || rtIsNaN
          (flight_data_collection_100hz__B.rt)) {
        flight_data_collection_100hz__B.rt = flight_data_collection_100hz__B.r;
      }

      flight_data_collection_100hz__B.r = fabs
        (flight_data_collection_100hz__B.e[i]);
      if ((flight_data_collection_100hz__B.rt >=
           flight_data_collection_100hz__B.r) || rtIsNaN
          (flight_data_collection_100hz__B.r)) {
        flight_data_collection_100hz__B.r = flight_data_collection_100hz__B.rt;
      }

      flight_data_collection_100hz__B.rt = fabs
        (flight_data_collection_100hz__B.b_s[qp1q]);
      if ((flight_data_collection_100hz__B.r >=
           flight_data_collection_100hz__B.rt) || rtIsNaN
          (flight_data_collection_100hz__B.rt)) {
        flight_data_collection_100hz__B.rt = flight_data_collection_100hz__B.r;
      }

      flight_data_collection_100hz__B.r = fabs
        (flight_data_collection_100hz__B.e[qp1q]);
      if ((flight_data_collection_100hz__B.rt >=
           flight_data_collection_100hz__B.r) || rtIsNaN
          (flight_data_collection_100hz__B.r)) {
        flight_data_collection_100hz__B.r = flight_data_collection_100hz__B.rt;
      }

      flight_data_collection_100hz__B.rt = flight_data_collection_100hz__B.sqds /
        flight_data_collection_100hz__B.r;
      flight_data_collection_100hz__B.smm1 =
        flight_data_collection_100hz__B.b_s[i] /
        flight_data_collection_100hz__B.r;
      flight_data_collection_100hz__B.emm1 = flight_data_collection_100hz__B.e[i]
        / flight_data_collection_100hz__B.r;
      flight_data_collection_100hz__B.sqds =
        flight_data_collection_100hz__B.b_s[qp1q] /
        flight_data_collection_100hz__B.r;
      flight_data_collection_100hz__B.smm1 =
        ((flight_data_collection_100hz__B.smm1 +
          flight_data_collection_100hz__B.rt) *
         (flight_data_collection_100hz__B.smm1 -
          flight_data_collection_100hz__B.rt) +
         flight_data_collection_100hz__B.emm1 *
         flight_data_collection_100hz__B.emm1) / 2.0;
      flight_data_collection_100hz__B.emm1 *= flight_data_collection_100hz__B.rt;
      flight_data_collection_100hz__B.emm1 *=
        flight_data_collection_100hz__B.emm1;
      if ((flight_data_collection_100hz__B.smm1 != 0.0) ||
          (flight_data_collection_100hz__B.emm1 != 0.0)) {
        flight_data_collection_100hz__B.shift = sqrt
          (flight_data_collection_100hz__B.smm1 *
           flight_data_collection_100hz__B.smm1 +
           flight_data_collection_100hz__B.emm1);
        if (flight_data_collection_100hz__B.smm1 < 0.0) {
          flight_data_collection_100hz__B.shift =
            -flight_data_collection_100hz__B.shift;
        }

        flight_data_collection_100hz__B.shift =
          flight_data_collection_100hz__B.emm1 /
          (flight_data_collection_100hz__B.smm1 +
           flight_data_collection_100hz__B.shift);
      } else {
        flight_data_collection_100hz__B.shift = 0.0;
      }

      flight_data_collection_100hz__B.rt = (flight_data_collection_100hz__B.sqds
        + flight_data_collection_100hz__B.rt) *
        (flight_data_collection_100hz__B.sqds -
         flight_data_collection_100hz__B.rt) +
        flight_data_collection_100hz__B.shift;
      flight_data_collection_100hz__B.r = flight_data_collection_100hz__B.e[qp1q]
        / flight_data_collection_100hz__B.r *
        flight_data_collection_100hz__B.sqds;
      for (qq = qp1q + 1; qq <= i + 1; qq++) {
        flight_data_collection_10_xrotg(&flight_data_collection_100hz__B.rt,
          &flight_data_collection_100hz__B.r,
          &flight_data_collection_100hz__B.sqds,
          &flight_data_collection_100hz__B.smm1);
        if (qq > qp1q + 1) {
          flight_data_collection_100hz__B.e[qq - 2] =
            flight_data_collection_100hz__B.rt;
        }

        flight_data_collection_100hz__B.emm1 =
          flight_data_collection_100hz__B.e[qq - 1];
        flight_data_collection_100hz__B.r =
          flight_data_collection_100hz__B.b_s[qq - 1];
        flight_data_collection_100hz__B.e[qq - 1] =
          flight_data_collection_100hz__B.emm1 *
          flight_data_collection_100hz__B.sqds -
          flight_data_collection_100hz__B.r *
          flight_data_collection_100hz__B.smm1;
        flight_data_collection_100hz__B.rt =
          flight_data_collection_100hz__B.smm1 *
          flight_data_collection_100hz__B.b_s[qq];
        flight_data_collection_100hz__B.b_s[qq] *=
          flight_data_collection_100hz__B.sqds;
        flight_data_collection_100_xrot(flight_data_collection_100hz__B.Vf, ((qq
          - 1) << 2) + 1, (qq << 2) + 1, flight_data_collection_100hz__B.sqds,
          flight_data_collection_100hz__B.smm1);
        flight_data_collection_100hz__B.b_s[qq - 1] =
          flight_data_collection_100hz__B.r *
          flight_data_collection_100hz__B.sqds +
          flight_data_collection_100hz__B.emm1 *
          flight_data_collection_100hz__B.smm1;
        flight_data_collection_10_xrotg(&flight_data_collection_100hz__B.b_s[qq
          - 1], &flight_data_collection_100hz__B.rt,
          &flight_data_collection_100hz__B.sqds,
          &flight_data_collection_100hz__B.smm1);
        flight_data_collection_100hz__B.r = flight_data_collection_100hz__B.e[qq
          - 1];
        flight_data_collection_100hz__B.rt = flight_data_collection_100hz__B.r *
          flight_data_collection_100hz__B.sqds +
          flight_data_collection_100hz__B.smm1 *
          flight_data_collection_100hz__B.b_s[qq];
        flight_data_collection_100hz__B.b_s[qq] =
          flight_data_collection_100hz__B.r *
          -flight_data_collection_100hz__B.smm1 +
          flight_data_collection_100hz__B.sqds *
          flight_data_collection_100hz__B.b_s[qq];
        flight_data_collection_100hz__B.r = flight_data_collection_100hz__B.smm1
          * flight_data_collection_100hz__B.e[qq];
        flight_data_collection_100hz__B.e[qq] *=
          flight_data_collection_100hz__B.sqds;
        flight_data_collection_1_xrot_a(U, ((qq - 1) << 3) + 1, (qq << 3) + 1,
          flight_data_collection_100hz__B.sqds,
          flight_data_collection_100hz__B.smm1);
      }

      flight_data_collection_100hz__B.e[i] = flight_data_collection_100hz__B.rt;
      qp1++;
      break;

     default:
      if (flight_data_collection_100hz__B.b_s[qp1q] < 0.0) {
        flight_data_collection_100hz__B.b_s[qp1q] =
          -flight_data_collection_100hz__B.b_s[qp1q];
        qp1 = (qp1q << 2) + 1;
        for (qq = qp1; qq <= qp1 + 3; qq++) {
          flight_data_collection_100hz__B.Vf[qq - 1] =
            -flight_data_collection_100hz__B.Vf[qq - 1];
        }
      }

      qp1 = qp1q + 1;
      while ((qp1q + 1 < 4) && (flight_data_collection_100hz__B.b_s[qp1q] <
              flight_data_collection_100hz__B.b_s[qp1])) {
        flight_data_collection_100hz__B.rt =
          flight_data_collection_100hz__B.b_s[qp1q];
        flight_data_collection_100hz__B.b_s[qp1q] =
          flight_data_collection_100hz__B.b_s[qp1];
        flight_data_collection_100hz__B.b_s[qp1] =
          flight_data_collection_100hz__B.rt;
        flight_data_collection_10_xswap(flight_data_collection_100hz__B.Vf,
          (qp1q << 2) + 1, ((qp1q + 1) << 2) + 1);
        flight_data_collection__xswap_l(U, (qp1q << 3) + 1, ((qp1q + 1) << 3) +
          1);
        qp1q = qp1;
        qp1++;
      }

      qp1 = 0;
      i--;
      break;
    }
  }

  s[0] = flight_data_collection_100hz__B.b_s[0];
  s[1] = flight_data_collection_100hz__B.b_s[1];
  s[2] = flight_data_collection_100hz__B.b_s[2];
  s[3] = flight_data_collection_100hz__B.b_s[3];
  if (doscale) {
    flight_data_collectio_xzlascl_a(flight_data_collection_100hz__B.cscale,
      flight_data_collection_100hz__B.anrm, 4, 1, s, 1, 4);
  }

  for (i = 0; i < 4; i++) {
    qp1 = i << 2;
    V[qp1] = flight_data_collection_100hz__B.Vf[qp1];
    V[qp1 + 1] = flight_data_collection_100hz__B.Vf[qp1 + 1];
    V[qp1 + 2] = flight_data_collection_100hz__B.Vf[qp1 + 2];
    V[qp1 + 3] = flight_data_collection_100hz__B.Vf[qp1 + 3];
  }
}

real_T rt_atan2d_snf(real_T u0, real_T u1)
{
  real_T y;
  if (rtIsNaN(u0) || rtIsNaN(u1)) {
    y = (rtNaN);
  } else if (rtIsInf(u0) && rtIsInf(u1)) {
    int32_T tmp;
    int32_T tmp_0;
    if (u0 > 0.0) {
      tmp = 1;
    } else {
      tmp = -1;
    }

    if (u1 > 0.0) {
      tmp_0 = 1;
    } else {
      tmp_0 = -1;
    }

    y = atan2(static_cast<real_T>(tmp), static_cast<real_T>(tmp_0));
  } else if (u1 == 0.0) {
    if (u0 > 0.0) {
      y = RT_PI / 2.0;
    } else if (u0 < 0.0) {
      y = -(RT_PI / 2.0);
    } else {
      y = 0.0;
    }
  } else {
    y = atan2(u0, u1);
  }

  return y;
}

// Model step function
void flight_data_collection::step()
{
  int32_T c_k;
  int32_T exponent;
  int32_T i;
  boolean_T p;
  static const int8_T c[8] = { 1, 1, -1, -1, -1, -1, 1, 1 };

  static const real_T a[9] = { 1.52, 0.0, 0.0, 0.0, 7.47, 0.0, 0.0, 0.0, 8.89 };

  static const real_T a_0[9] = { 1.545E-5, 0.0, 0.0, 0.0, 0.00073574, 0.0, 0.0,
    0.0, 0.00074861 };

  // BusAssignment: '<Root>/Bus Assignment' incorporates:
  //   Constant: '<S2>/Constant'

  flight_data_collection_100hz__B.BusAssignment =
    flight_data_collection_100hz__P.Constant_Value;

  // MATLAB Function: '<S5>/octo geometricCalc' incorporates:
  //   Constant: '<S5>/Constant'
  //   Constant: '<S5>/Constant1'
  //   Constant: '<S5>/Constant2'
  //   Constant: '<S5>/Constant4'
  //   Constant: '<S5>/Constant5'

  flight_data_collection_100hz__B.C[0] =
    -flight_data_collection_100hz__P.MotorForceCalculation_Ct;
  flight_data_collection_100hz__B.C[4] =
    -flight_data_collection_100hz__P.MotorForceCalculation_Ct;
  flight_data_collection_100hz__B.C[8] =
    -flight_data_collection_100hz__P.MotorForceCalculation_Ct;
  flight_data_collection_100hz__B.C[12] =
    -flight_data_collection_100hz__P.MotorForceCalculation_Ct;
  flight_data_collection_100hz__B.C[16] =
    -flight_data_collection_100hz__P.MotorForceCalculation_Ct;
  flight_data_collection_100hz__B.C[20] =
    -flight_data_collection_100hz__P.MotorForceCalculation_Ct;
  flight_data_collection_100hz__B.C[24] =
    -flight_data_collection_100hz__P.MotorForceCalculation_Ct;
  flight_data_collection_100hz__B.C[28] =
    -flight_data_collection_100hz__P.MotorForceCalculation_Ct;
  flight_data_collection_100hz__B.absx =
    -flight_data_collection_100hz__P.MotorForceCalculation_Ct *
    flight_data_collection_100hz__P.MotorForceCalculation_L1;
  flight_data_collection_100hz__B.C[1] = flight_data_collection_100hz__B.absx;
  flight_data_collection_100hz__B.fcn3 =
    flight_data_collection_100hz__P.MotorForceCalculation_Ct *
    flight_data_collection_100hz__P.MotorForceCalculation_L1;
  flight_data_collection_100hz__B.C[5] = flight_data_collection_100hz__B.fcn3;
  flight_data_collection_100hz__B.C[9] = flight_data_collection_100hz__B.absx;
  flight_data_collection_100hz__B.C[13] = flight_data_collection_100hz__B.absx;
  flight_data_collection_100hz__B.C[17] = flight_data_collection_100hz__B.fcn3;
  flight_data_collection_100hz__B.C[21] = flight_data_collection_100hz__B.fcn3;
  flight_data_collection_100hz__B.C[25] = flight_data_collection_100hz__B.fcn3;
  flight_data_collection_100hz__B.C[29] = flight_data_collection_100hz__B.absx;
  flight_data_collection_100hz__B.absx =
    flight_data_collection_100hz__P.MotorForceCalculation_Ct *
    flight_data_collection_100hz__P.MotorForceCalculation_L3;
  flight_data_collection_100hz__B.C[2] = flight_data_collection_100hz__B.absx;
  flight_data_collection_100hz__B.fcn3 =
    -flight_data_collection_100hz__P.MotorForceCalculation_Ct *
    flight_data_collection_100hz__P.MotorForceCalculation_L3;
  flight_data_collection_100hz__B.C[6] = flight_data_collection_100hz__B.fcn3;
  flight_data_collection_100hz__B.Product3 =
    flight_data_collection_100hz__P.MotorForceCalculation_Ct *
    flight_data_collection_100hz__P.MotorForceCalculation_L2;
  flight_data_collection_100hz__B.C[10] =
    flight_data_collection_100hz__B.Product3;
  flight_data_collection_100hz__B.C[14] = flight_data_collection_100hz__B.fcn3;
  flight_data_collection_100hz__B.C[18] = flight_data_collection_100hz__B.absx;
  flight_data_collection_100hz__B.absx =
    -flight_data_collection_100hz__P.MotorForceCalculation_Ct *
    flight_data_collection_100hz__P.MotorForceCalculation_L2;
  flight_data_collection_100hz__B.C[22] = flight_data_collection_100hz__B.absx;
  flight_data_collection_100hz__B.C[26] =
    flight_data_collection_100hz__B.Product3;
  flight_data_collection_100hz__B.C[30] = flight_data_collection_100hz__B.absx;
  flight_data_collection_100hz__B.C[3] =
    flight_data_collection_100hz__P.MotorForceCalculation_Cq;
  flight_data_collection_100hz__B.C[7] =
    flight_data_collection_100hz__P.MotorForceCalculation_Cq;
  flight_data_collection_100hz__B.C[11] =
    -flight_data_collection_100hz__P.MotorForceCalculation_Cq;
  flight_data_collection_100hz__B.C[15] =
    -flight_data_collection_100hz__P.MotorForceCalculation_Cq;
  flight_data_collection_100hz__B.C[19] =
    -flight_data_collection_100hz__P.MotorForceCalculation_Cq;
  flight_data_collection_100hz__B.C[23] =
    -flight_data_collection_100hz__P.MotorForceCalculation_Cq;
  flight_data_collection_100hz__B.C[27] =
    flight_data_collection_100hz__P.MotorForceCalculation_Cq;
  flight_data_collection_100hz__B.C[31] =
    flight_data_collection_100hz__P.MotorForceCalculation_Cq;
  for (c_k = 0; c_k < 4; c_k++) {
    for (i = 0; i < 8; i++) {
      flight_data_collection_100hz__B.A[i + (c_k << 3)] =
        flight_data_collection_100hz__B.C[(i << 2) + c_k];
    }
  }

  p = true;
  for (c_k = 0; c_k < 32; c_k++) {
    if (p) {
      flight_data_collection_100hz__B.absx =
        flight_data_collection_100hz__B.A[c_k];
      if (rtIsInf(flight_data_collection_100hz__B.absx) || rtIsNaN
          (flight_data_collection_100hz__B.absx)) {
        p = false;
      }
    }
  }

  if (p) {
    flight_data_collection_100h_svd(flight_data_collection_100hz__B.A,
      flight_data_collection_100hz__B.U,
      flight_data_collection_100hz__B.c_actual_force_and_moment_actin,
      flight_data_collection_100hz__B.V);
    flight_data_collection_100hz__B.absx = fabs
      (flight_data_collection_100hz__B.c_actual_force_and_moment_actin[0]);
    if ((!rtIsInf(flight_data_collection_100hz__B.absx)) && (!rtIsNaN
         (flight_data_collection_100hz__B.absx)) &&
        (!(flight_data_collection_100hz__B.absx < 4.4501477170144028E-308))) {
      frexp(flight_data_collection_100hz__B.absx, &exponent);
    }
  }

  // End of MATLAB Function: '<S5>/octo geometricCalc'

  // Outputs for Atomic SubSystem: '<Root>/Subscribe'
  // MATLABSystem: '<S8>/SourceBlock'
  p = Sub_flight_data_collection_100hz_conver_to_c_1138.getLatestMessage
    (&flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d);

  // Outputs for Enabled SubSystem: '<S8>/Enabled Subsystem' incorporates:
  //   EnablePort: '<S32>/Enable'

  // Start for MATLABSystem: '<S8>/SourceBlock'
  if (p) {
    // SignalConversion generated from: '<S32>/In1'
    flight_data_collection_100hz__B.In1_l =
      flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d;
  }

  // End of Start for MATLABSystem: '<S8>/SourceBlock'
  // End of Outputs for SubSystem: '<S8>/Enabled Subsystem'
  // End of Outputs for SubSystem: '<Root>/Subscribe'

  // Outputs for Atomic SubSystem: '<Root>/Subscribe3'
  // MATLABSystem: '<S15>/SourceBlock'
  p = Sub_flight_data_collection_100hz_conver_to_c_1139.getLatestMessage
    (&flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d);

  // Outputs for Enabled SubSystem: '<S15>/Enabled Subsystem' incorporates:
  //   EnablePort: '<S39>/Enable'

  // Start for MATLABSystem: '<S15>/SourceBlock'
  if (p) {
    // SignalConversion generated from: '<S39>/In1'
    flight_data_collection_100hz__B.In1_im =
      flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d;
  }

  // End of Start for MATLABSystem: '<S15>/SourceBlock'
  // End of Outputs for SubSystem: '<S15>/Enabled Subsystem'
  // End of Outputs for SubSystem: '<Root>/Subscribe3'

  // Outputs for Atomic SubSystem: '<Root>/Subscribe4'
  // MATLABSystem: '<S16>/SourceBlock'
  p = Sub_flight_data_collection_100hz_conver_to_c_1140.getLatestMessage
    (&flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d);

  // Outputs for Enabled SubSystem: '<S16>/Enabled Subsystem' incorporates:
  //   EnablePort: '<S40>/Enable'

  // Start for MATLABSystem: '<S16>/SourceBlock'
  if (p) {
    // SignalConversion generated from: '<S40>/In1'
    flight_data_collection_100hz__B.In1_a =
      flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d;
  }

  // End of Start for MATLABSystem: '<S16>/SourceBlock'
  // End of Outputs for SubSystem: '<S16>/Enabled Subsystem'
  // End of Outputs for SubSystem: '<Root>/Subscribe4'

  // Outputs for Atomic SubSystem: '<Root>/Subscribe5'
  // MATLABSystem: '<S17>/SourceBlock'
  p = Sub_flight_data_collection_100hz_conver_to_c_1141.getLatestMessage
    (&flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d);

  // Outputs for Enabled SubSystem: '<S17>/Enabled Subsystem' incorporates:
  //   EnablePort: '<S41>/Enable'

  // Start for MATLABSystem: '<S17>/SourceBlock'
  if (p) {
    // SignalConversion generated from: '<S41>/In1'
    flight_data_collection_100hz__B.In1_c =
      flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d;
  }

  // End of Start for MATLABSystem: '<S17>/SourceBlock'
  // End of Outputs for SubSystem: '<S17>/Enabled Subsystem'
  // End of Outputs for SubSystem: '<Root>/Subscribe5'

  // Outputs for Atomic SubSystem: '<Root>/Subscribe6'
  // MATLABSystem: '<S18>/SourceBlock'
  p = Sub_flight_data_collection_100hz_conver_to_c_1142.getLatestMessage
    (&flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d);

  // Outputs for Enabled SubSystem: '<S18>/Enabled Subsystem' incorporates:
  //   EnablePort: '<S42>/Enable'

  // Start for MATLABSystem: '<S18>/SourceBlock'
  if (p) {
    // SignalConversion generated from: '<S42>/In1'
    flight_data_collection_100hz__B.In1_j3 =
      flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d;
  }

  // End of Start for MATLABSystem: '<S18>/SourceBlock'
  // End of Outputs for SubSystem: '<S18>/Enabled Subsystem'
  // End of Outputs for SubSystem: '<Root>/Subscribe6'

  // Outputs for Atomic SubSystem: '<Root>/Subscribe7'
  // MATLABSystem: '<S19>/SourceBlock'
  p = Sub_flight_data_collection_100hz_conver_to_c_1143.getLatestMessage
    (&flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d);

  // Outputs for Enabled SubSystem: '<S19>/Enabled Subsystem' incorporates:
  //   EnablePort: '<S43>/Enable'

  // Start for MATLABSystem: '<S19>/SourceBlock'
  if (p) {
    // SignalConversion generated from: '<S43>/In1'
    flight_data_collection_100hz__B.In1_d =
      flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d;
  }

  // End of Start for MATLABSystem: '<S19>/SourceBlock'
  // End of Outputs for SubSystem: '<S19>/Enabled Subsystem'
  // End of Outputs for SubSystem: '<Root>/Subscribe7'

  // Outputs for Atomic SubSystem: '<Root>/Subscribe8'
  // MATLABSystem: '<S20>/SourceBlock'
  p = Sub_flight_data_collection_100hz_conver_to_c_1144.getLatestMessage
    (&flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d);

  // Outputs for Enabled SubSystem: '<S20>/Enabled Subsystem' incorporates:
  //   EnablePort: '<S44>/Enable'

  // Start for MATLABSystem: '<S20>/SourceBlock'
  if (p) {
    // SignalConversion generated from: '<S44>/In1'
    flight_data_collection_100hz__B.In1_i =
      flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d;
  }

  // End of Start for MATLABSystem: '<S20>/SourceBlock'
  // End of Outputs for SubSystem: '<S20>/Enabled Subsystem'
  // End of Outputs for SubSystem: '<Root>/Subscribe8'

  // Outputs for Atomic SubSystem: '<Root>/Subscribe9'
  // MATLABSystem: '<S21>/SourceBlock'
  p = Sub_flight_data_collection_100hz_conver_to_c_1145.getLatestMessage
    (&flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d);

  // Outputs for Enabled SubSystem: '<S21>/Enabled Subsystem' incorporates:
  //   EnablePort: '<S45>/Enable'

  // Start for MATLABSystem: '<S21>/SourceBlock'
  if (p) {
    // SignalConversion generated from: '<S45>/In1'
    flight_data_collection_100hz__B.In1_gs =
      flight_data_collection_100hz__B.rtb_SourceBlock_o2_a_d;
  }

  // End of Start for MATLABSystem: '<S21>/SourceBlock'
  // End of Outputs for SubSystem: '<S21>/Enabled Subsystem'
  // End of Outputs for SubSystem: '<Root>/Subscribe9'

  // SignalConversion generated from: '<S22>/ SFunction ' incorporates:
  //   MATLAB Function: '<Root>/MATLAB Function1'
  //   MATLAB Function: '<S5>/motorForceMomentCalc'
  //   SignalConversion generated from: '<S4>/ SFunction '

  flight_data_collection_100hz__B.rtb_TmpSignalConversionAtSFun_c[0] =
    flight_data_collection_100hz__B.In1_l.Data;
  flight_data_collection_100hz__B.rtb_TmpSignalConversionAtSFun_c[1] =
    flight_data_collection_100hz__B.In1_im.Data;
  flight_data_collection_100hz__B.rtb_TmpSignalConversionAtSFun_c[2] =
    flight_data_collection_100hz__B.In1_a.Data;
  flight_data_collection_100hz__B.rtb_TmpSignalConversionAtSFun_c[3] =
    flight_data_collection_100hz__B.In1_c.Data;
  flight_data_collection_100hz__B.rtb_TmpSignalConversionAtSFun_c[4] =
    flight_data_collection_100hz__B.In1_j3.Data;
  flight_data_collection_100hz__B.rtb_TmpSignalConversionAtSFun_c[5] =
    flight_data_collection_100hz__B.In1_d.Data;
  flight_data_collection_100hz__B.rtb_TmpSignalConversionAtSFun_c[6] =
    flight_data_collection_100hz__B.In1_i.Data;
  flight_data_collection_100hz__B.rtb_TmpSignalConversionAtSFun_c[7] =
    flight_data_collection_100hz__B.In1_gs.Data;

  // MATLAB Function: '<S5>/motorForceMomentCalc' incorporates:
  //   SignalConversion generated from: '<S22>/ SFunction '

  for (exponent = 0; exponent < 8; exponent++) {
    flight_data_collection_100hz__B.absx = fabs
      (flight_data_collection_100hz__B.rtb_TmpSignalConversionAtSFun_c[exponent]);
    flight_data_collection_100hz__B.y[exponent] =
      flight_data_collection_100hz__B.absx *
      flight_data_collection_100hz__B.absx;
  }

  for (c_k = 0; c_k < 4; c_k++) {
    flight_data_collection_100hz__B.absx = 0.0;
    for (i = 0; i < 8; i++) {
      flight_data_collection_100hz__B.absx += flight_data_collection_100hz__B.C
        [(i << 2) + c_k] * flight_data_collection_100hz__B.y[i];
    }

    flight_data_collection_100hz__B.c_actual_force_and_moment_actin[c_k] =
      flight_data_collection_100hz__B.absx;
  }

  flight_data_collection_100hz__B.FB[0] = 0.0;
  flight_data_collection_100hz__B.FB[1] = 0.0;
  flight_data_collection_100hz__B.FB[2] =
    flight_data_collection_100hz__B.c_actual_force_and_moment_actin[0];
  flight_data_collection_100hz__B.MB[0] =
    flight_data_collection_100hz__B.c_actual_force_and_moment_actin[1];
  flight_data_collection_100hz__B.MB[1] =
    -flight_data_collection_100hz__B.c_actual_force_and_moment_actin[2];
  flight_data_collection_100hz__B.MB[2] =
    -flight_data_collection_100hz__B.c_actual_force_and_moment_actin[3];

  // Outputs for Atomic SubSystem: '<Root>/Subscribe2'
  // MATLABSystem: '<S14>/SourceBlock'
  p = Sub_flight_data_collection_100hz_conver_to_c_1606.getLatestMessage
    (&flight_data_collection_100hz__B.rtb_SourceBlock_o2_b_c);

  // Outputs for Enabled SubSystem: '<S14>/Enabled Subsystem' incorporates:
  //   EnablePort: '<S38>/Enable'

  // Start for MATLABSystem: '<S14>/SourceBlock'
  if (p) {
    // SignalConversion generated from: '<S38>/In1'
    flight_data_collection_100hz__B.In1_g =
      flight_data_collection_100hz__B.rtb_SourceBlock_o2_b_c;
  }

  // End of Start for MATLABSystem: '<S14>/SourceBlock'
  // End of Outputs for SubSystem: '<S14>/Enabled Subsystem'
  // End of Outputs for SubSystem: '<Root>/Subscribe2'

  // Outputs for Atomic SubSystem: '<Root>/Subscribe14'
  // MATLABSystem: '<S13>/SourceBlock'
  p = Sub_flight_data_collection_100hz_conver_to_c_1935.getLatestMessage
    (&flight_data_collection_100hz__B.rtb_SourceBlock_o2_mb);

  // Outputs for Enabled SubSystem: '<S13>/Enabled Subsystem' incorporates:
  //   EnablePort: '<S37>/Enable'

  // Start for MATLABSystem: '<S13>/SourceBlock'
  if (p) {
    // SignalConversion generated from: '<S37>/In1'
    flight_data_collection_100hz__B.In1 =
      flight_data_collection_100hz__B.rtb_SourceBlock_o2_mb;
  }

  // End of Start for MATLABSystem: '<S13>/SourceBlock'
  // End of Outputs for SubSystem: '<S13>/Enabled Subsystem'
  // End of Outputs for SubSystem: '<Root>/Subscribe14'

  // Outputs for Atomic SubSystem: '<Root>/Subscribe12'
  // MATLABSystem: '<S11>/SourceBlock'
  p = Sub_flight_data_collection_100hz_conver_to_c_1918.getLatestMessage
    (&flight_data_collection_100hz__B.rtb_SourceBlock_o2_o_c);

  // Outputs for Enabled SubSystem: '<S11>/Enabled Subsystem' incorporates:
  //   EnablePort: '<S35>/Enable'

  // Start for MATLABSystem: '<S11>/SourceBlock'
  if (p) {
    // SignalConversion generated from: '<S35>/In1'
    flight_data_collection_100hz__B.In1_j =
      flight_data_collection_100hz__B.rtb_SourceBlock_o2_o_c;
  }

  // End of Start for MATLABSystem: '<S11>/SourceBlock'
  // End of Outputs for SubSystem: '<S11>/Enabled Subsystem'
  // End of Outputs for SubSystem: '<Root>/Subscribe12'

  // Sqrt: '<S30>/sqrt' incorporates:
  //   Product: '<S31>/Product'
  //   Product: '<S31>/Product1'
  //   Product: '<S31>/Product2'
  //   Product: '<S31>/Product3'
  //   Sum: '<S31>/Sum'

  flight_data_collection_100hz__B.Product3 = sqrt
    (((flight_data_collection_100hz__B.In1_j.Pose.Orientation.W *
       flight_data_collection_100hz__B.In1_j.Pose.Orientation.W +
       flight_data_collection_100hz__B.In1_j.Pose.Orientation.X *
       flight_data_collection_100hz__B.In1_j.Pose.Orientation.X) +
      flight_data_collection_100hz__B.In1_j.Pose.Orientation.Y *
      flight_data_collection_100hz__B.In1_j.Pose.Orientation.Y) +
     flight_data_collection_100hz__B.In1_j.Pose.Orientation.Z *
     flight_data_collection_100hz__B.In1_j.Pose.Orientation.Z);

  // Product: '<S25>/Product'
  flight_data_collection_100hz__B.fcn5 =
    flight_data_collection_100hz__B.In1_j.Pose.Orientation.W /
    flight_data_collection_100hz__B.Product3;

  // Product: '<S25>/Product1'
  flight_data_collection_100hz__B.Product1 =
    flight_data_collection_100hz__B.In1_j.Pose.Orientation.X /
    flight_data_collection_100hz__B.Product3;

  // Product: '<S25>/Product2'
  flight_data_collection_100hz__B.Product2 =
    flight_data_collection_100hz__B.In1_j.Pose.Orientation.Y /
    flight_data_collection_100hz__B.Product3;

  // Product: '<S25>/Product3'
  flight_data_collection_100hz__B.Product3 =
    flight_data_collection_100hz__B.In1_j.Pose.Orientation.Z /
    flight_data_collection_100hz__B.Product3;

  // Fcn: '<S7>/fcn2' incorporates:
  //   Fcn: '<S7>/fcn5'

  flight_data_collection_100hz__B.r_dot = flight_data_collection_100hz__B.fcn5 *
    flight_data_collection_100hz__B.fcn5;
  flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_tmp =
    flight_data_collection_100hz__B.Product1 *
    flight_data_collection_100hz__B.Product1;
  flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_t_g =
    flight_data_collection_100hz__B.Product2 *
    flight_data_collection_100hz__B.Product2;
  flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0__g1 =
    flight_data_collection_100hz__B.Product3 *
    flight_data_collection_100hz__B.Product3;

  // Trigonometry: '<S24>/Trigonometric Function1' incorporates:
  //   Fcn: '<S7>/fcn1'
  //   Fcn: '<S7>/fcn2'

  flight_data_collection_100hz__B.absx = rt_atan2d_snf
    ((flight_data_collection_100hz__B.Product1 *
      flight_data_collection_100hz__B.Product2 +
      flight_data_collection_100hz__B.fcn5 *
      flight_data_collection_100hz__B.Product3) * 2.0,
     ((flight_data_collection_100hz__B.r_dot +
       flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_tmp) -
      flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_t_g) -
     flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0__g1);

  // Fcn: '<S7>/fcn3'
  flight_data_collection_100hz__B.fcn3 =
    (flight_data_collection_100hz__B.Product1 *
     flight_data_collection_100hz__B.Product3 -
     flight_data_collection_100hz__B.fcn5 *
     flight_data_collection_100hz__B.Product2) * -2.0;

  // If: '<S26>/If' incorporates:
  //   Constant: '<S27>/Constant'
  //   Constant: '<S28>/Constant'
  //   Trigonometry: '<S24>/trigFcn'

  if (flight_data_collection_100hz__B.fcn3 > 1.0) {
    flight_data_collection_100hz__B.fcn3 =
      flight_data_collection_100hz__P.Constant_Value_g;
  } else if (flight_data_collection_100hz__B.fcn3 < -1.0) {
    flight_data_collection_100hz__B.fcn3 =
      flight_data_collection_100hz__P.Constant_Value_fx;
  }

  if (flight_data_collection_100hz__B.fcn3 > 1.0) {
    flight_data_collection_100hz__B.fcn3 = 1.0;
  } else if (flight_data_collection_100hz__B.fcn3 < -1.0) {
    flight_data_collection_100hz__B.fcn3 = -1.0;
  }

  // End of If: '<S26>/If'

  // Trigonometry: '<S24>/trigFcn'
  flight_data_collection_100hz__B.fcn3 = asin
    (flight_data_collection_100hz__B.fcn3);

  // Trigonometry: '<S24>/Trigonometric Function3' incorporates:
  //   Fcn: '<S7>/fcn4'
  //   Fcn: '<S7>/fcn5'

  flight_data_collection_100hz__B.Product3 = rt_atan2d_snf
    ((flight_data_collection_100hz__B.Product2 *
      flight_data_collection_100hz__B.Product3 +
      flight_data_collection_100hz__B.fcn5 *
      flight_data_collection_100hz__B.Product1) * 2.0,
     ((flight_data_collection_100hz__B.r_dot -
       flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_tmp) -
      flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_t_g) +
     flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0__g1);

  // MATLAB Function: '<Root>/MATLAB Function1' incorporates:
  //   SignalConversion generated from: '<S4>/ SFunction '

  flight_data_collection_100hz__B.fcn5 = cos
    (flight_data_collection_100hz__B.fcn3);
  flight_data_collection_100hz__B.Product1 = cos
    (flight_data_collection_100hz__B.absx);
  flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0__g1 = sin
    (flight_data_collection_100hz__B.fcn3);
  flight_data_collection_100hz__B.Product2 = sin
    (flight_data_collection_100hz__B.absx);
  flight_data_collection_100hz__B.r_dot = sin
    (flight_data_collection_100hz__B.Product3);
  flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_tmp = cos
    (flight_data_collection_100hz__B.Product3);
  flight_data_collection_100hz__B.b_b_tmp[0] =
    flight_data_collection_100hz__B.Product1 *
    flight_data_collection_100hz__B.fcn5;
  flight_data_collection_100hz__B.b_b_tmp[3] =
    flight_data_collection_100hz__B.Product2 *
    flight_data_collection_100hz__B.fcn5;
  flight_data_collection_100hz__B.b_b_tmp[6] =
    -flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0__g1;
  flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_t_g =
    flight_data_collection_100hz__B.Product1 *
    flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0__g1;
  flight_data_collection_100hz__B.b_b_tmp[1] =
    flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_t_g *
    flight_data_collection_100hz__B.r_dot -
    flight_data_collection_100hz__B.Product2 *
    flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_tmp;
  flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0__g1 *=
    flight_data_collection_100hz__B.Product2;
  flight_data_collection_100hz__B.b_b_tmp[4] =
    flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0__g1 *
    flight_data_collection_100hz__B.r_dot +
    flight_data_collection_100hz__B.Product1 *
    flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_tmp;
  flight_data_collection_100hz__B.b_b_tmp[7] =
    flight_data_collection_100hz__B.fcn5 * flight_data_collection_100hz__B.r_dot;
  flight_data_collection_100hz__B.b_b_tmp[2] =
    flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_t_g *
    flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_tmp +
    flight_data_collection_100hz__B.Product2 *
    flight_data_collection_100hz__B.r_dot;
  flight_data_collection_100hz__B.b_b_tmp[5] =
    flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0__g1 *
    flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_tmp -
    flight_data_collection_100hz__B.Product1 *
    flight_data_collection_100hz__B.r_dot;
  flight_data_collection_100hz__B.b_b_tmp[8] =
    flight_data_collection_100hz__B.fcn5 *
    flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_tmp;
  for (c_k = 0; c_k < 3; c_k++) {
    flight_data_collection_100hz__B.b_b[c_k] =
      (flight_data_collection_100hz__B.b_b_tmp[c_k + 3] * 0.0 +
       flight_data_collection_100hz__B.b_b_tmp[c_k] * 0.0) +
      flight_data_collection_100hz__B.b_b_tmp[c_k + 6];
  }

  for (exponent = 0; exponent < 8; exponent++) {
    flight_data_collection_100hz__B.y[exponent] = static_cast<real_T>(c[exponent])
      * fabs
      (flight_data_collection_100hz__B.rtb_TmpSignalConversionAtSFun_c[exponent]);
  }

  flight_data_collection_100hz__B.fcn5 = flight_data_collection_100hz__B.y[0];
  for (exponent = 0; exponent < 7; exponent++) {
    flight_data_collection_100hz__B.fcn5 +=
      flight_data_collection_100hz__B.y[exponent + 1];
  }

  // MATLAB Function: '<Root>/MATLAB Function'
  if (!flight_data_collection_100hz_DW.initialized_not_empty) {
    flight_data_collection_100hz_DW.p_prev =
      flight_data_collection_100hz__B.In1.AngularVelocity.X;
    flight_data_collection_100hz_DW.q_prev =
      flight_data_collection_100hz__B.In1.AngularVelocity.Y;
    flight_data_collection_100hz_DW.r_prev =
      flight_data_collection_100hz__B.In1.AngularVelocity.Z;
    flight_data_collection_100hz_DW.initialized_not_empty = true;
  }

  flight_data_collection_100hz__B.Product1 =
    (flight_data_collection_100hz__B.In1.AngularVelocity.X -
     flight_data_collection_100hz_DW.p_prev) / 0.01;
  flight_data_collection_100hz__B.Product2 =
    (flight_data_collection_100hz__B.In1.AngularVelocity.Y -
     flight_data_collection_100hz_DW.q_prev) / 0.01;
  flight_data_collection_100hz__B.r_dot =
    (flight_data_collection_100hz__B.In1.AngularVelocity.Z -
     flight_data_collection_100hz_DW.r_prev) / 0.01;
  flight_data_collection_100hz_DW.p_prev =
    flight_data_collection_100hz__B.In1.AngularVelocity.X;
  flight_data_collection_100hz_DW.q_prev =
    flight_data_collection_100hz__B.In1.AngularVelocity.Y;
  flight_data_collection_100hz_DW.r_prev =
    flight_data_collection_100hz__B.In1.AngularVelocity.Z;
  for (c_k = 0; c_k < 3; c_k++) {
    flight_data_collection_100hz__B.TmpSignalConversionAtSFun_i[c_k] = (a[c_k +
      3] * flight_data_collection_100hz__B.In1.AngularVelocity.Y + a[c_k] *
      flight_data_collection_100hz__B.In1.AngularVelocity.X) + a[c_k + 6] *
      flight_data_collection_100hz__B.In1.AngularVelocity.Z;
  }

  // Outputs for Atomic SubSystem: '<Root>/Subscribe13'
  // MATLABSystem: '<S12>/SourceBlock'
  p = Sub_flight_data_collection_100hz_conver_to_c_1930.getLatestMessage
    (&flight_data_collection_100hz__B.rtb_SourceBlock_o2_ov_k);

  // Outputs for Enabled SubSystem: '<S12>/Enabled Subsystem' incorporates:
  //   EnablePort: '<S36>/Enable'

  // Start for MATLABSystem: '<S12>/SourceBlock'
  if (p) {
    // SignalConversion generated from: '<S36>/In1'
    flight_data_collection_100hz__B.In1_p =
      flight_data_collection_100hz__B.rtb_SourceBlock_o2_ov_k;
  }

  // End of Start for MATLABSystem: '<S12>/SourceBlock'
  // End of Outputs for SubSystem: '<S12>/Enabled Subsystem'
  // End of Outputs for SubSystem: '<Root>/Subscribe13'

  // Outputs for Atomic SubSystem: '<Root>/Subscribe11'
  // MATLABSystem: '<S10>/SourceBlock'
  p = Sub_flight_data_collection_100hz_conver_to_c_1306.getLatestMessage
    (&flight_data_collection_100hz__B.rtb_SourceBlock_o2_b_c);

  // Outputs for Enabled SubSystem: '<S10>/Enabled Subsystem' incorporates:
  //   EnablePort: '<S34>/Enable'

  // Start for MATLABSystem: '<S10>/SourceBlock'
  if (p) {
    // SignalConversion generated from: '<S34>/In1'
    flight_data_collection_100hz__B.In1_m =
      flight_data_collection_100hz__B.rtb_SourceBlock_o2_b_c;
  }

  // End of Start for MATLABSystem: '<S10>/SourceBlock'
  // End of Outputs for SubSystem: '<S10>/Enabled Subsystem'
  // End of Outputs for SubSystem: '<Root>/Subscribe11'

  // Outputs for Atomic SubSystem: '<Root>/Subscribe10'
  // MATLABSystem: '<S9>/SourceBlock'
  p = Sub_flight_data_collection_100hz_conver_to_c_1305.getLatestMessage
    (&flight_data_collection_100hz__B.rtb_SourceBlock_o2_b_c);

  // Outputs for Enabled SubSystem: '<S9>/Enabled Subsystem' incorporates:
  //   EnablePort: '<S33>/Enable'

  // Start for MATLABSystem: '<S9>/SourceBlock'
  if (p) {
    // SignalConversion generated from: '<S33>/In1'
    flight_data_collection_100hz__B.In1_f =
      flight_data_collection_100hz__B.rtb_SourceBlock_o2_b_c;
  }

  // End of Start for MATLABSystem: '<S9>/SourceBlock'
  // End of Outputs for SubSystem: '<S9>/Enabled Subsystem'
  // End of Outputs for SubSystem: '<Root>/Subscribe10'

  // MATLAB Function: '<Root>/MATLAB Function' incorporates:
  //   MATLAB Function: '<Root>/MATLAB Function1'
  //   SignalConversion generated from: '<S4>/ SFunction '

  flight_data_collection_100hz__B.rtb_TmpSignalConversionAtSFun_f[0] =
    flight_data_collection_100hz__B.In1.AngularVelocity.Y *
    flight_data_collection_100hz__B.TmpSignalConversionAtSFun_i[2] -
    flight_data_collection_100hz__B.TmpSignalConversionAtSFun_i[1] *
    flight_data_collection_100hz__B.In1.AngularVelocity.Z;
  flight_data_collection_100hz__B.rtb_TmpSignalConversionAtSFun_f[1] =
    flight_data_collection_100hz__B.TmpSignalConversionAtSFun_i[0] *
    flight_data_collection_100hz__B.In1.AngularVelocity.Z -
    flight_data_collection_100hz__B.In1.AngularVelocity.X *
    flight_data_collection_100hz__B.TmpSignalConversionAtSFun_i[2];
  flight_data_collection_100hz__B.rtb_TmpSignalConversionAtSFun_f[2] =
    flight_data_collection_100hz__B.In1.AngularVelocity.X *
    flight_data_collection_100hz__B.TmpSignalConversionAtSFun_i[1] -
    flight_data_collection_100hz__B.TmpSignalConversionAtSFun_i[0] *
    flight_data_collection_100hz__B.In1.AngularVelocity.Y;

  // MATLAB Function: '<Root>/MATLAB Function1' incorporates:
  //   SignalConversion generated from: '<S4>/ SFunction '

  flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_tmp =
    flight_data_collection_100hz__B.In1.AngularVelocity.Y *
    flight_data_collection_100hz__B.b_b[2] -
    flight_data_collection_100hz__B.b_b[1] *
    flight_data_collection_100hz__B.In1.AngularVelocity.Z;
  flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_t_g =
    flight_data_collection_100hz__B.b_b[0] *
    flight_data_collection_100hz__B.In1.AngularVelocity.Z -
    flight_data_collection_100hz__B.In1.AngularVelocity.X *
    flight_data_collection_100hz__B.b_b[2];
  flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0__g1 =
    flight_data_collection_100hz__B.In1.AngularVelocity.X *
    flight_data_collection_100hz__B.b_b[1] -
    flight_data_collection_100hz__B.b_b[0] *
    flight_data_collection_100hz__B.In1.AngularVelocity.Y;

  // Sum: '<Root>/Sum'
  flight_data_collection_100hz__B.b_b[0] =
    flight_data_collection_100hz__B.In1_g.X;
  flight_data_collection_100hz__B.b_b[1] =
    flight_data_collection_100hz__B.In1_g.Y;
  flight_data_collection_100hz__B.b_b[2] =
    flight_data_collection_100hz__B.In1_g.Z;

  // BusAssignment: '<Root>/Bus Assignment' incorporates:
  //   MATLAB Function: '<Root>/MATLAB Function'

  flight_data_collection_100hz__B.BusAssignment.Data[0] =
    flight_data_collection_100hz__B.In1_j.Pose.Position.X;
  flight_data_collection_100hz__B.BusAssignment.Data[1] =
    flight_data_collection_100hz__B.In1_j.Pose.Position.Y;
  flight_data_collection_100hz__B.BusAssignment.Data[2] =
    flight_data_collection_100hz__B.In1_j.Pose.Position.Z;
  flight_data_collection_100hz__B.BusAssignment.Data[3] =
    flight_data_collection_100hz__B.In1_p.Twist.Linear.X;
  flight_data_collection_100hz__B.BusAssignment.Data[4] =
    flight_data_collection_100hz__B.In1_p.Twist.Linear.Y;
  flight_data_collection_100hz__B.BusAssignment.Data[5] =
    flight_data_collection_100hz__B.In1_p.Twist.Linear.Z;
  flight_data_collection_100hz__B.BusAssignment.Data[6] =
    flight_data_collection_100hz__B.In1.AngularVelocity.X;
  flight_data_collection_100hz__B.BusAssignment.Data[7] =
    flight_data_collection_100hz__B.In1.AngularVelocity.Y;
  flight_data_collection_100hz__B.BusAssignment.Data[8] =
    flight_data_collection_100hz__B.In1.AngularVelocity.Z;
  flight_data_collection_100hz__B.BusAssignment.Data[9] =
    flight_data_collection_100hz__B.Product3;
  flight_data_collection_100hz__B.BusAssignment.Data[10] =
    flight_data_collection_100hz__B.fcn3;
  flight_data_collection_100hz__B.BusAssignment.Data[11] =
    flight_data_collection_100hz__B.absx;
  flight_data_collection_100hz__B.BusAssignment.Data[12] =
    flight_data_collection_100hz__B.In1_m.X;
  flight_data_collection_100hz__B.BusAssignment.Data[13] =
    flight_data_collection_100hz__B.In1_m.Y;
  flight_data_collection_100hz__B.BusAssignment.Data[14] =
    flight_data_collection_100hz__B.In1_m.Z;
  flight_data_collection_100hz__B.BusAssignment.Data[15] =
    flight_data_collection_100hz__B.In1_f.X;
  flight_data_collection_100hz__B.BusAssignment.Data[16] =
    flight_data_collection_100hz__B.In1_f.Y;
  flight_data_collection_100hz__B.BusAssignment.Data[17] =
    flight_data_collection_100hz__B.In1_f.Z;
  for (c_k = 0; c_k < 3; c_k++) {
    // BusAssignment: '<Root>/Bus Assignment' incorporates:
    //   MATLAB Function: '<Root>/MATLAB Function'
    //   MATLAB Function: '<Root>/MATLAB Function1'
    //   Sum: '<Root>/Sum'

    flight_data_collection_100hz__B.absx =
      flight_data_collection_100hz__B.MB[c_k];
    flight_data_collection_100hz__B.BusAssignment.Data[c_k + 18] =
      flight_data_collection_100hz__B.absx;
    flight_data_collection_100hz__B.BusAssignment.Data[c_k + 21] =
      flight_data_collection_100hz__B.FB[c_k];
    flight_data_collection_100hz__B.BusAssignment.Data[c_k + 24] = ((a[c_k + 3] *
      flight_data_collection_100hz__B.Product2 + a[c_k] *
      flight_data_collection_100hz__B.Product1) + a[c_k + 6] *
      flight_data_collection_100hz__B.r_dot) +
      flight_data_collection_100hz__B.rtb_TmpSignalConversionAtSFun_f[c_k];
    flight_data_collection_100hz__B.BusAssignment.Data[c_k + 27] =
      (flight_data_collection_100hz__B.absx - ((a_0[c_k + 3] *
         flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_t_g +
         a_0[c_k] *
         flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0_tmp) +
        a_0[c_k + 6] *
        flight_data_collection_100hz__B.rtb_VectorConcatenate_idx_0__g1) *
       flight_data_collection_100hz__B.fcn5) +
      flight_data_collection_100hz__B.b_b[c_k];
  }

  // BusAssignment: '<Root>/Bus Assignment' incorporates:
  //   Constant: '<Root>/Constant'

  flight_data_collection_100hz__B.BusAssignment.Data_SL_Info.CurrentLength =
    flight_data_collection_100hz__P.Constant_Value_i;

  // Outputs for Atomic SubSystem: '<Root>/Publish'
  // MATLABSystem: '<S6>/SinkBlock'
  Pub_flight_data_collection_100hz_conver_to_c_1941.publish
    (&flight_data_collection_100hz__B.BusAssignment);

  // End of Outputs for SubSystem: '<Root>/Publish'
}

// Model initialize function
void flight_data_collection::initialize()
{
  // Registration code

  // initialize non-finites
  rt_InitInfAndNaN(sizeof(real_T));

  {
    int32_T i;
    char_T b_zeroDelimTopic_1[23];
    char_T b_zeroDelimTopic_0[17];
    char_T b_zeroDelimTopic[15];
    static const char_T b_zeroDelimTopic_2[30] = "/my/octocopter3/motor_speed/0";
    static const char_T b_zeroDelimTopic_3[30] = "/my/octocopter3/motor_speed/1";
    static const char_T b_zeroDelimTopic_4[30] = "/my/octocopter3/motor_speed/2";
    static const char_T b_zeroDelimTopic_5[30] = "/my/octocopter3/motor_speed/3";
    static const char_T b_zeroDelimTopic_6[30] = "/my/octocopter3/motor_speed/4";
    static const char_T b_zeroDelimTopic_7[30] = "/my/octocopter3/motor_speed/5";
    static const char_T b_zeroDelimTopic_8[30] = "/my/octocopter3/motor_speed/6";
    static const char_T b_zeroDelimTopic_9[30] = "/my/octocopter3/motor_speed/7";
    static const char_T b_zeroDelimTopic_a[15] = "/wind_gust_pub";
    static const char_T b_zeroDelimTopic_b[17] = "/mavros/imu/data";
    static const char_T b_zeroDelimTopic_c[28] = "/mavros/local_position/pose";
    static const char_T b_zeroDelimTopic_d[38] =
      "/mavros/local_position/velocity_local";
    static const char_T b_zeroDelimTopic_e[15] = "/torque_vector";
    static const char_T b_zeroDelimTopic_f[15] = "/thrust_vector";
    static const char_T b_zeroDelimTopic_g[23] = "/flight_data_log_100hz";

    // SystemInitialize for Atomic SubSystem: '<Root>/Subscribe'
    // SystemInitialize for Enabled SubSystem: '<S8>/Enabled Subsystem'
    // SystemInitialize for SignalConversion generated from: '<S32>/In1' incorporates:
    //   Outport: '<S32>/Out1'

    flight_data_collection_100hz__B.In1_l =
      flight_data_collection_100hz__P.Out1_Y0_lp;

    // End of SystemInitialize for SubSystem: '<S8>/Enabled Subsystem'

    // Start for MATLABSystem: '<S8>/SourceBlock'
    flight_data_collection_100hz_DW.obj_a.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj_a.isInitialized = 1;
    for (i = 0; i < 30; i++) {
      flight_data_collection_100hz__B.b_zeroDelimTopic_b[i] =
        b_zeroDelimTopic_2[i];
    }

    Sub_flight_data_collection_100hz_conver_to_c_1138.createSubscriber
      (&flight_data_collection_100hz__B.b_zeroDelimTopic_b[0], 1);
    flight_data_collection_100hz_DW.obj_a.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S8>/SourceBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Subscribe'

    // SystemInitialize for Atomic SubSystem: '<Root>/Subscribe3'
    // SystemInitialize for Enabled SubSystem: '<S15>/Enabled Subsystem'
    // SystemInitialize for SignalConversion generated from: '<S39>/In1' incorporates:
    //   Outport: '<S39>/Out1'

    flight_data_collection_100hz__B.In1_im =
      flight_data_collection_100hz__P.Out1_Y0_gi;

    // End of SystemInitialize for SubSystem: '<S15>/Enabled Subsystem'

    // Start for MATLABSystem: '<S15>/SourceBlock'
    flight_data_collection_100hz_DW.obj_gq.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj_gq.isInitialized = 1;
    for (i = 0; i < 30; i++) {
      flight_data_collection_100hz__B.b_zeroDelimTopic_b[i] =
        b_zeroDelimTopic_3[i];
    }

    Sub_flight_data_collection_100hz_conver_to_c_1139.createSubscriber
      (&flight_data_collection_100hz__B.b_zeroDelimTopic_b[0], 1);
    flight_data_collection_100hz_DW.obj_gq.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S15>/SourceBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Subscribe3'

    // SystemInitialize for Atomic SubSystem: '<Root>/Subscribe4'
    // SystemInitialize for Enabled SubSystem: '<S16>/Enabled Subsystem'
    // SystemInitialize for SignalConversion generated from: '<S40>/In1' incorporates:
    //   Outport: '<S40>/Out1'

    flight_data_collection_100hz__B.In1_a =
      flight_data_collection_100hz__P.Out1_Y0_b;

    // End of SystemInitialize for SubSystem: '<S16>/Enabled Subsystem'

    // Start for MATLABSystem: '<S16>/SourceBlock'
    flight_data_collection_100hz_DW.obj_o.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj_o.isInitialized = 1;
    for (i = 0; i < 30; i++) {
      flight_data_collection_100hz__B.b_zeroDelimTopic_b[i] =
        b_zeroDelimTopic_4[i];
    }

    Sub_flight_data_collection_100hz_conver_to_c_1140.createSubscriber
      (&flight_data_collection_100hz__B.b_zeroDelimTopic_b[0], 1);
    flight_data_collection_100hz_DW.obj_o.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S16>/SourceBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Subscribe4'

    // SystemInitialize for Atomic SubSystem: '<Root>/Subscribe5'
    // SystemInitialize for Enabled SubSystem: '<S17>/Enabled Subsystem'
    // SystemInitialize for SignalConversion generated from: '<S41>/In1' incorporates:
    //   Outport: '<S41>/Out1'

    flight_data_collection_100hz__B.In1_c =
      flight_data_collection_100hz__P.Out1_Y0_a;

    // End of SystemInitialize for SubSystem: '<S17>/Enabled Subsystem'

    // Start for MATLABSystem: '<S17>/SourceBlock'
    flight_data_collection_100hz_DW.obj_i.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj_i.isInitialized = 1;
    for (i = 0; i < 30; i++) {
      flight_data_collection_100hz__B.b_zeroDelimTopic_b[i] =
        b_zeroDelimTopic_5[i];
    }

    Sub_flight_data_collection_100hz_conver_to_c_1141.createSubscriber
      (&flight_data_collection_100hz__B.b_zeroDelimTopic_b[0], 1);
    flight_data_collection_100hz_DW.obj_i.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S17>/SourceBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Subscribe5'

    // SystemInitialize for Atomic SubSystem: '<Root>/Subscribe6'
    // SystemInitialize for Enabled SubSystem: '<S18>/Enabled Subsystem'
    // SystemInitialize for SignalConversion generated from: '<S42>/In1' incorporates:
    //   Outport: '<S42>/Out1'

    flight_data_collection_100hz__B.In1_j3 =
      flight_data_collection_100hz__P.Out1_Y0_j;

    // End of SystemInitialize for SubSystem: '<S18>/Enabled Subsystem'

    // Start for MATLABSystem: '<S18>/SourceBlock'
    flight_data_collection_100hz_DW.obj_b.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj_b.isInitialized = 1;
    for (i = 0; i < 30; i++) {
      flight_data_collection_100hz__B.b_zeroDelimTopic_b[i] =
        b_zeroDelimTopic_6[i];
    }

    Sub_flight_data_collection_100hz_conver_to_c_1142.createSubscriber
      (&flight_data_collection_100hz__B.b_zeroDelimTopic_b[0], 1);
    flight_data_collection_100hz_DW.obj_b.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S18>/SourceBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Subscribe6'

    // SystemInitialize for Atomic SubSystem: '<Root>/Subscribe7'
    // SystemInitialize for Enabled SubSystem: '<S19>/Enabled Subsystem'
    // SystemInitialize for SignalConversion generated from: '<S43>/In1' incorporates:
    //   Outport: '<S43>/Out1'

    flight_data_collection_100hz__B.In1_d =
      flight_data_collection_100hz__P.Out1_Y0_f;

    // End of SystemInitialize for SubSystem: '<S19>/Enabled Subsystem'

    // Start for MATLABSystem: '<S19>/SourceBlock'
    flight_data_collection_100hz_DW.obj_ng.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj_ng.isInitialized = 1;
    for (i = 0; i < 30; i++) {
      flight_data_collection_100hz__B.b_zeroDelimTopic_b[i] =
        b_zeroDelimTopic_7[i];
    }

    Sub_flight_data_collection_100hz_conver_to_c_1143.createSubscriber
      (&flight_data_collection_100hz__B.b_zeroDelimTopic_b[0], 1);
    flight_data_collection_100hz_DW.obj_ng.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S19>/SourceBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Subscribe7'

    // SystemInitialize for Atomic SubSystem: '<Root>/Subscribe8'
    // SystemInitialize for Enabled SubSystem: '<S20>/Enabled Subsystem'
    // SystemInitialize for SignalConversion generated from: '<S44>/In1' incorporates:
    //   Outport: '<S44>/Out1'

    flight_data_collection_100hz__B.In1_i =
      flight_data_collection_100hz__P.Out1_Y0_h;

    // End of SystemInitialize for SubSystem: '<S20>/Enabled Subsystem'

    // Start for MATLABSystem: '<S20>/SourceBlock'
    flight_data_collection_100hz_DW.obj_n.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj_n.isInitialized = 1;
    for (i = 0; i < 30; i++) {
      flight_data_collection_100hz__B.b_zeroDelimTopic_b[i] =
        b_zeroDelimTopic_8[i];
    }

    Sub_flight_data_collection_100hz_conver_to_c_1144.createSubscriber
      (&flight_data_collection_100hz__B.b_zeroDelimTopic_b[0], 1);
    flight_data_collection_100hz_DW.obj_n.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S20>/SourceBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Subscribe8'

    // SystemInitialize for Atomic SubSystem: '<Root>/Subscribe9'
    // SystemInitialize for Enabled SubSystem: '<S21>/Enabled Subsystem'
    // SystemInitialize for SignalConversion generated from: '<S45>/In1' incorporates:
    //   Outport: '<S45>/Out1'

    flight_data_collection_100hz__B.In1_gs =
      flight_data_collection_100hz__P.Out1_Y0_fy;

    // End of SystemInitialize for SubSystem: '<S21>/Enabled Subsystem'

    // Start for MATLABSystem: '<S21>/SourceBlock'
    flight_data_collection_100hz_DW.obj_g.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj_g.isInitialized = 1;
    for (i = 0; i < 30; i++) {
      flight_data_collection_100hz__B.b_zeroDelimTopic_b[i] =
        b_zeroDelimTopic_9[i];
    }

    Sub_flight_data_collection_100hz_conver_to_c_1145.createSubscriber
      (&flight_data_collection_100hz__B.b_zeroDelimTopic_b[0], 1);
    flight_data_collection_100hz_DW.obj_g.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S21>/SourceBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Subscribe9'

    // SystemInitialize for Atomic SubSystem: '<Root>/Subscribe2'
    // SystemInitialize for Enabled SubSystem: '<S14>/Enabled Subsystem'
    // SystemInitialize for SignalConversion generated from: '<S38>/In1' incorporates:
    //   Outport: '<S38>/Out1'

    flight_data_collection_100hz__B.In1_g =
      flight_data_collection_100hz__P.Out1_Y0_d;

    // End of SystemInitialize for SubSystem: '<S14>/Enabled Subsystem'

    // Start for MATLABSystem: '<S14>/SourceBlock'
    flight_data_collection_100hz_DW.obj_h.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj_h.isInitialized = 1;
    for (i = 0; i < 15; i++) {
      b_zeroDelimTopic[i] = b_zeroDelimTopic_a[i];
    }

    Sub_flight_data_collection_100hz_conver_to_c_1606.createSubscriber
      (&b_zeroDelimTopic[0], 1);
    flight_data_collection_100hz_DW.obj_h.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S14>/SourceBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Subscribe2'

    // SystemInitialize for Atomic SubSystem: '<Root>/Subscribe14'
    // SystemInitialize for Enabled SubSystem: '<S13>/Enabled Subsystem'
    // SystemInitialize for SignalConversion generated from: '<S37>/In1' incorporates:
    //   Outport: '<S37>/Out1'

    flight_data_collection_100hz__B.In1 =
      flight_data_collection_100hz__P.Out1_Y0;

    // End of SystemInitialize for SubSystem: '<S13>/Enabled Subsystem'

    // Start for MATLABSystem: '<S13>/SourceBlock'
    flight_data_collection_100hz_DW.obj_j.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj_j.isInitialized = 1;
    for (i = 0; i < 17; i++) {
      b_zeroDelimTopic_0[i] = b_zeroDelimTopic_b[i];
    }

    Sub_flight_data_collection_100hz_conver_to_c_1935.createSubscriber
      (&b_zeroDelimTopic_0[0], 1);
    flight_data_collection_100hz_DW.obj_j.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S13>/SourceBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Subscribe14'

    // SystemInitialize for Atomic SubSystem: '<Root>/Subscribe12'
    // SystemInitialize for Enabled SubSystem: '<S11>/Enabled Subsystem'
    // SystemInitialize for SignalConversion generated from: '<S35>/In1' incorporates:
    //   Outport: '<S35>/Out1'

    flight_data_collection_100hz__B.In1_j =
      flight_data_collection_100hz__P.Out1_Y0_m;

    // End of SystemInitialize for SubSystem: '<S11>/Enabled Subsystem'

    // Start for MATLABSystem: '<S11>/SourceBlock'
    flight_data_collection_100hz_DW.obj_d.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj_d.isInitialized = 1;
    for (i = 0; i < 28; i++) {
      flight_data_collection_100hz__B.b_zeroDelimTopic_p[i] =
        b_zeroDelimTopic_c[i];
    }

    Sub_flight_data_collection_100hz_conver_to_c_1918.createSubscriber
      (&flight_data_collection_100hz__B.b_zeroDelimTopic_p[0], 1);
    flight_data_collection_100hz_DW.obj_d.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S11>/SourceBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Subscribe12'

    // SystemInitialize for Atomic SubSystem: '<Root>/Subscribe13'
    // SystemInitialize for Enabled SubSystem: '<S12>/Enabled Subsystem'
    // SystemInitialize for SignalConversion generated from: '<S36>/In1' incorporates:
    //   Outport: '<S36>/Out1'

    flight_data_collection_100hz__B.In1_p =
      flight_data_collection_100hz__P.Out1_Y0_g;

    // End of SystemInitialize for SubSystem: '<S12>/Enabled Subsystem'

    // Start for MATLABSystem: '<S12>/SourceBlock'
    flight_data_collection_100hz_DW.obj_k.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj_k.isInitialized = 1;
    for (i = 0; i < 38; i++) {
      flight_data_collection_100hz__B.b_zeroDelimTopic[i] = b_zeroDelimTopic_d[i];
    }

    Sub_flight_data_collection_100hz_conver_to_c_1930.createSubscriber
      (&flight_data_collection_100hz__B.b_zeroDelimTopic[0], 1);
    flight_data_collection_100hz_DW.obj_k.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S12>/SourceBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Subscribe13'

    // SystemInitialize for Atomic SubSystem: '<Root>/Subscribe11'
    // SystemInitialize for Enabled SubSystem: '<S10>/Enabled Subsystem'
    // SystemInitialize for SignalConversion generated from: '<S34>/In1' incorporates:
    //   Outport: '<S34>/Out1'

    flight_data_collection_100hz__B.In1_m =
      flight_data_collection_100hz__P.Out1_Y0_gv;

    // End of SystemInitialize for SubSystem: '<S10>/Enabled Subsystem'

    // Start for MATLABSystem: '<S10>/SourceBlock'
    flight_data_collection_100hz_DW.obj_e.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj_e.isInitialized = 1;
    for (i = 0; i < 15; i++) {
      b_zeroDelimTopic[i] = b_zeroDelimTopic_e[i];
    }

    Sub_flight_data_collection_100hz_conver_to_c_1306.createSubscriber
      (&b_zeroDelimTopic[0], 1);
    flight_data_collection_100hz_DW.obj_e.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S10>/SourceBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Subscribe11'

    // SystemInitialize for Atomic SubSystem: '<Root>/Subscribe10'
    // SystemInitialize for Enabled SubSystem: '<S9>/Enabled Subsystem'
    // SystemInitialize for SignalConversion generated from: '<S33>/In1' incorporates:
    //   Outport: '<S33>/Out1'

    flight_data_collection_100hz__B.In1_f =
      flight_data_collection_100hz__P.Out1_Y0_l;

    // End of SystemInitialize for SubSystem: '<S9>/Enabled Subsystem'

    // Start for MATLABSystem: '<S9>/SourceBlock'
    flight_data_collection_100hz_DW.obj_bm.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj_bm.isInitialized = 1;
    for (i = 0; i < 15; i++) {
      b_zeroDelimTopic[i] = b_zeroDelimTopic_f[i];
    }

    Sub_flight_data_collection_100hz_conver_to_c_1305.createSubscriber
      (&b_zeroDelimTopic[0], 1);
    flight_data_collection_100hz_DW.obj_bm.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S9>/SourceBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Subscribe10'

    // SystemInitialize for Atomic SubSystem: '<Root>/Publish'
    // Start for MATLABSystem: '<S6>/SinkBlock'
    flight_data_collection_100hz_DW.obj.matlabCodegenIsDeleted = false;
    flight_data_collection_100hz_DW.obj.isInitialized = 1;
    for (i = 0; i < 23; i++) {
      b_zeroDelimTopic_1[i] = b_zeroDelimTopic_g[i];
    }

    Pub_flight_data_collection_100hz_conver_to_c_1941.createPublisher
      (&b_zeroDelimTopic_1[0], 1);
    flight_data_collection_100hz_DW.obj.isSetupComplete = true;

    // End of Start for MATLABSystem: '<S6>/SinkBlock'
    // End of SystemInitialize for SubSystem: '<Root>/Publish'
  }
}

// Model terminate function
void flight_data_collection::terminate()
{
  // Terminate for Atomic SubSystem: '<Root>/Subscribe'
  // Terminate for MATLABSystem: '<S8>/SourceBlock'
  if (!flight_data_collection_100hz_DW.obj_a.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj_a.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S8>/SourceBlock'
  // End of Terminate for SubSystem: '<Root>/Subscribe'

  // Terminate for Atomic SubSystem: '<Root>/Subscribe3'
  // Terminate for MATLABSystem: '<S15>/SourceBlock'
  if (!flight_data_collection_100hz_DW.obj_gq.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj_gq.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S15>/SourceBlock'
  // End of Terminate for SubSystem: '<Root>/Subscribe3'

  // Terminate for Atomic SubSystem: '<Root>/Subscribe4'
  // Terminate for MATLABSystem: '<S16>/SourceBlock'
  if (!flight_data_collection_100hz_DW.obj_o.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj_o.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S16>/SourceBlock'
  // End of Terminate for SubSystem: '<Root>/Subscribe4'

  // Terminate for Atomic SubSystem: '<Root>/Subscribe5'
  // Terminate for MATLABSystem: '<S17>/SourceBlock'
  if (!flight_data_collection_100hz_DW.obj_i.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj_i.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S17>/SourceBlock'
  // End of Terminate for SubSystem: '<Root>/Subscribe5'

  // Terminate for Atomic SubSystem: '<Root>/Subscribe6'
  // Terminate for MATLABSystem: '<S18>/SourceBlock'
  if (!flight_data_collection_100hz_DW.obj_b.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj_b.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S18>/SourceBlock'
  // End of Terminate for SubSystem: '<Root>/Subscribe6'

  // Terminate for Atomic SubSystem: '<Root>/Subscribe7'
  // Terminate for MATLABSystem: '<S19>/SourceBlock'
  if (!flight_data_collection_100hz_DW.obj_ng.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj_ng.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S19>/SourceBlock'
  // End of Terminate for SubSystem: '<Root>/Subscribe7'

  // Terminate for Atomic SubSystem: '<Root>/Subscribe8'
  // Terminate for MATLABSystem: '<S20>/SourceBlock'
  if (!flight_data_collection_100hz_DW.obj_n.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj_n.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S20>/SourceBlock'
  // End of Terminate for SubSystem: '<Root>/Subscribe8'

  // Terminate for Atomic SubSystem: '<Root>/Subscribe9'
  // Terminate for MATLABSystem: '<S21>/SourceBlock'
  if (!flight_data_collection_100hz_DW.obj_g.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj_g.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S21>/SourceBlock'
  // End of Terminate for SubSystem: '<Root>/Subscribe9'

  // Terminate for Atomic SubSystem: '<Root>/Subscribe2'
  // Terminate for MATLABSystem: '<S14>/SourceBlock'
  if (!flight_data_collection_100hz_DW.obj_h.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj_h.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S14>/SourceBlock'
  // End of Terminate for SubSystem: '<Root>/Subscribe2'

  // Terminate for Atomic SubSystem: '<Root>/Subscribe14'
  // Terminate for MATLABSystem: '<S13>/SourceBlock'
  if (!flight_data_collection_100hz_DW.obj_j.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj_j.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S13>/SourceBlock'
  // End of Terminate for SubSystem: '<Root>/Subscribe14'

  // Terminate for Atomic SubSystem: '<Root>/Subscribe12'
  // Terminate for MATLABSystem: '<S11>/SourceBlock'
  if (!flight_data_collection_100hz_DW.obj_d.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj_d.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S11>/SourceBlock'
  // End of Terminate for SubSystem: '<Root>/Subscribe12'

  // Terminate for Atomic SubSystem: '<Root>/Subscribe13'
  // Terminate for MATLABSystem: '<S12>/SourceBlock'
  if (!flight_data_collection_100hz_DW.obj_k.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj_k.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S12>/SourceBlock'
  // End of Terminate for SubSystem: '<Root>/Subscribe13'

  // Terminate for Atomic SubSystem: '<Root>/Subscribe11'
  // Terminate for MATLABSystem: '<S10>/SourceBlock'
  if (!flight_data_collection_100hz_DW.obj_e.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj_e.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S10>/SourceBlock'
  // End of Terminate for SubSystem: '<Root>/Subscribe11'

  // Terminate for Atomic SubSystem: '<Root>/Subscribe10'
  // Terminate for MATLABSystem: '<S9>/SourceBlock'
  if (!flight_data_collection_100hz_DW.obj_bm.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj_bm.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S9>/SourceBlock'
  // End of Terminate for SubSystem: '<Root>/Subscribe10'

  // Terminate for Atomic SubSystem: '<Root>/Publish'
  // Terminate for MATLABSystem: '<S6>/SinkBlock'
  if (!flight_data_collection_100hz_DW.obj.matlabCodegenIsDeleted) {
    flight_data_collection_100hz_DW.obj.matlabCodegenIsDeleted = true;
  }

  // End of Terminate for MATLABSystem: '<S6>/SinkBlock'
  // End of Terminate for SubSystem: '<Root>/Publish'
}

// Constructor
flight_data_collection::flight_data_collection() :
  flight_data_collection_100hz__B(),
  flight_data_collection_100hz_DW(),
  flight_data_collection_100hz_M()
{
  // Currently there is no constructor body generated.
}

// Destructor
flight_data_collection::~flight_data_collection()
{
  // Currently there is no destructor body generated.
}

// Real-Time Model get method
flight_data_collection::RT_MODEL_flight_data_collecti_T * flight_data_collection::
  getRTM()
{
  return (&flight_data_collection_100hz_M);
}

//
// File trailer for generated code.
//
// [EOF]
//
