#!/usr/bin/env python3
import rospy
import math
import numpy as np
from geometry_msgs.msg import PoseStamped
from mavros_msgs.msg import State
from mavros_msgs.srv import CommandBool, CommandBoolRequest, SetMode, SetModeRequest
from tf.transformations import quaternion_from_euler

# ==============================================================================
# [사용자 설정 구역] Sweep Parameter (점진적 변화)
# 형식: [시작값(Start), 종료값(End), 증가분(Step)]
# ==============================================================================

# 1. 8자 궤적 반지름 (Radius) [m]
# 10m에서 시작해서 매 바퀴마다 2m씩 커져서 30m가 되면 멈춤
CFG_RADIUS = [10.0, 40.0, 2.0]  

# 2. 기준 고도 (Z_Base) [m]
# 중심 높이입니다. 10m 높이에서 시작해서 점점 더 높이 올라갑니다.
CFG_Z_BASE = [10.0, 20.0, 2.0]

# 3. 고도 변화 폭 (Z_Amp) [m]
# 흔드는 폭입니다. 5m면 위아래로 5m씩 (총 10m) 흔듭니다.
# 결과적으로 고도는 (Base - Amp) ~ (Base + Amp) 사이를 움직입니다.
# 예: Base=10, Amp=5 -> 5m ~ 15m 비행
CFG_Z_AMP  = [5.0, 10.0, 2]

# 4. 비행 속도 (Omega) [rad/s]
# 점점 빠르게 돕니다.
CFG_OMEGA  = [0.3, 0.7, 0.05]   

# ------------------------------------------------------------------------------
RATE_HZ = 30  # 통신 주기 (Hz)

class SweepLemniscate:
    def __init__(self):
        rospy.init_node('sweep_lemniscate_node')
        
        self.current_state = State()
        self.pose = PoseStamped()
        
        self.state_sub = rospy.Subscriber("mavros/state", State, self.state_cb)
        self.local_pos_pub = rospy.Publisher("mavros/setpoint_position/local", PoseStamped, queue_size=10)
        
        rospy.wait_for_service("/mavros/cmd/arming")
        self.arming_client = rospy.ServiceProxy("mavros/cmd/arming", CommandBool)
        
        rospy.wait_for_service("/mavros/set_mode")
        self.set_mode_client = rospy.ServiceProxy("mavros/set_mode", SetMode)
        
        self.rate = rospy.Rate(RATE_HZ)
        self.dt = 1.0 / RATE_HZ

        # --- 파라미터 초기화 ---
        self.cur_radius = CFG_RADIUS[0]
        self.cur_z_base = CFG_Z_BASE[0]
        self.cur_z_amp  = CFG_Z_AMP[0]
        self.cur_omega  = CFG_OMEGA[0]
        
        # 위상 및 랩 카운트
        self.theta_acc = 0.0
        self.lap_count = 0

    def state_cb(self, msg):
        self.current_state = msg

    def update_parameters(self):
        """ 한 바퀴(2*pi)를 돌 때마다 파라미터를 'Step'만큼 증가시킴 """
        
        # 1. Radius 증가 (End 값보다 커지지 않게 제한)
        if self.cur_radius < CFG_RADIUS[1]:
            self.cur_radius = min(self.cur_radius + CFG_RADIUS[2], CFG_RADIUS[1])

        # 2. Z Base 증가
        if self.cur_z_base < CFG_Z_BASE[1]:
            self.cur_z_base = min(self.cur_z_base + CFG_Z_BASE[2], CFG_Z_BASE[1])
            
        # 3. Z Amp 증가
        if self.cur_z_amp < CFG_Z_AMP[1]:
            self.cur_z_amp = min(self.cur_z_amp + CFG_Z_AMP[2], CFG_Z_AMP[1])

        # 4. Omega(속도) 증가
        if self.cur_omega < CFG_OMEGA[1]:
            self.cur_omega = min(self.cur_omega + CFG_OMEGA[2], CFG_OMEGA[1])

        # 현재 상태 출력
        print(f"\n=== [Level Up] Lap {self.lap_count} Parameters ===")
        print(f" Radius : {self.cur_radius:.1f} m")
        print(f" Height : {self.cur_z_base:.1f} m (± {self.cur_z_amp:.1f})")
        print(f" Range  : {self.cur_z_base - self.cur_z_amp:.1f}m ~ {self.cur_z_base + self.cur_z_amp:.1f}m")
        print(f" Speed  : {self.cur_omega:.2f} rad/s")
        print("=========================================\n")

    def get_next_pose(self):
        # 1. 위상 적분 (속도가 변해도 위치가 튀지 않게 함)
        self.theta_acc += self.cur_omega * self.dt
        
        # 2. 랩(Lap) 체크: 2*pi를 넘으면 한 바퀴 돈 것
        current_lap = int(self.theta_acc / (2 * math.pi))
        if current_lap > self.lap_count:
            self.lap_count = current_lap
            self.update_parameters()

        t = self.theta_acc 

        # 3. 3D 위치 계산
        # X, Y: 8자 궤적 (Lemniscate of Gerono)
        x = self.cur_radius * math.sin(t)
        y = self.cur_radius * math.sin(t) * math.cos(t)
        
        # Z: 8자의 양 날개에서 올라가고, 교차점에서 내려감 (주파수 2배)
        # sin(2t)는 -1 ~ 1 사이를 움직임 -> 결과적으로 (Base-Amp) ~ (Base+Amp)
        z = self.cur_z_base + self.cur_z_amp * math.sin(2 * t)

        # 4. Yaw(헤딩) 계산: 진행 방향 바라보기
        dx = self.cur_radius * math.cos(t)
        dy = self.cur_radius * math.cos(2 * t)
        yaw = math.atan2(dy, dx)
        q = quaternion_from_euler(0, 0, yaw)
        
        # 디버깅용: 1초에 한 번씩만 현재 고도 출력
        # if int(t * 10) % 10 == 0:
        #     print(f"Current Z: {z:.2f} m")

        return x, y, z, q

    def start(self):
        print("Waiting for FCU connection...")
        while not rospy.is_shutdown() and not self.current_state.connected:
            self.rate.sleep()

        print(f"Setting initial Position: 0, 0, {self.cur_z_base}m")
        self.pose.pose.position.x = 0
        self.pose.pose.position.y = 0
        self.pose.pose.position.z = self.cur_z_base
        
        # Offboard 진입 전 Setpoint 스트리밍
        for i in range(100):   
            if rospy.is_shutdown(): break
            self.local_pos_pub.publish(self.pose)
            self.rate.sleep()

        offb_set_mode = SetModeRequest()
        offb_set_mode.custom_mode = 'OFFBOARD'
        arm_cmd = CommandBoolRequest()
        arm_cmd.value = True
        
        last_req = rospy.Time.now()
        start_time = rospy.Time.now()

        print("--> Dynamic Sweep Started!")
        print(f"Initial Range: {self.cur_z_base - self.cur_z_amp:.1f}m ~ {self.cur_z_base + self.cur_z_amp:.1f}m")

        while not rospy.is_shutdown():
            if self.current_state.mode != "OFFBOARD" and (rospy.Time.now() - last_req) > rospy.Duration(5.0):
                if self.set_mode_client.call(offb_set_mode).mode_sent:
                    rospy.loginfo("Offboard enabled")
                last_req = rospy.Time.now()
            else:
                if not self.current_state.armed and (rospy.Time.now() - last_req) > rospy.Duration(5.0):
                    if self.arming_client.call(arm_cmd).success:
                        rospy.loginfo("Vehicle armed")
                    last_req = rospy.Time.now()

            if self.current_state.mode == "OFFBOARD" and self.current_state.armed:
                tx, ty, tz, q = self.get_next_pose()
                
                self.pose.pose.position.x = tx
                self.pose.pose.position.y = ty
                self.pose.pose.position.z = tz
                
                self.pose.pose.orientation.x = q[0]
                self.pose.pose.orientation.y = q[1]
                self.pose.pose.orientation.z = q[2]
                self.pose.pose.orientation.w = q[3]
            else:
                # 대기 중일 때 (안전을 위해 현재 Base 고도 유지)
                self.pose.pose.position.z = self.cur_z_base

            self.local_pos_pub.publish(self.pose)
            self.rate.sleep()

if __name__ == '__main__':
    try:
        controller = SweepLemniscate()
        controller.start()
    except rospy.ROSInterruptException:
        pass