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

# PatchTST 모델 import를 위한 경로 추가
sys.path.append('/home/hmcl/Downloads/PatchTST-main/PatchTST-main/PatchTST_supervised')
from models import PatchTST

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
        
        # 실시간 측정값 저장 (12차원)
        self.input_buffer = deque(maxlen=seq_len)
        
        # 결과 저장용
        self.actual_xyz = deque(maxlen=self.max_buffer_size)
        self.predicted_xyz = deque(maxlen=self.max_buffer_size)
        self.setpoint_xyz = deque(maxlen=self.max_buffer_size)
        self.timestamps = deque(maxlen=self.max_buffer_size)
        
        # ✅ 전체 예측 궤적 저장 추가 (25-step)
        self.predicted_trajectory = deque(maxlen=self.max_buffer_size)  # (25, 3) 저장
        
        # MSE 기록
        self.mse_x = deque(maxlen=self.max_buffer_size)
        self.mse_y = deque(maxlen=self.max_buffer_size)
        self.mse_z = deque(maxlen=self.max_buffer_size)
        
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
        
        # ✅ 초기 위치 오프셋 추가
        self.initial_position = None  # 첫 예측 시 설정
        self.position_offset_calibrated = False
        
        print(f"[INFO] Model loaded from {checkpoint_path}")
        print(f"[INFO] Device: {self.device}")
        print(f"[INFO] Input: 12D [phi~f_z], Output: 3D [X,Y,Z]")
        print(f"[INFO] Sequence Length: {seq_len}, Prediction Length: {pred_len}")

    def load_model(self, checkpoint_path):
        """PatchTST 모델 구조 생성 및 가중치 로드"""
        # flight_xyz.sh와 동일한 하이퍼파라미터로 모델 생성
        configs = type('Args', (), {
            'enc_in': 12,          # 입력 변수 12개
            'dec_in': 12,
            'c_out': 3,           # 출력 변수 3개 (X, Y, Z)
            'seq_len': self.seq_len,
            'pred_len': self.pred_len,
            'e_layers': 6,         # Encoder layers
            'n_heads': 16,         # Attention heads
            'd_model': 128,        # Model dimension
            'd_ff': 512,           # Feed-forward dimension
            'dropout': 0.3,
            'fc_dropout': 0.3,
            'head_dropout': 0.0,
            'patch_len': 100,       # Patch length
            'stride': 50,           # Patch stride
            'individual': False,
            'revin': True,
            'affine': False,
            'padding_patch': 'end',  # 'end' 문자열로 수정
            'subtract_last': False,
            'decomposition': False,
            'kernel_size': 25,
        })()
        
        # 모델 생성
        model = PatchTST.Model(configs).to(self.device)
        
        # 가중치 로드
        checkpoint = torch.load(checkpoint_path, map_location=self.device)
        model.load_state_dict(checkpoint)
        model.eval()
        
        print(f"[INFO] Model architecture created and weights loaded successfully")
        print(f"[INFO] Model: 12 inputs → 3 outputs")
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
        """12차원 입력 벡터를 구성하여 버퍼에 추가 (phi~f_z만!)"""
        # 1. 모터 속도 계산
        omega_motor = self.pwm_to_rads(self.current_pwm)
        
        # 2. 힘과 모멘트 계산
        u_p, u_q, u_r, f_x, f_y, f_z = self.motor_force_moment_calc(omega_motor)

        # 3. 12차원 벡터 구성
        # [phi, theta, psi, p, q, r, u_p, u_q, u_r, f_x, f_y, f_z]
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
            f_z
        ]
        
        # 4. 버퍼에 추가
        self.input_buffer.append(input_vector)
        
        # 5. 예측 수행
        if len(self.input_buffer) >= self.seq_len:
            self.perform_prediction()

    def perform_prediction(self):
        """PatchTST 모델로 XYZ 예측"""
        try:
            # 입력 데이터 준비 [seq_len, 12]
            input_seq = np.array(list(self.input_buffer))
            
            # 정규화
            if self.mean is None:
                self.mean = input_seq.mean(axis=0)
                self.std = input_seq.std(axis=0) + 1e-8
            
            input_normalized = (input_seq - self.mean) / self.std
            
            # 텐서 변환: (1, seq_len, 12)
            input_tensor = torch.FloatTensor(input_normalized).unsqueeze(0).to(self.device)
            
            # 예측
            with torch.no_grad():
                output = self.model(input_tensor)
    
            # ✅ 모델 출력: (1, pred_len, output_dim)
            output_np = output.cpu().numpy()[0]  # (100, 12) 또는 (100, 3)
            
            # ✅ 디버그: 실제 출력 shape 확인
            print(f"[DEBUG] Model output shape: {output_np.shape}")
            
            # ✅ XYZ만 추출 (12차원 중 마지막 3개가 X,Y,Z일 가능성)
            # 또는 처음 3개가 X,Y,Z일 수도 있음 - 학습 데이터 구조 확인 필요
            if output_np.shape[1] == 12:
                # Case 1: 마지막 3개가 X, Y, Z (가장 가능성 높음)
                predicted_xyz = output_np[:, -3:]  # (100, 3) - [f_x, f_y, f_z]는 9~11번 인덱스
                
                # ✅ 만약 f_x, f_y, f_z가 아니라 실제 X, Y, Z가 다른 위치라면:
                # predicted_xyz = output_np[:, 9:12]  # 예: 9, 10, 11번 인덱스
                # 또는
                # predicted_xyz = output_np[:, :3]    # 예: 0, 1, 2번 인덱스 (phi, theta, psi 위치)
                
            elif output_np.shape[1] == 3:
                # Case 2: 이미 X, Y, Z만 출력 (원래 의도대로)
                predicted_xyz = output_np  # (100, 3)
            else:
                raise ValueError(f"Unexpected output dimension: {output_np.shape[1]}")
            
            print(f"[DEBUG] Extracted XYZ shape: {predicted_xyz.shape}")  # (100, 3)
            print(f"[DEBUG] current_xyz: {self.current_xyz}")
        
            # ✅ 첫 예측 시 초기 위치 오프셋 계산
            if not self.position_offset_calibrated:
                current_actual = np.array(self.current_xyz)
                first_prediction = predicted_xyz[0]  # 이제 (3,) shape
        
                print(f"[DEBUG] current_actual shape: {current_actual.shape}")
                print(f"[DEBUG] first_prediction shape: {first_prediction.shape}")
        
                self.initial_position = current_actual - first_prediction
                self.position_offset_calibrated = True
        
                print(f"\n[CALIBRATION] Initial position offset set:")
                print(f"  Current actual: {current_actual}")
                print(f"  First prediction: {first_prediction}")
                print(f"  Offset: {self.initial_position}")
                print(f"  Offset shape: {self.initial_position.shape}\n")
    
            # ✅ 예측값에 오프셋 적용
            if self.initial_position is not None:
                predicted_xyz_calibrated = predicted_xyz + self.initial_position.reshape(1, 3)
            else:
                predicted_xyz_calibrated = predicted_xyz.copy()
    
            # ✅ 전체 궤적 저장 (보정된 값)
            self.predicted_trajectory.append(predicted_xyz_calibrated.copy())
        
            # 첫 번째 예측값 사용 (1-step ahead)
            predicted_xyz_current = predicted_xyz_calibrated[0]
        
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
        except Exception as e:
            print(f"[ERROR] Prediction failed: {e}")
            import traceback
            traceback.print_exc()

    def start_visualization(self):
        """실시간 시각화 - 여러 개의 figure로 분리"""
        # 화면 크기 가져오기
        try:
            import tkinter as tk
            root = tk.Tk()
            screen_width = root.winfo_screenwidth()
            screen_height = root.winfo_screenheight()
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
        
        # ✅ Figure 4: 미래 25-step 예측 궤적 (NEW!)
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
                ax_3d.plot(actual[:, 0], actual[:, 1], actual[:, 2], 
                          'b-', label='Actual', linewidth=2, alpha=0.8)
                ax_3d.plot(predicted[:, 0], predicted[:, 1], predicted[:, 2], 
                          'r--', label='Predicted', linewidth=2, alpha=0.8)
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
                ax_3d.legend(loc='upper right', fontsize=8, framealpha=0.9)
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
            """미래 25-step 예측 궤적 업데이트"""
            with self.lock:
                if len(self.predicted_trajectory) < 1:
                    return
                
                # 현재 위치
                current_pos = np.array(self.current_xyz)
                
                # 최신 예측 궤적 (25, 3)
                future_traj = np.array(list(self.predicted_trajectory)[-1])
                
                # 타임스텝 인덱스 (1~25)
                time_steps = np.arange(1, self.pred_len + 1)
                
                # 색상 맵 (시간에 따라 진해짐)
                colors = plt.cm.plasma(np.linspace(0, 1, self.pred_len))
                
                # ✅ 신뢰구간 계산 (최근 10개 예측의 표준편차)
                std_traj = None
                if len(self.predicted_trajectory) >= 10:
                    recent_trajs = np.array(list(self.predicted_trajectory)[-10:])  # (10, 25, 3)
                    std_traj = recent_trajs.std(axis=0)  # (25, 3)
                
                # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                # 3D 궤적 플롯 (신뢰구간 추가!)
                # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                ax_future_3d.clear()
                
                # 현재 위치 표시
                ax_future_3d.scatter(current_pos[0], current_pos[1], current_pos[2],
                                    c='green', marker='o', s=200, 
                                    label='Current', zorder=10, edgecolors='black', linewidths=2)
                
                # ✅ 신뢰구간 표시 (3D - 튜브 형태로)
                if std_traj is not None:
                    # 상한/하한 궤적 계산
                    upper_bound = future_traj + 2 * std_traj
                    lower_bound = future_traj - 2 * std_traj
                    
                    # 신뢰구간 영역 (반투명 튜브)
                    for i in range(self.pred_len - 1):
                        # 각 세그먼트마다 사각형으로 신뢰구간 표시
                        vertices = [
                            [upper_bound[i, 0], upper_bound[i, 1], upper_bound[i, 2]],
                            [upper_bound[i+1, 0], upper_bound[i+1, 1], upper_bound[i+1, 2]],
                            [lower_bound[i+1, 0], lower_bound[i+1, 1], lower_bound[i+1, 2]],
                            [lower_bound[i, 0], lower_bound[i, 1], lower_bound[i, 2]]
                        ]
                        from mpl_toolkits.mplot3d.art3d import Poly3DCollection
                        poly = Poly3DCollection([vertices], alpha=0.15, 
                                               facecolors='gray', edgecolors='none')
                        ax_future_3d.add_collection3d(poly)
                    
                    # 상한/하한 선 (점선으로)
                    ax_future_3d.plot(upper_bound[:, 0], upper_bound[:, 1], upper_bound[:, 2],
                                    'gray', linestyle=':', linewidth=1, alpha=0.5, label='±2σ bounds')
                    ax_future_3d.plot(lower_bound[:, 0], lower_bound[:, 1], lower_bound[:, 2],
                                    'gray', linestyle=':', linewidth=1, alpha=0.5)
                
                # 미래 궤적 (중심선)
                ax_future_3d.plot(future_traj[:, 0], future_traj[:, 1], future_traj[:, 2],
                                 'r--', linewidth=2.5, alpha=0.8, label='Predicted Path', zorder=6)
                
                # 각 예측 포인트 (시간에 따라 색상 변화)
                for i in range(self.pred_len):
                    ax_future_3d.scatter(future_traj[i, 0], future_traj[i, 1], future_traj[i, 2],
                                        c=[colors[i]], marker='o', s=50, 
                                        edgecolors='black', linewidths=0.5, zorder=7)
                
                # 시작점과 끝점 강조
                ax_future_3d.scatter(future_traj[0, 0], future_traj[0, 1], future_traj[0, 2],
                                    c='yellow', marker='*', s=150, 
                                    label='t+1 (Next)', zorder=9, edgecolors='black', linewidths=1)
                ax_future_3d.scatter(future_traj[-1, 0], future_traj[-1, 1], future_traj[-1, 2],
                                    c='red', marker='X', s=150, 
                                    label=f't+{self.pred_len} (Last)', zorder=9, 
                                    edgecolors='black', linewidths=1)
                
                ax_future_3d.set_xlabel('X (m)', fontsize=9)
                ax_future_3d.set_ylabel('Y (m)', fontsize=9)
                ax_future_3d.set_zlabel('Z (m)', fontsize=9)
                ax_future_3d.set_title(f'Future {self.pred_len}-Step Trajectory (3D)', 
                                      fontsize=10, fontweight='bold')
                ax_future_3d.legend(loc='best', fontsize=7, framealpha=0.9)
                ax_future_3d.grid(True, alpha=0.3)
                ax_future_3d.tick_params(labelsize=7)
                
                # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                # X, Y, Z 각 축별 예측 (신뢰구간 추가!)
                # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                for ax, idx, label, color_base in zip(
                    [ax_future_x, ax_future_y, ax_future_z],
                    [0, 1, 2],
                    ['X', 'Y', 'Z'],
                    ['red', 'green', 'blue']
                ):
                    ax.clear()
                    
                    # 현재 위치 (t=0)
                    ax.scatter(0, current_pos[idx], c='green', marker='o', s=100, 
                              label='Current (t=0)', zorder=10, edgecolors='black', linewidths=1.5)
                    
                    # ✅ 신뢰구간 표시 (fill_between)
                    if std_traj is not None:
                        ax.fill_between(time_steps, 
                                       future_traj[:, idx] - 2*std_traj[:, idx],
                                       future_traj[:, idx] + 2*std_traj[:, idx],
                                       alpha=0.2, color=color_base, label='±2σ', zorder=1)
                        
                        # 상한/하한 선
                        ax.plot(time_steps, future_traj[:, idx] + 2*std_traj[:, idx],
                               color=color_base, linestyle=':', linewidth=1, alpha=0.4, zorder=2)
                        ax.plot(time_steps, future_traj[:, idx] - 2*std_traj[:, idx],
                               color=color_base, linestyle=':', linewidth=1, alpha=0.4, zorder=2)
                    
                    # 미래 예측 (중심선)
                    ax.plot(time_steps, future_traj[:, idx], 
                           color=color_base, linestyle='--', linewidth=2.5, 
                           alpha=0.8, label='Predicted', zorder=6)
                    
                    # 각 예측 포인트
                    ax.scatter(time_steps, future_traj[:, idx], 
                              c=colors, s=40, edgecolors='black', linewidths=0.5, zorder=7)
                    
                    # t+1 강조
                    ax.scatter(1, future_traj[0, idx], c='yellow', marker='*', s=120, 
                              label='t+1 (Next)', zorder=9, edgecolors='black', linewidths=1)
                    
                    ax.set_xlabel('Time Step', fontsize=8)
                    ax.set_ylabel(f'{label} Position (m)', fontsize=8)
                    ax.set_title(f'{label}-axis Future Prediction', fontsize=9, fontweight='bold')
                    ax.legend(loc='best', fontsize=7, framealpha=0.9)
                    ax.grid(True, alpha=0.3, linewidth=0.5)
                    ax.tick_params(labelsize=7)
                    ax.set_xlim(-1, self.pred_len + 1)
                
                fig_future.suptitle(f'Future {self.pred_len}-Step Prediction Analysis (with ±2σ)', 
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
            
            # ✅ Figure 4: 오른쪽 아래 (NEW!)
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
        """주기적으로 통계 출력"""
        rate = rospy.Rate(0.5)
        while not rospy.is_shutdown():
            with self.lock:
                if len(self.mse_x) > 10:
                    print("\n" + "="*60)
                    print(f"[Statistics] Samples: {len(self.actual_xyz)}")
                    print(f"MSE X: {np.mean(self.mse_x):.6f} ± {np.std(self.mse_x):.6f}")
                    print(f"MSE Y: {np.mean(self.mse_y):.6f} ± {np.std(self.mse_y):.6f}")
                    print(f"MSE Z: {np.mean(self.mse_z):.6f} ± {np.std(self.mse_z):.6f}")
                    total_mse = np.mean(self.mse_x) + np.mean(self.mse_y) + np.mean(self.mse_z)
                    print(f"Total MSE: {total_mse:.6f}")
                    print("="*60)
            rate.sleep()

    def save_results(self, filename='prediction_results.npz'):
        """결과 저장"""
        with self.lock:
            np.savez(filename,
                    timestamps=np.array(self.timestamps),
                    actual=np.array(self.actual_xyz),
                    predicted=np.array(self.predicted_xyz),
                    setpoint=np.array(self.setpoint_xyz),
                    mse_x=np.array(self.mse_x),
                    mse_y=np.array(self.mse_y),
                    mse_z=np.array(self.mse_z))
        print(f"[INFO] Results saved to {filename}")


if __name__ == '__main__':
    try:
        # checkpoint.pth 파일 경로 (pred_len에 맞는 체크포인트 선택)
        checkpoint_path = '/home/hmcl/Downloads/PatchTST-main/PatchTST-main/PatchTST_supervised/checkpoints/drone_position_pred_1000_100_PatchTST_custom_ftMS_sl1000_ll48_pl100_dm128_nh16_el6_dl1_df512_fc1_ebtimeF_dtTrue_Exp_0/checkpoint.pth'
        
        # 비교 시스템 초기화
        comparator = RealtimePatchTSTComparison(
            checkpoint_path=checkpoint_path,
            seq_len=1000,
            pred_len=100  # checkpoint와 동일한 pred_len 사용
        )
        
        # 통계 출력 스레드
        stats_thread = threading.Thread(target=comparator.print_statistics)
        stats_thread.daemon = True
        stats_thread.start()
        
        print("\n[INFO] Waiting for drone data...")
        print("[INFO] Make sure your drone is in OFFBOARD mode and flying!")
        
        # 시각화 시작
        comparator.start_visualization()
        
        # 종료 시 결과 저장
        comparator.save_results()
        
    except rospy.ROSInterruptException:
        pass
    except KeyboardInterrupt:
        print("\n[INFO] Shutting down...")
        comparator.save_results()