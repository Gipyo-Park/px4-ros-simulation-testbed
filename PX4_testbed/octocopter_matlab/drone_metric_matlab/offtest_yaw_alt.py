#!/usr/bin/env python3
import rospy
import math
import numpy as np
from geometry_msgs.msg import PoseStamped
from mavros_msgs.msg import State
from mavros_msgs.srv import CommandBool, CommandBoolRequest, SetMode, SetModeRequest
from tf.transformations import quaternion_from_euler

# --- 설정 파라미터 ---
# 기존 8자 궤적보다 조금더 변형된 8자 궤적을 받으면 데이터가 더 좋겠다
RADIUS = 20.0             # 8자 궤적의 가로 반지름
OMEGA = 0.5              # 각속도 (속도 조절)
Z_BASE = 10.0             # 기준 고도 (미터) - 너무 낮으면 바닥에 박을 수 있음
Z_AMP = 5.0              # 고도 변화 폭 (위아래로 1m씩, 총 2m 변동)
RATE_HZ = 20             # 통신 주기

class OffboardLemniscate3D:
    def __init__(self):
        rospy.init_node('offboard_lemniscate_3d_node')
        
        self.current_state = State()
        self.pose = PoseStamped()
        
        self.state_sub = rospy.Subscriber("mavros/state", State, self.state_cb)
        self.local_pos_pub = rospy.Publisher("mavros/setpoint_position/local", PoseStamped, queue_size=10)
        
        rospy.wait_for_service("/mavros/cmd/arming")
        self.arming_client = rospy.ServiceProxy("mavros/cmd/arming", CommandBool)
        
        rospy.wait_for_service("/mavros/set_mode")
        self.set_mode_client = rospy.ServiceProxy("mavros/set_mode", SetMode)
        
        self.rate = rospy.Rate(RATE_HZ)

    def state_cb(self, msg):
        self.current_state = msg

    def get_lemniscate_pose(self, t):
        theta = OMEGA * t
        
        # 1. 3D 위치 계산
        x = RADIUS * math.sin(theta)
        y = RADIUS * math.sin(theta) * math.cos(theta)
        
        # 고도(z)를 2배 주기로 흔들어서 8자의 양쪽 날개에서 높이가 변하게 함
        # theta가 변할 때 z도 같이 부드럽게 오르내림
        z = Z_BASE + Z_AMP * math.sin(2 * theta)

        # 2. 진행 방향(Yaw) 계산 (x, y 평면 기준)
        # 미분(속도 벡터)
        dx = RADIUS * math.cos(theta)
        dy = RADIUS * math.cos(2 * theta) 
        
        # atan2로 각도 산출
        yaw = math.atan2(dy, dx)

        # 3. Quaternion 변환 (Roll, Pitch는 0으로 둠)
        # 참고: 드론은 이동하기 위해 스스로 Pitch/Roll을 기울이므로, 
        # 위치 제어 모드에서는 우리가 강제로 Pitch를 주지 않는 것이 더 안정적입니다.
        q = quaternion_from_euler(0, 0, yaw)
        
        return x, y, z, q

    def start(self):
        # 연결 대기
        while not rospy.is_shutdown() and not self.current_state.connected:
            self.rate.sleep()

        # 초기값 설정
        self.pose.pose.position.x = 0
        self.pose.pose.position.y = 0
        self.pose.pose.position.z = Z_BASE  # 기준 고도로 초기화
        
        # 초기 스트리밍
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
                t = (rospy.Time.now() - start_time).to_sec()
                
                tx, ty, tz, q = self.get_lemniscate_pose(t)
                
                self.pose.pose.position.x = tx
                self.pose.pose.position.y = ty
                self.pose.pose.position.z = tz
                
                self.pose.pose.orientation.x = q[0]
                self.pose.pose.orientation.y = q[1]
                self.pose.pose.orientation.z = q[2]
                self.pose.pose.orientation.w = q[3]
            else:
                start_time = rospy.Time.now()
                # 대기 시 기준 고도 유지
                self.pose.pose.position.z = Z_BASE

            self.local_pos_pub.publish(self.pose)
            self.rate.sleep()

if __name__ == '__main__':
    try:
        controller = OffboardLemniscate3D()
        controller.start()
    except rospy.ROSInterruptException:
        pass