#!/usr/bin/env python3
import rospy
import math
import numpy as np
from geometry_msgs.msg import PoseStamped, Quaternion
from mavros_msgs.msg import State
from mavros_msgs.srv import CommandBool, CommandBoolRequest, SetMode, SetModeRequest
# 쿼터니언 변환을 위한 라이브러리 (tf.transformations 대용)
from tf.transformations import quaternion_from_euler

# --- 설정 파라미터 ---
RADIUS = 20.0             # 8자 궤적의 크기 (미터)
OMEGA = 0.7              # 각속도 (rad/s) -> 값이 클수록 빨리 돔
ALTITUDE = 10.0           # 비행 고도 (미터)
RATE_HZ = 100             # 통신 주기 (Hz)

class OffboardLemniscate:
    def __init__(self):
        rospy.init_node('offboard_lemniscate_node')
        
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
        
        # 1. 위치 계산 (Position)
        # x = A * sin(theta)
        # y = A * sin(theta) * cos(theta) = (A/2) * sin(2*theta)
        x = RADIUS * math.sin(theta)
        y = RADIUS * math.sin(theta) * math.cos(theta)
        z = ALTITUDE

        # 2. 진행 방향(Yaw) 계산을 위한 미분 (Velocity Vector)
        # dx/dt = A * omega * cos(theta)
        # dy/dt = A * omega * cos(2*theta)
        # (방향만 필요하므로 omega와 A 상수는 atan2 비율에서 약분되지만, 정확성을 위해 기입)
        dx = RADIUS * math.cos(theta)
        dy = RADIUS * math.cos(2 * theta) 
        
        # 3. Yaw 각도 산출 (Radian)
        yaw = math.atan2(dy, dx)

        # 4. Euler Angle -> Quaternion 변환
        # (Roll=0, Pitch=0, Yaw=yaw)
        q = quaternion_from_euler(0, 0, yaw)
        
        return x, y, z, q

    def start(self):
        # 연결 대기
        while not rospy.is_shutdown() and not self.current_state.connected:
            self.rate.sleep()

        # 초기값 설정
        self.pose.pose.position.x = 0
        self.pose.pose.position.y = 0
        self.pose.pose.position.z = ALTITUDE
        
        # 초기 스트리밍
        for i in range(100):   
            if rospy.is_shutdown(): break
            self.local_pos_pub.publish(self.pose)
            self.rate.sleep()

        # 모드 전환 및 시동 요청 객체 생성
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
                
                # 위치와 쿼터니언을 받아옴
                tx, ty, tz, q = self.get_lemniscate_pose(t)
                
                self.pose.pose.position.x = tx
                self.pose.pose.position.y = ty
                self.pose.pose.position.z = tz
                
                # 쿼터니언 적용 (Orientation)
                self.pose.pose.orientation.x = q[0]
                self.pose.pose.orientation.y = q[1]
                self.pose.pose.orientation.z = q[2]
                self.pose.pose.orientation.w = q[3]
            else:
                # 대기 상태
                start_time = rospy.Time.now()

            self.local_pos_pub.publish(self.pose)
            self.rate.sleep()

if __name__ == '__main__':
    try:
        controller = OffboardLemniscate()
        controller.start()
    except rospy.ROSInterruptException:
        pass