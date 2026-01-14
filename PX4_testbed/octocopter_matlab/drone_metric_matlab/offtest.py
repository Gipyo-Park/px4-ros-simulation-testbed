#!/usr/bin/env python3
import rospy
import math
import numpy as np
from geometry_msgs.msg import PoseStamped
from mavros_msgs.msg import State
from mavros_msgs.srv import CommandBool, CommandBoolRequest, SetMode, SetModeRequest

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
        
        # Subscribers
        self.state_sub = rospy.Subscriber("mavros/state", State, self.state_cb)
        
        # Publishers
        self.local_pos_pub = rospy.Publisher("mavros/setpoint_position/local", PoseStamped, queue_size=10)
        
        # Service Clients
        rospy.wait_for_service("/mavros/cmd/arming")
        self.arming_client = rospy.ServiceProxy("mavros/cmd/arming", CommandBool)
        
        rospy.wait_for_service("/mavros/set_mode")
        self.set_mode_client = rospy.ServiceProxy("mavros/set_mode", SetMode)
        
        self.rate = rospy.Rate(RATE_HZ)

    def state_cb(self, msg):
        self.current_state = msg

    def get_lemniscate_pose(self, t):
        """
        Lemniscate of Gerono 공식을 사용한 위치 계산
        x = A * sin(t)
        y = A * sin(t) * cos(t)
        """
        theta = OMEGA * t
        
        # ENU 좌표계: x(East), y(North), z(Up)
        x = RADIUS * math.sin(theta)
        y = RADIUS * math.sin(theta) * math.cos(theta)
        z = ALTITUDE
        
        return x, y, z

    def start(self):
        # 1. 연결 대기
        while not rospy.is_shutdown() and not self.current_state.connected:
            self.rate.sleep()

        # 2. 초기 셋포인트 설정 (안전을 위해 현재 위치 혹은 0,0,0 위로 띄움)
        self.pose.pose.position.x = 0
        self.pose.pose.position.y = 0
        self.pose.pose.position.z = ALTITUDE
        
        # PX4는 Offboard 전환 전에 이미 setpoint가 스트리밍 되고 있어야 함
        for i in range(100):   
            if rospy.is_shutdown():
                break
            self.local_pos_pub.publish(self.pose)
            self.rate.sleep()

        # 3. Offboard 모드 변경 요청
        offb_set_mode = SetModeRequest()
        offb_set_mode.custom_mode = 'OFFBOARD'
        
        # 4. 시동(Arming) 요청
        arm_cmd = CommandBoolRequest()
        arm_cmd.value = True
        
        last_req = rospy.Time.now()
        start_time = rospy.Time.now()

        # 5. 메인 루프
        while not rospy.is_shutdown():
            # 모드 전환 및 시동 유지 로직 (5초 간격으로 재시도)
            if self.current_state.mode != "OFFBOARD" and (rospy.Time.now() - last_req) > rospy.Duration(5.0):
                if self.set_mode_client.call(offb_set_mode).mode_sent:
                    rospy.loginfo("Offboard enabled")
                last_req = rospy.Time.now()
            else:
                if not self.current_state.armed and (rospy.Time.now() - last_req) > rospy.Duration(5.0):
                    if self.arming_client.call(arm_cmd).success:
                        rospy.loginfo("Vehicle armed")
                    last_req = rospy.Time.now()

            # --- 궤적 생성 핵심 로직 ---
            # 시동이 걸리고 Offboard일 때만 시간 t를 흐르게 하여 궤적 계산
            if self.current_state.mode == "OFFBOARD" and self.current_state.armed:
                # 경과 시간 계산
                t = (rospy.Time.now() - start_time).to_sec()
                
                # 8자 궤적 좌표 계산
                tx, ty, tz = self.get_lemniscate_pose(t)
                
                self.pose.pose.position.x = tx
                self.pose.pose.position.y = ty
                self.pose.pose.position.z = tz
            else:
                # 아직 준비 안됐으면 시작 시간 리셋 및 호버링 대기
                start_time = rospy.Time.now()
                self.pose.pose.position.x = 0
                self.pose.pose.position.y = 0
                self.pose.pose.position.z = ALTITUDE

            self.local_pos_pub.publish(self.pose)
            self.rate.sleep()

if __name__ == '__main__':
    try:
        controller = OffboardLemniscate()
        controller.start()
    except rospy.ROSInterruptException:
        pass