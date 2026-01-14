/*
 * Copyright 2015 Fadri Furrer, ASL, ETH Zurich, Switzerland
 * Copyright 2015 Michael Burri, ASL, ETH Zurich, Switzerland
 * Copyright 2015 Mina Kamel, ASL, ETH Zurich, Switzerland
 * Copyright 2015 Janosch Nikolic, ASL, ETH Zurich, Switzerland
 * Copyright 2015 Markus Achtelik, ASL, ETH Zurich, Switzerland
 * Copyright 2016 Anton Matosov
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef ROTORS_GAZEBO_PLUGINS_GAZEBO_WIND_PLUGIN_H
#define ROTORS_GAZEBO_PLUGINS_GAZEBO_WIND_PLUGIN_H

#include <stdio.h>
#include <boost/bind.hpp>
#include <thread>
#include <string>
#include <random>
#include <gazebo/common/common.hh>
#include <gazebo/common/Plugin.hh>
#include <gazebo/gazebo.hh>
#include <gazebo/physics/physics.hh>
#include <gazebo/transport/transport.hh>
#include <gazebo/msgs/msgs.hh>
// #include "gazebo/transport/transport.hh"
// #include "gazebo/msgs/msgs.hh"
// #include "common.h"

#include <ros/ros.h>
#include <ros/callback_queue.h>
#include <ros/subscribe_options.h>
#include <geometry_msgs/Vector3.h>

#include <common.h>
#include "Wind.pb.h"

namespace gazebo
{
  // Default values
  static const std::string kDefaultNamespace = "";
  static const std::string kDefaultFrameId = "world";

  static constexpr double kDefaultWindVelocityMean = 0.0;
  static constexpr double kDefaultWindVelocityMax = 100.0;
  static constexpr double kDefaultWindVelocityVariance = 0.0;
  static constexpr double kDefaultWindGustVelocityMean = 0.0;
  static constexpr double kDefaultWindGustVelocityMax = 10.0;
  static constexpr double kDefaultWindGustVelocityVariance = 0.0;

  static constexpr double kDefaultWindGustStart = 10.0;
  static constexpr double kDefaultWindGustDuration = 0.0;

  static const ignition::math::Vector3d kDefaultWindDirectionMean = ignition::math::Vector3d(1, 0, 0);
  static const ignition::math::Vector3d kDefaultWindGustDirectionMean = ignition::math::Vector3d(0, 1, 0);
  static constexpr double kDefaultWindDirectionVariance = 0.0;
  static constexpr double kDefaultWindGustDirectionVariance = 0.0;

  static constexpr double kDefaultWindRampStart = 0.;
  static constexpr double kDefaultWindRampDuration = 0.;
  static const ignition::math::Vector3d kDefaultRampedWindVector = ignition::math::Vector3d(0, 0, 0);

  /// \brief This gazebo plugin simulates wind acting on a model.
  class GazeboWindPlugin : public WorldPlugin
  {
  public:
    GazeboWindPlugin()
        : WorldPlugin(),
          namespace_(kDefaultNamespace),
          wind_pub_topic_("world_wind"),
          wind_velocity_mean_(kDefaultWindVelocityMean),
          wind_velocity_max_(kDefaultWindVelocityMax),
          wind_velocity_variance_(kDefaultWindVelocityVariance),
          wind_gust_velocity_mean_(kDefaultWindGustVelocityMean),
          wind_gust_velocity_max_(kDefaultWindGustVelocityMax),
          wind_gust_velocity_variance_(kDefaultWindGustVelocityVariance),
          wind_direction_mean_(kDefaultWindDirectionMean),
          wind_direction_variance_(kDefaultWindDirectionVariance),
          wind_gust_direction_mean_(kDefaultWindGustDirectionMean),
          wind_gust_direction_variance_(kDefaultWindGustDirectionVariance),
          ramped_wind_vector(kDefaultRampedWindVector),
          frame_id_(kDefaultFrameId),
          pub_interval_(0.5),
          wind_velocity_generator_X(1), // 여기 생성자쪽에서 시드를 바꿔서 난수 값을 다르게 설정했다
          wind_velocity_generator_Y(2), // 시드(seed)란, 난수 생성기가 “랜덤값”을 만들 때 처음 출발점이 되는 값이야. 컴퓨터의 "랜덤"은 사실상 "알고리즘에 따라 잘 섞은 값"이기 때문에, 시드 값이 같으면 항상 같은 "난수 시퀀스"가 나와.(즉, 랜덤값이라고 하지만 실행할 때마다 결과가 반복됨). 시드 값이 다르면 매번 다른 패턴으로 값이 나오지.
          wind_velocity_generator_Z(3),
          node_handle_(NULL)
    {
    }

    virtual ~GazeboWindPlugin();

  protected:
    /// \brief Load the plugin.
    /// \param[in] _model Pointer to the model that loaded this plugin.
    /// \param[in] _sdf SDF element that describes the plugin.
    void Load(physics::WorldPtr world, sdf::ElementPtr sdf);

    /// \brief Called when the world is updated.
    /// \param[in] _info Update timing information.
    void OnUpdate(const common::UpdateInfo & /*_info*/);

  private:
    /// \brief Pointer to the update event connection.
    event::ConnectionPtr update_connection_;

    physics::WorldPtr world_;

    std::string namespace_;

    std::string frame_id_;
    std::string wind_pub_topic_;

    double wind_velocity_mean_;
    double wind_velocity_max_;
    double wind_velocity_variance_;
    double wind_gust_velocity_mean_;
    double wind_gust_velocity_max_;
    double wind_gust_velocity_variance_;
    double pub_interval_;
    std::default_random_engine wind_velocity_generator_;
    std::normal_distribution<double> wind_velocity_distribution_; // wind_velocity_mean_ 과 wind_velocity_variance_ 를 이용하여 구한다.
    std::default_random_engine wind_gust_velocity_generator_;
    std::normal_distribution<double> wind_gust_velocity_distribution_;

    ignition::math::Vector3d wind_direction_mean_;
    ignition::math::Vector3d wind_gust_direction_mean_;
    double wind_direction_variance_;
    double wind_gust_direction_variance_;
    std::default_random_engine wind_direction_generator_;
    std::normal_distribution<double> wind_direction_distribution_X_; // wind_direction_mean_(은 vector3d다) 와 wind_direction_variance_를 이용하여 구한다.
    std::normal_distribution<double> wind_direction_distribution_Y_; //<windDirectionMean>0 1 0</windDirectionMean> 이렇게 되어 있다.
    std::normal_distribution<double> wind_direction_distribution_Z_; // ignition::math::Vector3d 타입의 wind_direction_mean_ 벡터에서 X 축 값을 추출
    std::default_random_engine wind_gust_direction_generator_;
    std::normal_distribution<double> wind_gust_direction_distribution_X_;
    std::normal_distribution<double> wind_gust_direction_distribution_Y_;
    std::normal_distribution<double> wind_gust_direction_distribution_Z_;

    common::Time wind_gust_end_;
    common::Time wind_gust_start_;
    common::Time last_time_;

    ignition::math::Vector3d ramped_wind_vector;
    common::Time wind_ramp_start_;
    common::Time wind_ramp_duration_;

    transport::NodePtr node_handle_;
    transport::PublisherPtr wind_pub_;
    // typedef boost::shared_ptr<Publisher> PublisherPtr; 라고 정의 되어있다.
    // typedef const boost::shared_ptr<gazebo::msgs::Vector3d const> ConstVector3dPtr;
    // typedef const boost::shared_ptr<const physics_msgs::msgs::Wind> WindPtr;


    physics_msgs::msgs::Wind wind_msg;


    // 내가 추가한거 ----------------------------------------------------------------
    double wind_velocity_mean_X{0};
    double wind_velocity_max_X{0};
    double wind_velocity_variance_X{0};
    double wind_velocity_mean_Y{0};
    double wind_velocity_max_Y{0};
    double wind_velocity_variance_Y{0};
    double wind_velocity_mean_Z{0};
    double wind_velocity_max_Z{0};
    double wind_velocity_variance_Z{0};
    double wind_strength;
    ignition::math::Vector3d wind;
    ignition::math::Vector3d wind_direction;
    std::normal_distribution<double> wind_velocity_distribution_X;
    std::normal_distribution<double> wind_velocity_distribution_Y;
    std::normal_distribution<double> wind_velocity_distribution_Z;
    std::default_random_engine wind_velocity_generator_X;
    std::default_random_engine wind_velocity_generator_Y;
    std::default_random_engine wind_velocity_generator_Z;
    ros::NodeHandle* rosNode; // ROS1 노드 핸들, 이걸 사용하면 ros에 노드 생성
    ros::Subscriber rosSub;   // ROS1 구독자
    ros::Subscriber rosSub1;
    ros::Subscriber rosSub2;
    ros::Subscriber rosSub3;
    ros::Subscriber rosSub4;
    ros::CallbackQueue rosQueue;
    std::thread rosQueueThread;
    ignition::math::Vector3d my_wind_gust_;
    ignition::math::Vector3d my_wind_normal_distribution_Mean_Max_Variance_X_;
    ignition::math::Vector3d my_wind_normal_distribution_Mean_Max_Variance_Y_;
    ignition::math::Vector3d my_wind_normal_distribution_Mean_Max_Variance_Z_;
    ignition::math::Vector3d wind_strength_XYZ;
    ignition::math::Vector3d my_wind_normal_distribution_XYZ_Direction_;
    gazebo::msgs::Vector3d *my_wind_gust;
    gazebo::msgs::Vector3d *my_wind_normal_distribution_Mean_Max_Variance_X;
    gazebo::msgs::Vector3d *my_wind_normal_distribution_Mean_Max_Variance_Y;
    gazebo::msgs::Vector3d *my_wind_normal_distribution_Mean_Max_Variance_Z;
    gazebo::msgs::Vector3d *my_wind_normal_distribution_XYZ_Direction;
    void OnWindMsg(const geometry_msgs::Vector3::ConstPtr &msg);
    void OnWindMsg1(const geometry_msgs::Vector3::ConstPtr &msg);
    void OnWindMsg2(const geometry_msgs::Vector3::ConstPtr &msg);
    void OnWindMsg3(const geometry_msgs::Vector3::ConstPtr &msg);
    void OnWindMsg4(const geometry_msgs::Vector3::ConstPtr &msg);
    void QueueThread();
    bool isZero(const gazebo::msgs::Vector3d *check_for_Mean_Max_Variacne);
    
    // 내가 추가한거 -----------------------------------------------------------------
  };
}

#endif // ROTORS_GAZEBO_PLUGINS_GAZEBO_WIND_PLUGIN_H
