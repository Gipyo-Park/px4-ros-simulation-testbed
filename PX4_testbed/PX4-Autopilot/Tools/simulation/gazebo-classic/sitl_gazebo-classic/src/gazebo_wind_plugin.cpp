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

#include "gazebo_wind_plugin.h"
#include "common.h"

namespace gazebo
{
  GazeboWindPlugin::~GazeboWindPlugin()
  {
    update_connection_->~Connection();
    delete my_wind_gust;
    delete my_wind_normal_distribution_Mean_Max_Variance_X;
    delete my_wind_normal_distribution_Mean_Max_Variance_Y;
    delete my_wind_normal_distribution_Mean_Max_Variance_Z;
    delete my_wind_normal_distribution_XYZ_Direction;
  }

  void GazeboWindPlugin::Load(physics::WorldPtr world, sdf::ElementPtr sdf)
  {
    world_ = world;

    double wind_gust_start = kDefaultWindGustStart;
    double wind_gust_duration = kDefaultWindGustDuration;

    double wind_ramp_start = kDefaultWindRampStart;
    double wind_ramp_duration = kDefaultWindRampDuration;

    if (sdf->HasElement("robotNamespace"))
    {
      namespace_ = sdf->GetElement("robotNamespace")->Get<std::string>();
    }
    else
    {
      gzerr << "[gazebo_wind_plugin] Please specify a robotNamespace.\n";
    }

    // Create a new transport node
    // transport::NodePtr node_handle(new transport::Node()); 이렇게도 가능하다.
    // Gazebo의 transport 시스템은 시뮬레이션 내의 다양한 컴포넌트 간에 메시지 기반 통신을 가능하게 하는 매커니즘이다
    /*
     이는 Gazebo 내에서의 데이터 교환과 이벤트 처리를 위한 중요한 구조적 요소입니다.
     따라서 node_handle_은 Gazebo 환경에 특화된 노드로, Gazebo 시뮬레이션 밖에서는 사용되지 않습니다.
    */
    node_handle_ = transport::NodePtr(new transport::Node());
    node_handle_->Init(namespace_);

    getSdfParam<std::string>(sdf, "windPubTopic", wind_pub_topic_, wind_pub_topic_);
    double pub_rate = 2.0;
    getSdfParam<double>(sdf, "publishRate", pub_rate, pub_rate); // Wind topic publishing rates
    pub_interval_ = (pub_rate > 0.0) ? 1 / pub_rate : 0.0;
    getSdfParam<std::string>(sdf, "frameId", frame_id_, frame_id_);
    // Get the wind params from SDF.
    getSdfParam<double>(sdf, "windVelocityMean", wind_velocity_mean_, wind_velocity_mean_);
    getSdfParam<double>(sdf, "windVelocityMax", wind_velocity_max_, wind_velocity_max_);
    getSdfParam<double>(sdf, "windVelocityVariance", wind_velocity_variance_, wind_velocity_variance_);
    getSdfParam<ignition::math::Vector3d>(sdf, "windDirectionMean", wind_direction_mean_, wind_direction_mean_);
    getSdfParam<double>(sdf, "windDirectionVariance", wind_direction_variance_, wind_direction_variance_);
    // Get the wind gust params from SDF.
    getSdfParam<double>(sdf, "windGustStart", wind_gust_start, wind_gust_start);
    getSdfParam<double>(sdf, "windGustDuration", wind_gust_duration, wind_gust_duration);
    getSdfParam<double>(sdf, "windGustVelocityMean", wind_gust_velocity_mean_, wind_gust_velocity_mean_);
    getSdfParam<double>(sdf, "windGustVelocityMax", wind_gust_velocity_max_, wind_gust_velocity_max_);
    getSdfParam<double>(sdf, "windGustVelocityVariance", wind_gust_velocity_variance_, wind_gust_velocity_variance_);
    getSdfParam<ignition::math::Vector3d>(sdf, "windGustDirectionMean", wind_gust_direction_mean_, wind_gust_direction_mean_);
    getSdfParam<double>(sdf, "windGustDirectionVariance", wind_gust_direction_variance_, wind_gust_direction_variance_);

    wind_direction_mean_.Normalize();
    wind_gust_direction_mean_.Normalize();
    wind_gust_start_ = common::Time(wind_gust_start);
    wind_gust_end_ = common::Time(wind_gust_start + wind_gust_duration);
    // Set random wind velocity mean and standard deviation
    wind_velocity_distribution_.param(std::normal_distribution<double>::param_type(wind_velocity_mean_, sqrt(wind_velocity_variance_)));
    // Set random wind direction mean and standard deviation
    wind_direction_distribution_X_.param(std::normal_distribution<double>::param_type(wind_direction_mean_.X(), sqrt(wind_direction_variance_)));
    wind_direction_distribution_Y_.param(std::normal_distribution<double>::param_type(wind_direction_mean_.Y(), sqrt(wind_direction_variance_)));
    wind_direction_distribution_Z_.param(std::normal_distribution<double>::param_type(wind_direction_mean_.Z(), sqrt(wind_direction_variance_)));
    
    // Set random wind gust velocity mean and standard deviation
    wind_gust_velocity_distribution_.param(std::normal_distribution<double>::param_type(wind_gust_velocity_mean_, sqrt(wind_gust_velocity_variance_)));
    // Set random wind gust direction mean and standard deviation
    wind_gust_direction_distribution_X_.param(std::normal_distribution<double>::param_type(wind_gust_direction_mean_.X(), sqrt(wind_gust_direction_variance_)));
    wind_gust_direction_distribution_Y_.param(std::normal_distribution<double>::param_type(wind_gust_direction_mean_.Y(), sqrt(wind_gust_direction_variance_)));
    wind_gust_direction_distribution_Z_.param(std::normal_distribution<double>::param_type(wind_gust_direction_mean_.Z(), sqrt(wind_gust_direction_variance_)));

    // Get the ramped wind params from SDF.
    getSdfParam<double>(sdf, "windRampStart", wind_ramp_start, wind_ramp_start);
    getSdfParam<double>(sdf, "windChangeRampDuration", wind_ramp_duration, wind_ramp_duration);
    getSdfParam<ignition::math::Vector3d>(sdf, "windRampWindVectorComponents", ramped_wind_vector, ramped_wind_vector);

    wind_ramp_start_ = common::Time(wind_ramp_start);
    wind_ramp_duration_ = common::Time(wind_ramp_duration);

    // Initialize my_wind_gust
    my_wind_gust = new gazebo::msgs::Vector3d();
    my_wind_gust->set_x(0);
    my_wind_gust->set_y(0);
    my_wind_gust->set_z(0);

    my_wind_normal_distribution_Mean_Max_Variance_X = new gazebo::msgs::Vector3d();
    my_wind_normal_distribution_Mean_Max_Variance_X->set_x(0);
    my_wind_normal_distribution_Mean_Max_Variance_X->set_y(0);
    my_wind_normal_distribution_Mean_Max_Variance_X->set_z(0);

    my_wind_normal_distribution_Mean_Max_Variance_Y = new gazebo::msgs::Vector3d();
    my_wind_normal_distribution_Mean_Max_Variance_Y->set_x(0);
    my_wind_normal_distribution_Mean_Max_Variance_Y->set_y(0);
    my_wind_normal_distribution_Mean_Max_Variance_Y->set_z(0);

    my_wind_normal_distribution_Mean_Max_Variance_Z = new gazebo::msgs::Vector3d();
    my_wind_normal_distribution_Mean_Max_Variance_Z->set_x(0);
    my_wind_normal_distribution_Mean_Max_Variance_Z->set_y(0);
    my_wind_normal_distribution_Mean_Max_Variance_Z->set_z(0);

    wind_strength_XYZ = ignition::math::Vector3d(0, 0, 0);

    my_wind_normal_distribution_XYZ_Direction = new gazebo::msgs::Vector3d();
    my_wind_normal_distribution_XYZ_Direction->set_x(0);
    my_wind_normal_distribution_XYZ_Direction->set_y(0);
    my_wind_normal_distribution_XYZ_Direction->set_z(0);

    // Listen to the update event. This event is broadcast every
    // simulation iteration.
    update_connection_ = event::Events::ConnectWorldUpdateBegin(boost::bind(&GazeboWindPlugin::OnUpdate, this, _1));
    // transport::NodePtr node_handle_; // Gazebo 및 ROS 통신을 위한 노드 핸들
    // wind_pub_ = node_handle_->Advertise<physics_msgs::msgs::Wind>("~/" + wind_pub_topic_, 10);
    wind_pub_ = node_handle_->Advertise<physics_msgs::msgs::Wind>("~/world_wind", 10);
    // wind_pub_topic_ 이놈이 world_wind 토픽을 보내고 있다.

    if (!ros::isInitialized())
    {
      int argc = 0;
      char **argv = NULL;
      ros::init(argc, argv, "gazebo_wind_sub", ros::init_options::NoSigintHandler);
    }
    // Create our ROS node. This acts in a similar manner to the Gazebo node
    this->rosNode = new ros::NodeHandle(this->namespace_);
    ros::SubscribeOptions so = ros::SubscribeOptions::create<geometry_msgs::Vector3>("/wind_gust_pub",
                                                                                     10, boost::bind(&GazeboWindPlugin::OnWindMsg, this, _1),
                                                                                     ros::VoidPtr(), &this->rosQueue);
    ros::SubscribeOptions so1 = ros::SubscribeOptions::create<geometry_msgs::Vector3>("/wind_normal_distribution_Mean_Max_Variance_X_pub",
                                                                                      10, boost::bind(&GazeboWindPlugin::OnWindMsg1, this, _1),
                                                                                      ros::VoidPtr(), &this->rosQueue);
    ros::SubscribeOptions so2 = ros::SubscribeOptions::create<geometry_msgs::Vector3>("/wind_normal_distribution_Mean_Max_Variance_Y_pub",
                                                                                      10, boost::bind(&GazeboWindPlugin::OnWindMsg2, this, _1),
                                                                                      ros::VoidPtr(), &this->rosQueue);
    ros::SubscribeOptions so3 = ros::SubscribeOptions::create<geometry_msgs::Vector3>("/wind_normal_distribution_Mean_Max_Variance_Z_pub",
                                                                                      10, boost::bind(&GazeboWindPlugin::OnWindMsg3, this, _1),
                                                                                      ros::VoidPtr(), &this->rosQueue);
    ros::SubscribeOptions so4 = ros::SubscribeOptions::create<geometry_msgs::Vector3>("/wind_normal_distribution_XYZ_Direction_pub",
                                                                                      10, boost::bind(&GazeboWindPlugin::OnWindMsg4, this, _1),
                                                                                      ros::VoidPtr(), &this->rosQueue);
    this->rosSub = this->rosNode->subscribe(so);
    this->rosSub1 = this->rosNode->subscribe(so1);
    this->rosSub2 = this->rosNode->subscribe(so2);
    this->rosSub3 = this->rosNode->subscribe(so3);
    this->rosSub4 = this->rosNode->subscribe(so4);
    this->rosQueueThread = std::thread(std::bind(&GazeboWindPlugin::QueueThread, this));

#if GAZEBO_MAJOR_VERSION >= 9
    last_time_ = world_->SimTime();
#else
    last_time_ = world_->GetSimTime();
#endif
  }

  // This gets called by the world update start event.
  void GazeboWindPlugin::OnUpdate(const common::UpdateInfo &_info)
  {
    // Get the current simulation time.
#if GAZEBO_MAJOR_VERSION >= 9
    common::Time now = world_->SimTime();
#else
    common::Time now = world_->GetSimTime();
#endif
    if ((now - last_time_).Double() < pub_interval_ || pub_interval_ == 0.0)
    {
      return;
    }
    last_time_ = now;

    // ------------------------------------------------- Normal Distribution ------------------------------------------------------------
    // Calculate the wind force.
    // Get normal distribution wind strength

      wind_velocity_mean_X = my_wind_normal_distribution_Mean_Max_Variance_X->x();
      wind_velocity_max_X = my_wind_normal_distribution_Mean_Max_Variance_X->y();
      wind_velocity_variance_X = my_wind_normal_distribution_Mean_Max_Variance_X->z();
      wind_velocity_distribution_X.param(std::normal_distribution<double>::param_type(wind_velocity_mean_X, sqrt(wind_velocity_variance_X)));
      // std::cout << "[my_wind_normal_distribution_Mean_Max_Variance_X after change] :  (" << wind_velocity_mean_X << ", " << wind_velocity_max_X << ", " << wind_velocity_variance_X << ")" << std::endl;
    

    // std::cout << "[wind_velocity_distribution_X after change] :  (" << wind_velocity_distribution_X << std::endl;


      wind_velocity_mean_Y = my_wind_normal_distribution_Mean_Max_Variance_Y->x();
      wind_velocity_max_Y = my_wind_normal_distribution_Mean_Max_Variance_Y->y();
      wind_velocity_variance_Y = my_wind_normal_distribution_Mean_Max_Variance_Y->z();
      wind_velocity_distribution_Y.param(std::normal_distribution<double>::param_type(wind_velocity_mean_Y, sqrt(wind_velocity_variance_Y)));
      // std::cout << "[my_wind_normal_distribution_Mean_Max_Variance_Y after change] :  (" << wind_velocity_mean_Y << ", " << wind_velocity_max_Y << ", " << wind_velocity_variance_Y << ")" << std::endl;
    

    // std::cout << "[wind_velocity_distribution_Y after change] :  (" << wind_velocity_distribution_Y << std::endl;


      wind_velocity_mean_Z = my_wind_normal_distribution_Mean_Max_Variance_Z->x();
      wind_velocity_max_Z = my_wind_normal_distribution_Mean_Max_Variance_Z->y();
      wind_velocity_variance_Z = my_wind_normal_distribution_Mean_Max_Variance_Z->z();
      wind_velocity_distribution_Z.param(std::normal_distribution<double>::param_type(wind_velocity_mean_Z, sqrt(wind_velocity_variance_Z)));
      // std::cout << "[my_wind_normal_distribution_Mean_Max_Variance_Z after change] :  (" << wind_velocity_mean_Z << ", " << wind_velocity_max_Z << ", " << wind_velocity_variance_Z << ")" << std::endl;
    

    // std::cout << "[wind_velocity_distribution_Z after change] :  (" << wind_velocity_distribution_Z << std::endl;


    if (!isZero(my_wind_normal_distribution_Mean_Max_Variance_X) || !isZero(my_wind_normal_distribution_Mean_Max_Variance_Y) || !isZero(my_wind_normal_distribution_Mean_Max_Variance_Z))
    {
      // X축 바람 세기
      double wind_strength_X = wind_velocity_distribution_X(wind_velocity_generator_X);
      wind_strength_X = std::abs(wind_strength_X);
      wind_strength_X = (wind_strength_X > wind_velocity_max_X) ? wind_velocity_max_X : wind_strength_X;
      // std::cout << "[wind_strength_X ] :  (" << wind_strength_X << ")" << std::endl;

      // Y축 바람 세기
      double wind_strength_Y = wind_velocity_distribution_Y(wind_velocity_generator_Y);
      wind_strength_Y = std::abs(wind_strength_Y);
      wind_strength_Y = (wind_strength_Y > wind_velocity_max_Y) ? wind_velocity_max_Y : wind_strength_Y;
      // std::cout << "[wind_strength_Y ] :  (" << wind_strength_Y << ")" << std::endl;

      // Z축 바람 세기
      double wind_strength_Z = wind_velocity_distribution_Z(wind_velocity_generator_Z);
      // std::cout << "[1111111 wind_strength_Z ] :  (" << wind_strength_Z << ")" << std::endl;
      wind_strength_Z = std::abs(wind_strength_Z);
      // std::cout << "[2222222222 wind_strength_Z ] :  (" << wind_strength_Z << ")" << std::endl;
      wind_strength_Z = (wind_strength_Z > wind_velocity_max_Z) ? wind_velocity_max_Z : wind_strength_Z;
      // std::cout << "[3333333333 wind_strength_Z ] :  (" << wind_strength_Z << ")" << std::endl;

      wind_strength_XYZ.X(wind_strength_X);
      wind_strength_XYZ.Y(wind_strength_Y);
      wind_strength_XYZ.Z(wind_strength_Z);

      // std::cout << "[wind_strength_XYZ ] :  (" << wind_strength_XYZ << ")" << std::endl;
    }
    else
    {
      wind_strength = std::abs(wind_velocity_distribution_(wind_velocity_generator_)); // wind_velocity_distribution_ 평균 = a, 표준편차 = b 라는 정규분포에서, 아무거나 하나 뽑아준다
      wind_strength = (wind_strength > wind_velocity_max_) ? wind_velocity_max_ : wind_strength;
      // std::cout << "[wind_strength ] :  (" << wind_strength << ")" << std::endl;
    }

    

    if (my_wind_normal_distribution_XYZ_Direction->x() != 0 || my_wind_normal_distribution_XYZ_Direction->y() != 0 || my_wind_normal_distribution_XYZ_Direction->z() != 0)
    {
      wind_direction.X(my_wind_normal_distribution_XYZ_Direction->x());
      wind_direction.Y(my_wind_normal_distribution_XYZ_Direction->y());
      wind_direction.Z(my_wind_normal_distribution_XYZ_Direction->z());
      // std::cout << "[my_wind_normal_distribution_XYZ_Direction after  change] :  (" << wind_direction.X() << ", " << wind_direction.Y() << ", " << wind_direction.Z() << ")" << std::endl;
    }
    else
    {
      wind_direction.X() = wind_direction_distribution_X_(wind_direction_generator_);
      wind_direction.Y() = wind_direction_distribution_Y_(wind_direction_generator_);
      wind_direction.Z() = wind_direction_distribution_Z_(wind_direction_generator_);
      // std::cout << "[wind_direction after  change] :  (" << wind_direction.X() << ", " << wind_direction.Y() << ", " << wind_direction.Z() << ")" << std::endl;
    }

    

    // Calculate total wind velocity
    if (wind_strength_XYZ.X() != 0 || wind_strength_XYZ.Y() != 0 || wind_strength_XYZ.Z() != 0)
    {
      wind = wind_strength_XYZ * wind_direction;
      // std::cout << "[wind in if] :  (" << wind << ")" << std::endl;
    }
    else
    {
      wind = wind_strength * wind_direction;
      // std::cout << "[wind in else] :  (" << wind << ")" << std::endl;
    }


    // ------------------------------------------------- Gust ------------------------------------------------------------
    ignition::math::Vector3d wind_gust(0, 0, 0);
    // Calculate the wind gust velocity.
    if (now >= wind_gust_start_ && now < wind_gust_end_)
    {
      // Get normal distribution wind gust strength
      double wind_gust_strength = std::abs(wind_gust_velocity_distribution_(wind_gust_velocity_generator_));
      wind_gust_strength = (wind_gust_strength > wind_gust_velocity_max_) ? wind_gust_velocity_max_ : wind_gust_strength;
      // Get normal distribution wind gust direction
      ignition::math::Vector3d wind_gust_direction;
      wind_gust_direction.X() = wind_gust_direction_distribution_X_(wind_gust_direction_generator_);
      wind_gust_direction.Y() = wind_gust_direction_distribution_Y_(wind_gust_direction_generator_);
      wind_gust_direction.Z() = wind_gust_direction_distribution_Z_(wind_gust_direction_generator_);
      wind_gust = wind_gust_strength * wind_gust_direction;
    }
    // std::cout << "[wind_gust in Load] :  (" << my_wind_gust->x() << ", " << my_wind_gust->y() << ", " << my_wind_gust->z() << ")" << std::endl;

    if (my_wind_gust->x() != 0 || my_wind_gust->y() != 0 || my_wind_gust->z() != 0)
    {
      wind_gust.X(my_wind_gust->x());
      wind_gust.Y(my_wind_gust->y());
      wind_gust.Z(my_wind_gust->z());
      // std::cout << "[wind_gust after  change] :  (" << wind_gust.X() << ", " << wind_gust.Y() << ", " << wind_gust.Z() << ")" << std::endl;
    }

    // std::cout << "[wind_gust in Onupdate] :  (" << wind_v->x() << ", " << wind_v->y() << ", " << wind_v->z() << ")" << std::endl;

    // ------------------------------------------------- Ramp ------------------------------------------------------------
    // Calculate the wind with the added ramped up wind component
    double ramp_factor = 0.;
    if (wind_ramp_duration_.Double() > 0)
    {
      ramp_factor = constrain((now - wind_ramp_start_).Double() / wind_ramp_duration_.Double(), 0., 1.);
    }

    wind += ramp_factor * ramped_wind_vector;
    // wind = wind + (ramp_factor * ramped_wind_vector)
    // 여기서 wind는 ignition::math::Vector3d wind 타입이다.
    gazebo::msgs::Vector3d *wind_v = new gazebo::msgs::Vector3d();
    // new 란? int* ptr = new int; // 정수를 저장할 수 있는 메모리를 할당하고, 그 주소를 ptr에 저장합니다.
    // *ptr = 5; // 할당된 메모리에 5를 저장합니다.
    // 이 코드는 특히 Gazebo의 메시지 전송 시스템에서 사용될 벡터 데이터를 생성하고 초기화할 때 사용됩니다.

    wind_v->set_x(wind.X() + wind_gust.X());
    wind_v->set_y(wind.Y() + wind_gust.Y());
    wind_v->set_z(wind.Z() + wind_gust.Z());
    // std::cout << "[wind_v after change] :  (" << wind_v->x() << ", " << wind_v->y() << ", " << wind_v->z() << ")" << std::endl;



    wind_msg.set_frame_id(frame_id_);
    wind_msg.set_time_usec(now.Double() * 1e6);
    wind_msg.set_allocated_velocity(wind_v);
    // set_allocated_velocity는 gazebo::msgs::Vector3d 타입의 포인터를 받는다 즉, wind_v는 gazebo::msgs::Vector3d이다.
    /*
    inline void Wind::set_allocated_velocity(::gazebo::msgs::Vector3d* velocity) {
    ::google::protobuf::Arena* message_arena = GetArenaNoVirtual();
    if (message_arena == NULL) {
      delete reinterpret_cast< ::google::protobuf::MessageLite*>(velocity_);
    }
    if (velocity) {
      ::google::protobuf::Arena* submessage_arena = NULL;
      if (message_arena != submessage_arena) {
        velocity = ::google::protobuf::internal::GetOwnedMessage(
            message_arena, velocity, submessage_arena);
      }
      set_has_velocity();
    } else {
      clear_has_velocity();
    }
    velocity_ = velocity;
    // @@protoc_insertion_point(field_set_allocated:physics_msgs.msgs.Wind.velocity)
    }
    */
    // velocity_ 변수에 velocity의 포인터를 할당 즉, velocity_에 wind_v 의 포인터가 할당된다.
    // physics_msgs::msgs::Wind 타입인 wind_msg 이다.

    // my_wind_msg.set_frame_id(frame_id_); // frame_id_ 설정 필요
    // my_wind_msg.set_time_usec(now.Double() * 1e6); // now 업데이트 필요
    // my_wind_msg.set_allocated_velocity(my_wind_gust);
    // wind_pub_->Publish(my_wind_msg);
    wind_pub_->Publish(wind_msg);
    // gazebo::msgs::Vector3d 타입인 wind_v를 wind_pub이 pub 한다.
    // gazebo_wind_plugin.h 파일의 physics_msgs::msgs::Wind wind_msg 를 보낸다.
    // 보낸 wind_msg 는 void GazeboMotorModel::WindVelocityCallback(WindPtr& msg) 에서 WindVelocityCallback 이 콜백 함수가 받는다.
  }

  void GazeboWindPlugin::QueueThread()
  {
    static const double timeout = 0.01;

    while (this->rosNode->ok())
    {
      this->rosQueue.callAvailable(ros::WallDuration(timeout));
    }
  }

  void GazeboWindPlugin::OnWindMsg(const geometry_msgs::Vector3::ConstPtr &msg)
  {
    ignition::math::Vector3d my_wind_gust_ = ignition::math::Vector3d(msg->x, msg->y, msg->z);

    my_wind_gust->set_x(my_wind_gust_.X());
    my_wind_gust->set_y(my_wind_gust_.Y());
    my_wind_gust->set_z(my_wind_gust_.Z());

    std::cout << "[my_wind_gust after change] :  (" << my_wind_gust->x() << ", " << my_wind_gust->y() << ", " << my_wind_gust->z() << ")" << std::endl;

    // wind_pub_->Publish(my_wind_msg); // my_wind_pub_ 설정 및 초기화 필요
  }

  void GazeboWindPlugin::OnWindMsg1(const geometry_msgs::Vector3::ConstPtr &msg)
  {
    ignition::math::Vector3d my_wind_normal_distribution_Mean_Max_Variance_X_ = ignition::math::Vector3d(msg->x, msg->y, msg->z);

    my_wind_normal_distribution_Mean_Max_Variance_X->set_x(my_wind_normal_distribution_Mean_Max_Variance_X_.X());
    my_wind_normal_distribution_Mean_Max_Variance_X->set_y(my_wind_normal_distribution_Mean_Max_Variance_X_.Y());
    my_wind_normal_distribution_Mean_Max_Variance_X->set_z(my_wind_normal_distribution_Mean_Max_Variance_X_.Z());

    std::cout << "[my_wind_normal_distribution_Mean_Max_Variance_X after change] :  (" << my_wind_normal_distribution_Mean_Max_Variance_X->x() << ", " << my_wind_normal_distribution_Mean_Max_Variance_X->y() << ", " << my_wind_normal_distribution_Mean_Max_Variance_X->z() << ")" << std::endl;

    // wind_pub_->Publish(my_wind_msg); // my_wind_pub_ 설정 및 초기화 필요
  }

  void GazeboWindPlugin::OnWindMsg2(const geometry_msgs::Vector3::ConstPtr &msg)
  {
    ignition::math::Vector3d my_wind_normal_distribution_Mean_Max_Variance_Y_ = ignition::math::Vector3d(msg->x, msg->y, msg->z);

    my_wind_normal_distribution_Mean_Max_Variance_Y->set_x(my_wind_normal_distribution_Mean_Max_Variance_Y_.X());
    my_wind_normal_distribution_Mean_Max_Variance_Y->set_y(my_wind_normal_distribution_Mean_Max_Variance_Y_.Y());
    my_wind_normal_distribution_Mean_Max_Variance_Y->set_z(my_wind_normal_distribution_Mean_Max_Variance_Y_.Z());

    std::cout << "[my_wind_normal_distribution_Mean_Max_Variance_Y after change] :  (" << my_wind_normal_distribution_Mean_Max_Variance_Y->x() << ", " << my_wind_normal_distribution_Mean_Max_Variance_Y->y() << ", " << my_wind_normal_distribution_Mean_Max_Variance_Y->z() << ")" << std::endl;

    // wind_pub_->Publish(my_wind_msg); // my_wind_pub_ 설정 및 초기화 필요
  }

  void GazeboWindPlugin::OnWindMsg3(const geometry_msgs::Vector3::ConstPtr &msg)
  {
    ignition::math::Vector3d my_wind_normal_distribution_Mean_Max_Variance_Z_ = ignition::math::Vector3d(msg->x, msg->y, msg->z);

    my_wind_normal_distribution_Mean_Max_Variance_Z->set_x(my_wind_normal_distribution_Mean_Max_Variance_Z_.X());
    my_wind_normal_distribution_Mean_Max_Variance_Z->set_y(my_wind_normal_distribution_Mean_Max_Variance_Z_.Y());
    my_wind_normal_distribution_Mean_Max_Variance_Z->set_z(my_wind_normal_distribution_Mean_Max_Variance_Z_.Z());

    std::cout << "[my_wind_normal_distribution_Mean_Max_Variance_Z after change] :  (" << my_wind_normal_distribution_Mean_Max_Variance_Z->x() << ", " << my_wind_normal_distribution_Mean_Max_Variance_Z->y() << ", " << my_wind_normal_distribution_Mean_Max_Variance_Z->z() << ")" << std::endl;

    // wind_pub_->Publish(my_wind_msg); // my_wind_pub_ 설정 및 초기화 필요
  }

  void GazeboWindPlugin::OnWindMsg4(const geometry_msgs::Vector3::ConstPtr &msg)
  {
    ignition::math::Vector3d my_wind_normal_distribution_XYZ_Direction_ = ignition::math::Vector3d(msg->x, msg->y, msg->z);

    my_wind_normal_distribution_XYZ_Direction->set_x(my_wind_normal_distribution_XYZ_Direction_.X());
    my_wind_normal_distribution_XYZ_Direction->set_y(my_wind_normal_distribution_XYZ_Direction_.Y());
    my_wind_normal_distribution_XYZ_Direction->set_z(my_wind_normal_distribution_XYZ_Direction_.Z());

    std::cout << "[my_wind_normal_distribution_XYZ_Direction after change] :  (" << my_wind_normal_distribution_XYZ_Direction->x() << ", " << my_wind_normal_distribution_XYZ_Direction->y() << ", " << my_wind_normal_distribution_XYZ_Direction->z() << ")" << std::endl;

    // wind_pub_->Publish(my_wind_msg); // my_wind_pub_ 설정 및 초기화 필요
  }

  bool GazeboWindPlugin::isZero(const gazebo::msgs::Vector3d *check_for_Mean_Max_Variacne)
  {
    // if (check_for_Mean_Max_Variacne == nullptr)
    //   return true; // 혹은 false. 상황에 따라 다르게 리턴

    return check_for_Mean_Max_Variacne->x() == 0 && check_for_Mean_Max_Variacne->y() == 0 && check_for_Mean_Max_Variacne->z() == 0;
  }

  GZ_REGISTER_WORLD_PLUGIN(GazeboWindPlugin); // 월드 일경우 GZ_REGISTER_WORLD_PLUGIN 마무리
  // GZ_REGISTER_MODEL_PLUGIN 모델이면 이걸로 마무리
  // GZ_REGISTER_SENSOR_PLUGIN
  // GZ_REGISTER_GUI_PLUGIN
  // GZ_REGISTER_SYSTEM_PLUGIN
  // GZ_REGISTER_VISUAL_PLUGIN
}
