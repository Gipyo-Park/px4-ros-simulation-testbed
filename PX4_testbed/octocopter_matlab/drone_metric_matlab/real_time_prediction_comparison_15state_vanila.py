#!/usr/bin/env python3
import rospy
import numpy as np
import torch
import sys
import os
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from mpl_toolkits.mplot3d import Axes3D
from collections import deque
from geometry_msgs.msg import PoseStamped
from sensor_msgs.msg import Imu
from mavros_msgs.msg import State, RCOut
from tf.transformations import euler_from_quaternion
import threading
import csv
from datetime import datetime

# ✅ Vanilla Transformer 모델 import를 위한 경로 추가
sys.path.append('/home/hmcl/Downloads/PatchTST_deeplearning-vanilla-1/vanilla-transformer')
from model import Transformer  # 실제 모델 클래스명 (확인 필요)

class RealtimePatchTSTComparison:
    def __init__(self, checkpoint_path, seq_len=100, pred_len=25):
        """
        Args:
            checkpoint_path: checkpoint.pth 파일 경로
            seq_len: 입력 시퀀스 길이 (100)
            pred_len: 예측 길이 (25, 50, 75, 100 중 선택)
        """
        rospy.init_node('realtime_patchtst_comparison')
        
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        self.seq_len = seq_len
        self.pred_len = pred_len
        
        # 모델 구조 생성 및 가중치 로드
        self.model = self.load_model(checkpoint_path)
        
        # 모터/드론 파라미터 (C 행렬 계산용)
        self.setup_motor_parameters()
        
        # 데이터 버퍼
        self.max_buffer_size = 2000
        
        # 실시간 측정값 저장 (15차원)
        self.input_buffer = deque(maxlen=seq_len)
        
        # 결과 저장용
        self.actual_xyz = deque(maxlen=self.max_buffer_size)
        self.predicted_xyz = deque(maxlen=self.max_buffer_size)
        self.setpoint_xyz = deque(maxlen=self.max_buffer_size)
        self.timestamps = deque(maxlen=self.max_buffer_size)
        
        # ✅ 전체 예측 궤적 저장 추가 (pred_len-step)
        self.predicted_trajectory = deque(maxlen=self.max_buffer_size)  # (pred_len, 3) 저장
        
        # MSE 기록
        self.mse_x = deque(maxlen=self.max_buffer_size)
        self.mse_y = deque(maxlen=self.max_buffer_size)
        self.mse_z = deque(maxlen=self.max_buffer_size)
        
        # ✅ MAE 기록 추가
        self.mae_x = deque(maxlen=self.max_buffer_size)
        self.mae_y = deque(maxlen=self.max_buffer_size)
        self.mae_z = deque(maxlen=self.max_buffer_size)
        
        # 현재 상태 변수들
        self.current_state = State()
        self.current_phi = 0.0
        self.current_theta = 0.0
        self.current_psi = 0.0
        self.current_p = 0.0
        self.current_q = 0.0
        self.current_r = 0.0
        self.current_xyz = [0.0, 0.0, 0.0]
        self.current_setpoint = None
        self.current_pwm = np.zeros(8)
        
        # ROS 구독자
        self.state_sub = rospy.Subscriber("mavros/state", State, self.state_cb)
        self.imu_sub = rospy.Subscriber("mavros/imu/data", Imu, self.imu_cb)
        self.local_pos_sub = rospy.Subscriber("mavros/local_position/pose", PoseStamped, self.position_cb)
        self.setpoint_sub = rospy.Subscriber("mavros/setpoint_position/local", PoseStamped, self.setpoint_cb)
        self.rc_out_sub = rospy.Subscriber("mavros/rc/out", RCOut, self.rc_out_cb)
        
        self.start_time = rospy.Time.now()
        self.lock = threading.Lock()
        
        # 정규화 파라미터
        self.mean = None
        self.std = None
        
        # ✅ 로그 저장 디렉토리 설정
        self.model_type = "vanilla"
        self.log_dir = f"/home/hmcl/PX4_testbed/octocopter_matlab/drone_metric_matlab/prediction_logs/{self.model_type}/pred_len_{pred_len}"
        os.makedirs(self.log_dir, exist_ok=True)
        
        # 타임스탬프 생성
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        print(f"[INFO] Model loaded from {checkpoint_path}")
        print(f"[INFO] Device: {self.device}")
        print(f"[INFO] Sequence Length: {seq_len}, Prediction Length: {pred_len}")

    def load_model(self, checkpoint_path):
        """✅ Vanilla Transformer 모델 구조 생성 및 가중치 로드"""
        # vanilla-transformer/config.py와 동일한 하이퍼파라미터 사용
        from model import Transformer
        
        model = Transformer(
            src_vocab_size=1000,      # 연속 데이터에선 사용 안 함 (더미 값)
            trg_vocab_size=1000,      # 연속 데이터에선 사용 안 함 (더미 값)
            src_pad_idx=0,            # 연속 데이터에선 사용 안 함
            trg_pad_idx=0,            # 연속 데이터에선 사용 안 함
            embed_dim=128,            # d_model=128
            n_blocks=3,               # encoder/decoder layers=3
            n_heads=16,               # attention heads=16
            ff_hid_dim=512,           # feed-forward hidden dimension
            max_length=100,           # ✅ 학습 시 사용한 값과 일치 (200 → 100)
            dropout=0.2,              # dropout rate
            device=self.device,
            input_dim=15,             # 15개 입력 채널
            output_dim=15             # 15개 출력 채널
        ).to(self.device)
        
        # 가중치 로드
        checkpoint = torch.load(checkpoint_path, map_location=self.device, weights_only=False)
        model.load_state_dict(checkpoint)
        model.eval()
        
        print(f"[INFO] Vanilla Transformer model loaded successfully")
        print(f"[INFO] Model parameters: embed_dim=128, n_blocks=3, n_heads=16, max_length=100")
        return model

    def setup_motor_parameters(self):
        """모터 파라미터 및 C 행렬 설정"""
        # 실제 드론 파라미터
        self.Ct = -0.00053      # Thrust coefficient
        self.Cq = 0.0000169     # Torque coefficient
        self.L1 = 0.545         # 모터 암 길이 (m)
        self.L2 = 0.36          # 모터 암 길이 (m)
        self.L3 = 1.08          # 모터 암 길이 (m)
        
        # C 행렬 구성 (8x8 octocopter)
        # [f_z; u_p; u_q; u_r] = C * [omega1^2; omega2^2; ...; omega8^2]
        self.C = np.array([
            [-self.Ct, -self.Ct, -self.Ct, -self.Ct, -self.Ct, -self.Ct, -self.Ct, -self.Ct],
            [-self.Ct*self.L1, self.Ct*self.L1, -self.Ct*self.L1, -self.Ct*self.L1, 
             self.Ct*self.L1, self.Ct*self.L1, self.Ct*self.L1, -self.Ct*self.L1],
            [self.Ct*self.L3, -self.Ct*self.L3, self.Ct*self.L2, -self.Ct*self.L3, 
             self.Ct*self.L3, -self.Ct*self.L2, self.Ct*self.L2, -self.Ct*self.L2],
            [self.Cq, self.Cq, -self.Cq, -self.Cq, -self.Cq, -self.Cq, self.Cq, self.Cq]
        ])
        
        # C 역행렬 계산 (pseudo-inverse)
        self.C_inv = np.linalg.pinv(self.C)
        
        print(f"[INFO] Motor parameters loaded:")
        print(f"  Ct = {self.Ct}, Cq = {self.Cq}")
        print(f"  L1 = {self.L1}m, L2 = {self.L2}m, L3 = {self.L3}m")
        
    def pwm_to_rads(self, pwm_values):
        """PWM 값을 모터 각속도(rad/s)로 변환"""
        maxRotVelocity = 425.47  # rad/s
        PWM_MIN = 1100
        PWM_MAX = 2000
        
        rad_s_out = np.zeros(8)
        
        for i in range(8):
            pwm_value = float(pwm_values[i])
            
            # 정규화 (0.0 ~ 1.0)
            if pwm_value < PWM_MIN:
                normalized_input = 0.0
            elif pwm_value > PWM_MAX:
                normalized_input = 1.0
            else:
                normalized_input = (pwm_value - PWM_MIN) / (PWM_MAX - PWM_MIN)
            
            # rad/s로 변환
            rad_s_out[i] = normalized_input * maxRotVelocity
            
        return rad_s_out

    def motor_force_moment_calc(self, omega_motor_speed):
        """모터 속도로부터 힘과 모멘트 계산"""
        # omega^2 계산
        omega_squared = np.abs(omega_motor_speed) * np.abs(omega_motor_speed)
        
        # C 역행렬과 omega^2의 행렬곱
        result = self.C @ omega_squared
        
        # 결과 추출 (MATLAB 코드의 motorForceMomentCalc 함수와 동일)
        f_z = result[0]
        u_p = result[1]
        u_q = -result[2]  # 부호 반전
        u_r = -result[3]  # 부호 반전
        
        # f_x, f_y는 0으로 가정 (body frame에서 추력은 z축만)
        f_x = 0.0
        f_y = 0.0
        
        return u_p, u_q, u_r, f_x, f_y, f_z

    def state_cb(self, msg):
        self.current_state = msg

    def imu_cb(self, msg):
        """IMU 데이터에서 p, q, r 추출"""
        with self.lock:
            self.current_p = msg.angular_velocity.x
            self.current_q = msg.angular_velocity.y
            self.current_r = msg.angular_velocity.z

    def position_cb(self, msg):
        """위치 및 자세 데이터 수신"""
        with self.lock:
            # XYZ 위치
            x = msg.pose.position.x
            y = msg.pose.position.y
            z = msg.pose.position.z
            self.current_xyz = [x, y, z]
            
            # Quaternion을 Euler로 변환
            orientation = msg.pose.orientation
            quaternion = [orientation.x, orientation.y, orientation.z, orientation.w]
            phi, theta, psi = euler_from_quaternion(quaternion)
            
            self.current_phi = phi
            self.current_theta = theta
            self.current_psi = psi
            
            # 15차원 입력 벡터 구성
            self.update_input_buffer()

    def rc_out_cb(self, msg):
        """RC PWM 출력 수신"""
        with self.lock:
            self.current_pwm = np.array(msg.channels[:8])

    def setpoint_cb(self, msg):
        """목표 위치(setpoint) 수신"""
        with self.lock:
            self.current_setpoint = [
                msg.pose.position.x,
                msg.pose.position.y,
                msg.pose.position.z
            ]

    def update_input_buffer(self):
        """15차원 입력 벡터를 구성하여 버퍼에 추가"""
        # 1. 모터 속도 계산
        omega_motor = self.pwm_to_rads(self.current_pwm)
        
        # 2. 힘과 모멘트 계산
        u_p, u_q, u_r, f_x, f_y, f_z = self.motor_force_moment_calc(omega_motor)
        
        # 3. 15차원 벡터 구성
        # [phi, theta, psi, p, q, r, u_p, u_q, u_r, f_x, f_y, f_z, X, Y, Z]
        input_vector = [
            self.current_phi,
            self.current_theta,
            self.current_psi,
            self.current_p,
            self.current_q,
            self.current_r,
            u_p,
            u_q,
            u_r,
            f_x,
            f_y,
            f_z,
            self.current_xyz[0],
            self.current_xyz[1],
            self.current_xyz[2]
        ]
        
        # 4. 버퍼에 추가
        self.input_buffer.append(input_vector)
        
        # 5. 예측 수행
        if len(self.input_buffer) >= self.seq_len:
            self.perform_prediction()

    def perform_prediction(self):
        """✅ Vanilla Transformer 모델로 XYZ 예측 (Auto-regressive)"""
        try:
            # 입력 데이터 준비 [seq_len, 15]
            input_seq = np.array(list(self.input_buffer))
            
            # 정규화
            if self.mean is None:
                self.mean = input_seq.mean(axis=0)
                self.std = input_seq.std(axis=0) + 1e-8
            
            input_normalized = (input_seq - self.mean) / self.std
            
            # 텐서 변환: (batch, seq_len, n_vars)
            src_tensor = torch.FloatTensor(input_normalized).unsqueeze(0).to(self.device)
            
            # ✅ Auto-regressive 예측 루프
            with torch.no_grad():
                # 초기 decoder input: 마지막 encoder 입력값
                trg_input = src_tensor[:, -1:, :]  # (1, 1, 15)
                predictions = []
                
                for step in range(self.pred_len):
                    # Transformer forward: forward(src, trg)
                    output = self.model(src_tensor, trg_input)  # (1, current_len, 15)
                    
                    # 마지막 예측값 추출
                    next_pred = output[:, -1:, :]  # (1, 1, 15)
                    predictions.append(next_pred.cpu().numpy()[0, 0, :])
                    
                    # 다음 step의 입력으로 사용
                    trg_input = torch.cat([trg_input, next_pred], dim=1)  # (1, step+2, 15)
            
            # 역정규화
            predicted_all = np.array(predictions) * self.std + self.mean  # (pred_len, 15)
            
            # XYZ만 추출 (마지막 3개 컬럼: 인덱스 12, 13, 14)
            predicted_xyz = predicted_all[:, 12:15]  # (pred_len, 3)
            
            # ✅ 전체 예측 궤적 저장 (pred_len-step)
            self.predicted_trajectory.append(predicted_xyz.copy())
            
            # 첫 번째 예측값 사용 (1-step ahead)
            predicted_xyz_current = predicted_xyz[0]  # (3,)
            
            # 결과 저장
            current_time = (rospy.Time.now() - self.start_time).to_sec()
            self.timestamps.append(current_time)
            self.actual_xyz.append(self.current_xyz.copy())
            self.predicted_xyz.append(predicted_xyz_current.tolist())
            
            if self.current_setpoint is not None:
                self.setpoint_xyz.append(self.current_setpoint.copy())
            else:
                self.setpoint_xyz.append(self.current_xyz.copy())
            
            # MSE 계산
            mse_x = (predicted_xyz_current[0] - self.current_xyz[0]) ** 2
            mse_y = (predicted_xyz_current[1] - self.current_xyz[1]) ** 2
            mse_z = (predicted_xyz_current[2] - self.current_xyz[2]) ** 2
            
            self.mse_x.append(mse_x)
            self.mse_y.append(mse_y)
            self.mse_z.append(mse_z)
            
            # ✅ MAE 계산
            mae_x = abs(predicted_xyz_current[0] - self.current_xyz[0])
            mae_y = abs(predicted_xyz_current[1] - self.current_xyz[1])
            mae_z = abs(predicted_xyz_current[2] - self.current_xyz[2])
            
            self.mae_x.append(mae_x)
            self.mae_y.append(mae_y)
            self.mae_z.append(mae_z)
            
        except Exception as e:
            print(f"[ERROR] Prediction failed: {e}")
            import traceback
            traceback.print_exc()

    def save_metrics_to_csv(self):
        """✅ MSE, MAE, RMSE 메트릭을 CSV 파일로 저장"""
        if len(self.mse_x) == 0:
            print("[WARNING] No MSE data to save - no predictions made yet")
            return
        
        try:
            # ✅ RMSE 계산 추가
            rmse_x = float(np.sqrt(np.mean(self.mse_x)))
            rmse_y = float(np.sqrt(np.mean(self.mse_y)))
            rmse_z = float(np.sqrt(np.mean(self.mse_z)))
            rmse_total = float(np.sqrt(np.mean(self.mse_x) + np.mean(self.mse_y) + np.mean(self.mse_z)))
            
            # 메트릭 계산
            metrics = {
                'MSE_X': float(np.mean(self.mse_x)),
                'MSE_Y': float(np.mean(self.mse_y)),
                'MSE_Z': float(np.mean(self.mse_z)),
                'MSE_Total': float(np.mean(self.mse_x) + np.mean(self.mse_y) + np.mean(self.mse_z)),
                'MAE_X': float(np.mean(self.mae_x)),
                'MAE_Y': float(np.mean(self.mae_y)),
                'MAE_Z': float(np.mean(self.mae_z)),
                'MAE_Total': float(np.mean(self.mae_x) + np.mean(self.mae_y) + np.mean(self.mae_z)),
                'RMSE_X': rmse_x,
                'RMSE_Y': rmse_y,
                'RMSE_Z': rmse_z,
                'RMSE_Total': rmse_total,
                'Samples': len(self.actual_xyz),
                'Model_Type': self.model_type,
                'Pred_Length': self.pred_len,
                'Seq_Length': self.seq_len,
                'Timestamp': self.timestamp
            }
            
            # CSV 파일 저장
            csv_filename = os.path.join(self.log_dir, f"metrics_{self.timestamp}.csv")
            print(f"[DEBUG] Attempting to save metrics to: {csv_filename}")
            
            with open(csv_filename, 'w', newline='') as csvfile:
                writer = csv.DictWriter(csvfile, fieldnames=metrics.keys())
                writer.writeheader()
                writer.writerow(metrics)
            
            print(f"[INFO] ✅ Metrics saved to {csv_filename}")
            
            # ✅ 시계열 데이터에도 RMSE 추가
            timeseries_filename = os.path.join(self.log_dir, f"timeseries_{self.timestamp}.csv")
            print(f"[DEBUG] Attempting to save time-series to: {timeseries_filename}")
            
            with open(timeseries_filename, 'w', newline='') as csvfile:
                fieldnames = ['timestamp', 'actual_x', 'actual_y', 'actual_z', 
                             'predicted_x', 'predicted_y', 'predicted_z',
                             'mse_x', 'mse_y', 'mse_z', 
                             'mae_x', 'mae_y', 'mae_z',
                             'rmse_x', 'rmse_y', 'rmse_z']
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                writer.writeheader()
                
                for i in range(len(self.actual_xyz)):
                    writer.writerow({
                        'timestamp': float(self.timestamps[i]),
                        'actual_x': float(self.actual_xyz[i][0]),
                        'actual_y': float(self.actual_xyz[i][1]),
                        'actual_z': float(self.actual_xyz[i][2]),
                        'predicted_x': float(self.predicted_xyz[i][0]),
                        'predicted_y': float(self.predicted_xyz[i][1]),
                        'predicted_z': float(self.predicted_xyz[i][2]),
                        'mse_x': float(self.mse_x[i]),
                        'mse_y': float(self.mse_y[i]),
                        'mse_z': float(self.mse_z[i]),
                        'mae_x': float(self.mae_x[i]),
                        'mae_y': float(self.mae_y[i]),
                        'mae_z': float(self.mae_z[i]),
                        'rmse_x': float(np.sqrt(self.mse_x[i])),
                        'rmse_y': float(np.sqrt(self.mse_y[i])),
                        'rmse_z': float(np.sqrt(self.mse_z[i]))
                    })
            
            print(f"[INFO] ✅ Time-series data saved to {timeseries_filename}")
            
        except Exception as e:
            print(f"[ERROR] Failed in save_metrics_to_csv: {e}")
            import traceback
            traceback.print_exc()

    def start_visualization(self):
        """실시간 시각화 - 여러 개의 figure로 분리"""
        # 화면 크기 가져오기
        try:
            import tkinter as tk
            root = tk.Tk()
            screen_width = 1920
            screen_height = 1080
            root.destroy()
        except:
            # 기본값 사용
            screen_width = 1920
            screen_height = 1080
        
        # 창 크기 계산 (화면의 45%씩 사용)
        fig_width = int(screen_width * 0.45 / 100)  # inch 단위
        fig_height = int(screen_height * 0.45 / 100)
        
        # Figure 1: X, Y, Z 개별 플롯
        fig_xyz = plt.figure(figsize=(fig_width, fig_height))
        ax_x = fig_xyz.add_subplot(3, 1, 1)
        ax_y = fig_xyz.add_subplot(3, 1, 2)
        ax_z = fig_xyz.add_subplot(3, 1, 3)
        
        # Figure 2: 3D 궤적
        fig_3d = plt.figure(figsize=(fig_width * 0.8, fig_height * 0.8))
        ax_3d = fig_3d.add_subplot(111, projection='3d')
        
        # Figure 3: MSE 플롯
        fig_mse = plt.figure(figsize=(fig_width, fig_height))
        ax_mse_x = fig_mse.add_subplot(2, 2, 1)
        ax_mse_y = fig_mse.add_subplot(2, 2, 2)
        ax_mse_z = fig_mse.add_subplot(2, 2, 3)
        ax_mse_total = fig_mse.add_subplot(2, 2, 4)
        
        # ✅ Figure 4: 미래 pred_len-step 예측 궤적 (NEW!)
        fig_future = plt.figure(figsize=(fig_width, fig_height))
        ax_future_3d = fig_future.add_subplot(2, 2, 1, projection='3d')
        ax_future_x = fig_future.add_subplot(2, 2, 2)
        ax_future_y = fig_future.add_subplot(2, 2, 3)
        ax_future_z = fig_future.add_subplot(2, 2, 4)
        
        def update_xyz(frame):
            """X, Y, Z 위치 업데이트"""
            with self.lock:
                if len(self.actual_xyz) < 2:
                    return
                
                times = np.array(self.timestamps)
                actual = np.array(self.actual_xyz)
                predicted = np.array(self.predicted_xyz)
                setpoint = np.array(self.setpoint_xyz)
                
                # X, Y, Z 개별 플롯
                for ax, idx, label in zip([ax_x, ax_y, ax_z], [0, 1, 2], ['X', 'Y', 'Z']):
                    ax.clear()
                    ax.plot(times, actual[:, idx], 'b-', label='Actual', linewidth=1.5)
                    ax.plot(times, predicted[:, idx], 'r--', label='Predicted', linewidth=1.5)
                    ax.plot(times, setpoint[:, idx], 'g:', label='Setpoint', linewidth=1.2)
                    ax.set_xlabel('Time (s)', fontsize=9)
                    ax.set_ylabel(f'{label} (m)', fontsize=9)
                    ax.set_title(f'{label}-axis Position', fontsize=10, fontweight='bold')
                    ax.legend(loc='upper right', fontsize=8, framealpha=0.9)
                    ax.grid(True, alpha=0.3, linewidth=0.5)
                    ax.tick_params(labelsize=8)
                
                fig_xyz.suptitle('Position Tracking: X, Y, Z Components', 
                               fontsize=11, fontweight='bold')
        
        def update_3d(frame):
            """3D 궤적 업데이트"""
            with self.lock:
                if len(self.actual_xyz) < 2:
                    return
                
                actual = np.array(self.actual_xyz)
                predicted = np.array(self.predicted_xyz)
                setpoint = np.array(self.setpoint_xyz)
                
                ax_3d.clear()
                
                # 실제 궤적
                ax_3d.plot(actual[:, 0], actual[:, 1], actual[:, 2], 
                          'b-', label='Actual', linewidth=2, alpha=0.8)
                
                # 1-step 예측 궤적
                ax_3d.plot(predicted[:, 0], predicted[:, 1], predicted[:, 2], 
                          'r--', label='Predicted (1-step)', linewidth=2, alpha=0.8)
                
                # Setpoint
                ax_3d.plot(setpoint[:, 0], setpoint[:, 1], setpoint[:, 2], 
                          'g:', label='Setpoint', linewidth=1.5, alpha=0.6)
                
                # 시작점 표시
                ax_3d.scatter(actual[0, 0], actual[0, 1], actual[0, 2], 
                             c='blue', marker='o', s=80, label='Start', zorder=5)
                # 현재점 표시
                ax_3d.scatter(actual[-1, 0], actual[-1, 1], actual[-1, 2], 
                             c='red', marker='*', s=150, label='Current', zorder=5)
                
                ax_3d.set_xlabel('X (m)', fontsize=9)
                ax_3d.set_ylabel('Y (m)', fontsize=9)
                ax_3d.set_zlabel('Z (m)', fontsize=9)
                ax_3d.set_title('3D Trajectory', fontsize=10, fontweight='bold')
                ax_3d.legend(loc='upper right', fontsize=7, framealpha=0.9)
                ax_3d.grid(True, alpha=0.3)
                ax_3d.tick_params(labelsize=8)
                
                # 축 범위 자동 조정
                ax_3d.set_box_aspect([1,1,1])
        
        def update_mse(frame):
            """MSE 플롯 업데이트"""
            with self.lock:
                if len(self.mse_x) < 2:
                    return
                
                times = np.array(self.timestamps)
                mse_times = times[-len(self.mse_x):]
                
                # 개별 MSE
                for ax, mse_data, label, color in zip(
                    [ax_mse_x, ax_mse_y, ax_mse_z],
                    [self.mse_x, self.mse_y, self.mse_z],
                    ['X', 'Y', 'Z'],
                    ['red', 'green', 'blue']
                ):
                    ax.clear()
                    ax.plot(mse_times, mse_data, color=color, linewidth=1.5, alpha=0.7)
                    mean_val = np.mean(mse_data)
                    ax.axhline(y=mean_val, color='black', 
                              linestyle='--', linewidth=0.8, alpha=0.5, label=f'Mean: {mean_val:.4f}')
                    ax.set_xlabel('Time (s)', fontsize=8)
                    ax.set_ylabel(f'MSE {label}', fontsize=8)
                    ax.set_title(f'{label}-axis MSE', fontsize=9, fontweight='bold')
                    ax.legend(loc='upper right', fontsize=7, framealpha=0.9)
                    ax.grid(True, alpha=0.3, linewidth=0.5)
                    ax.tick_params(labelsize=7)
                
                # 전체 MSE
                total_mse = np.array(self.mse_x) + np.array(self.mse_y) + np.array(self.mse_z)
                ax_mse_total.clear()
                ax_mse_total.plot(mse_times, total_mse, color='purple', linewidth=1.5, alpha=0.8)
                mean_total = np.mean(total_mse)
                ax_mse_total.axhline(y=mean_total, color='black', 
                                   linestyle='--', linewidth=0.8, alpha=0.5, 
                                   label=f'Mean: {mean_total:.4f}')
                ax_mse_total.set_xlabel('Time (s)', fontsize=8)
                ax_mse_total.set_ylabel('Total MSE', fontsize=8)
                ax_mse_total.set_title('Total Position MSE', fontsize=9, fontweight='bold')
                ax_mse_total.legend(loc='upper right', fontsize=7, framealpha=0.9)
                ax_mse_total.grid(True, alpha=0.3, linewidth=0.5)
                ax_mse_total.tick_params(labelsize=7)
                
                fig_mse.suptitle('Mean Squared Error Analysis', 
                               fontsize=11, fontweight='bold')
        
        def update_future(frame):
            """✅ 미래 pred_len-step 예측 궤적 업데이트"""
            with self.lock:
                if len(self.predicted_trajectory) < 1:
                    return
                
                future_traj = self.predicted_trajectory[-1]  # (pred_len, 3)
                step_indices = np.arange(1, self.pred_len + 1)
                
                # 3D 미래 궤적
                ax_future_3d.clear()
                ax_future_3d.plot(future_traj[:, 0], future_traj[:, 1], future_traj[:, 2],
                                 'orange', linewidth=2.5, marker='o', markersize=4)
                ax_future_3d.scatter(future_traj[0, 0], future_traj[0, 1], future_traj[0, 2],
                                   c='green', marker='o', s=100, label='t+1', zorder=5)
                ax_future_3d.scatter(future_traj[-1, 0], future_traj[-1, 1], future_traj[-1, 2],
                                   c='red', marker='*', s=150, label=f't+{self.pred_len}', zorder=5)
                ax_future_3d.set_xlabel('X (m)', fontsize=8)
                ax_future_3d.set_ylabel('Y (m)', fontsize=8)
                ax_future_3d.set_zlabel('Z (m)', fontsize=8)
                ax_future_3d.set_title(f'{self.pred_len}-Step Future Trajectory', fontsize=9, fontweight='bold')
                ax_future_3d.legend(fontsize=7)
                ax_future_3d.grid(True, alpha=0.3)
                
                # X, Y, Z 개별 미래 예측
                for ax, idx, label, color in zip(
                    [ax_future_x, ax_future_y, ax_future_z],
                    [0, 1, 2],
                    ['X', 'Y', 'Z'],
                    ['red', 'green', 'blue']
                ):
                    ax.clear()
                    ax.plot(step_indices, future_traj[:, idx], color=color, 
                           linewidth=2, marker='o', markersize=4)
                    ax.set_xlabel('Future Step', fontsize=8)
                    ax.set_ylabel(f'{label} (m)', fontsize=8)
                    ax.set_title(f'{label}-axis Future Prediction', fontsize=9, fontweight='bold')
                    ax.grid(True, alpha=0.3)
                    ax.tick_params(labelsize=7)
                
                fig_future.suptitle(f'{self.pred_len}-Step Ahead Prediction', 
                                  fontsize=11, fontweight='bold')
        
        # 레이아웃 자동 조정
        fig_xyz.tight_layout(rect=[0, 0.01, 1, 0.97], pad=2.0, h_pad=1.5)
        fig_3d.tight_layout(rect=[0, 0.01, 1, 0.97], pad=1.5)
        fig_mse.tight_layout(rect=[0, 0.01, 1, 0.97], pad=2.0, h_pad=1.5, w_pad=2.0)
        fig_future.tight_layout(rect=[0, 0.01, 1, 0.97], pad=2.0, h_pad=1.5, w_pad=2.0)
        
        # Figure 위치 자동 배치
        try:
            # Figure 1: 왼쪽 위
            mng_xyz = fig_xyz.canvas.manager
            if hasattr(mng_xyz, 'window'):
                if hasattr(mng_xyz.window, 'wm_geometry'):
                    width1 = int(screen_width * 0.48)
                    height1 = int(screen_height * 0.48)
                    mng_xyz.window.wm_geometry(f"{width1}x{height1}+0+0")
                elif hasattr(mng_xyz.window, 'setGeometry'):
                    mng_xyz.window.setGeometry(0, 0, 
                                              int(screen_width * 0.48), 
                                              int(screen_height * 0.48))
            
            # Figure 2: 오른쪽 위
            mng_3d = fig_3d.canvas.manager
            if hasattr(mng_3d, 'window'):
                if hasattr(mng_3d.window, 'wm_geometry'):
                    width2 = int(screen_width * 0.48)
                    height2 = int(screen_height * 0.48)
                    x_pos = int(screen_width * 0.51)
                    mng_3d.window.wm_geometry(f"{width2}x{height2}+{x_pos}+0")
                elif hasattr(mng_3d.window, 'setGeometry'):
                    mng_3d.window.setGeometry(int(screen_width * 0.51), 0,
                                             int(screen_width * 0.48),
                                             int(screen_height * 0.48))
            
            # Figure 3: 왼쪽 아래
            mng_mse = fig_mse.canvas.manager
            if hasattr(mng_mse, 'window'):
                if hasattr(mng_mse.window, 'wm_geometry'):
                    width3 = int(screen_width * 0.48)
                    height3 = int(screen_height * 0.48)
                    y_pos = int(screen_height * 0.51)
                    mng_mse.window.wm_geometry(f"{width3}x{height3}+0+{y_pos}")
                elif hasattr(mng_mse.window, 'setGeometry'):
                    mng_mse.window.setGeometry(0, int(screen_height * 0.51),
                                              int(screen_width * 0.48),
                                              int(screen_height * 0.48))
            
            # ✅ Figure 4: 오른쪽 아래
            mng_future = fig_future.canvas.manager
            if hasattr(mng_future, 'window'):
                if hasattr(mng_future.window, 'wm_geometry'):
                    width4 = int(screen_width * 0.48)
                    height4 = int(screen_height * 0.48)
                    x_pos = int(screen_width * 0.51)
                    y_pos = int(screen_height * 0.51)
                    mng_future.window.wm_geometry(f"{width4}x{height4}+{x_pos}+{y_pos}")
                elif hasattr(mng_future.window, 'setGeometry'):
                    mng_future.window.setGeometry(int(screen_width * 0.51), 
                                                 int(screen_height * 0.51),
                                                 int(screen_width * 0.48),
                                                 int(screen_height * 0.48))
        except Exception as e:
            print(f"[WARNING] Could not set window positions: {e}")
        
        # 애니메이션 시작 (변수에 할당하여 가비지 컬렉션 방지)
        self.ani_xyz = FuncAnimation(fig_xyz, update_xyz, interval=100, cache_frame_data=False)
        self.ani_3d = FuncAnimation(fig_3d, update_3d, interval=100, cache_frame_data=False)
        self.ani_mse = FuncAnimation(fig_mse, update_mse, interval=100, cache_frame_data=False)
        self.ani_future = FuncAnimation(fig_future, update_future, interval=100, cache_frame_data=False)
        
        plt.show()

    def print_statistics(self):
        """✅ 주기적으로 통계 출력"""
        rate = rospy.Rate(0.5)  # 2초마다 출력
        while not rospy.is_shutdown():
            with self.lock:
                if len(self.mse_x) > 10:
                    print("\n" + "="*60)
                    print(f"[Statistics] Samples: {len(self.actual_xyz)}")
                    print(f"MSE X: {np.mean(self.mse_x):.6f} ± {np.std(self.mse_x):.6f}")
                    print(f"MSE Y: {np.mean(self.mse_y):.6f} ± {np.std(self.mse_y):.6f}")
                    print(f"MSE Z: {np.mean(self.mse_z):.6f} ± {np.std(self.mse_z):.6f}")
                    print(f"MAE X: {np.mean(self.mae_x):.6f} ± {np.std(self.mae_x):.6f}")
                    print(f"MAE Y: {np.mean(self.mae_y):.6f} ± {np.std(self.mae_y):.6f}")
                    print(f"MAE Z: {np.mean(self.mae_z):.6f} ± {np.std(self.mae_z):.6f}")
                    print(f"RMSE X: {np.sqrt(np.mean(self.mse_x)):.6f}")
                    print(f"RMSE Y: {np.sqrt(np.mean(self.mse_y)):.6f}")
                    print(f"RMSE Z: {np.sqrt(np.mean(self.mse_z)):.6f}")
                    total_mse = np.mean(self.mse_x) + np.mean(self.mse_y) + np.mean(self.mse_z)
                    print(f"Total MSE: {total_mse:.6f}")
                    print(f"Total RMSE: {np.sqrt(total_mse):.6f}")
                    print("="*60)
            rate.sleep()

    def save_results(self, filename='prediction_results.npz'):
        """결과 저장"""
        with self.lock:
            if len(self.actual_xyz) == 0:
                print("[WARNING] No data to save - buffers are empty!")
                return
                
            # 기존 npz 파일 저장
            npz_filename = os.path.join(self.log_dir, f"results_{self.timestamp}.npz")
            try:
                np.savez(npz_filename,
                        timestamps=np.array(self.timestamps),
                        actual=np.array(self.actual_xyz),
                        predicted=np.array(self.predicted_xyz),
                        setpoint=np.array(self.setpoint_xyz),
                        mse_x=np.array(self.mse_x),
                        mse_y=np.array(self.mse_y),
                        mse_z=np.array(self.mse_z),
                        mae_x=np.array(self.mae_x),
                        mae_y=np.array(self.mae_y),
                        mae_z=np.array(self.mae_z))
                print(f"[INFO] Results saved to {npz_filename}")
            except Exception as e:
                print(f"[ERROR] Failed to save NPZ file: {e}")
            
            # ✅ CSV 메트릭 저장
            try:
                self.save_metrics_to_csv()
                print("[INFO] CSV metrics saved successfully")
            except Exception as e:
                print(f"[ERROR] Failed to save CSV metrics: {e}")
                import traceback
                traceback.print_exc()


if __name__ == '__main__':
    try:
        # ✅ Vanilla Transformer checkpoint 경로
        checkpoint_path = '/home/hmcl/Downloads/PatchTST-main/PatchTST-main/PatchTST_supervised/checkpoints/best_model_25.pth'
        
        # 비교 시스템 초기화
        comparator = RealtimePatchTSTComparison(
            checkpoint_path=checkpoint_path,
            seq_len=100,        # config.py의 seq_len과 일치
            pred_len=25        # config.py의 pred_len과 일치
        )
        
        # 통계 출력 스레드
        stats_thread = threading.Thread(target=comparator.print_statistics)
        stats_thread.daemon = True
        stats_thread.start()
        
        print("\n[INFO] Waiting for drone data...")
        print("[INFO] Make sure your drone is in OFFBOARD mode and flying!")
        print(f"[INFO] Logs will be saved to: {comparator.log_dir}")
        
        # 시각화 시작
        comparator.start_visualization()
        
    except rospy.ROSInterruptException:
        print("\n[INFO] ROS interrupted - saving results...")
        if 'comparator' in locals():
            comparator.save_results()
    except KeyboardInterrupt:
        print("\n[INFO] Keyboard interrupt - saving results...")
        if 'comparator' in locals():
            comparator.save_results()
    finally:
        # ✅ 확실하게 저장하도록 finally 블록 추가
        if 'comparator' in locals():
            print("\n[INFO] Final save attempt...")
            comparator.save_results()
            print("[INFO] Shutdown complete!")