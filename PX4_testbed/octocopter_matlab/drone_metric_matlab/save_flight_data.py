#!/usr/bin/env python
import rospy
import csv
import re
from std_msgs.msg import Float64MultiArray

# 기본 설정 (자동 감지 실패 시 예비용)
DEFAULT_TOPIC = "/flight_data_log"
DEFAULT_HZ = 10

HEADERS = [
    'Time', 'X', 'Y', 'Z', 'u', 'v', 'w', 'p', 'q', 'r', 
    'phi (rad)', 'theta (rad)', 'psi (rad)', 
    'u_p (controller)', 'u_q (controller)', 'u_r (controller)', 
    'f_x (controller)', 'f_y (controller)', 'f_z (controller)', 
    'u_p', 'u_q', 'u_r', 'f_x', 'f_y', 'f_z',
    'backward_Mx', 'backward_My', 'backward_Mz', 
    'nominal_Mx', 'nominal_My', 'nominal_Mz'
]

# 전역 변수
packet_count = 0
dt = 0.1
filename = "flight_log.csv"

def find_target_topic():
    """
    현재 활성화된 토픽 목록을 스캔하여
    /flight_data_log_XXhz 패턴과 일치하는 것을 찾습니다.
    """
    topics = rospy.get_published_topics()
    
    # 정규표현식: flight_data_log_ 뒤에 숫자(\d+)가 오고 hz로 끝나는 패턴
    pattern = re.compile(r'/flight_data_log_(\d+)hz')
    
    for name, type_ in topics:
        match = pattern.search(name)
        if match:
            hz_value = int(match.group(1))
            return name, hz_value
            
    # 패턴이 없으면 기본 토픽 확인
    for name, type_ in topics:
        if name == DEFAULT_TOPIC:
            return name, DEFAULT_HZ
            
    return None, None

def init_csv():
    with open(filename, 'w') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(HEADERS)
    print(f"=== File Created: {filename} ===")

def callback(msg):
    global packet_count
    try:
        # 주파수(Hz)에 맞춰 시간 계산 (0.0, 0.1, 0.2 ...)
        sim_time = packet_count * dt
        
        # 카운트 증가
        packet_count += 1
        
        data_list = list(msg.data)
        
        # 데이터 개수 체크
        if len(data_list) != 30:
            return

        # CSV 저장
        clean_time = round(sim_time, 4)
        row = [clean_time] + data_list
        
        with open(filename, 'a') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(row)
            
    except Exception as e:
        rospy.logerr(f"Write Error: {e}")

def listener():
    global dt, filename
    
    # 노드 초기화 (Anonymous=True로 중복 실행 방지)
    rospy.init_node('smart_data_logger', anonymous=True)
    
    print(">>> Scanning for flight data topics...")
    
    # 1. 토픽 스캔 및 자동 설정
    target_topic, detected_hz = find_target_topic()
    
    if target_topic:
        # Hz에 따라 파일 이름과 시간 간격 결정
        filename = f"flight_log_{detected_hz}hz.csv"
        dt = 1.0 / detected_hz
        
        print(f">>> Found Topic: {target_topic}")
        print(f">>> Detected Hz: {detected_hz} Hz (Step: {dt:.4f}s)")
        print(f">>> Saving to:   {filename}")
        
        # CSV 초기화
        init_csv()
        
        # 구독 시작
        rospy.Subscriber(target_topic, Float64MultiArray, callback)
        rospy.spin()
        
    else:
        print("!!! Error: No matching topic found.")
        print("!!! Make sure Simulink is running and publishing to '/flight_data_log_XXhz'")
        print("!!! List of current topics:")
        print(rospy.get_published_topics())

if __name__ == '__main__':
    try:
        listener()
    except rospy.ROSInterruptException:
        pass