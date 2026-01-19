#ifndef CUSTOM_VEHICLE_TORQUE_SETPOINT_HPP
#define CUSTOM_VEHICLE_TORQUE_SETPOINT_HPP

#include <uORB/topics/vehicle_torque_setpoint.h>
#include <uORB/topics/vehicle_control_mode.h>
#include <uORB/topics/offboard_control_mode.h>

class MavlinkStreamVehicleTorqueSetpoint : public MavlinkStream
{
public:
    const char *get_name() const
    {
        return get_name_static();
    }
    static const char *get_name_static()
    {
        return "CUSTOM_VEHICLE_TORQUE_SETPOINT";
    }
    static uint16_t get_id_static()
    {
        return MAVLINK_MSG_ID_CUSTOM_VEHICLE_TORQUE_SETPOINT;
    }
    uint16_t get_id()
    {
        return get_id_static();
    }
    static MavlinkStream *new_instance(Mavlink *mavlink)
    {
        return new MavlinkStreamVehicleTorqueSetpoint(mavlink);
    }
    unsigned get_size()
    {
        return _torque_setpoint_sub.advertised() ? MAVLINK_MSG_ID_CUSTOM_VEHICLE_TORQUE_SETPOINT_LEN + MAVLINK_NUM_NON_PAYLOAD_BYTES : 0;
    }

private:
    explicit MavlinkStreamVehicleTorqueSetpoint(Mavlink *mavlink) : MavlinkStream(mavlink) {}

    uORB::Subscription _torque_setpoint_sub{ORB_ID(vehicle_torque_setpoint)};
    uORB::Subscription _torque_setpoint_offboard_sub{ORB_ID(vehicle_torque_setpoint_offboard)};
    uORB::Subscription _vehicle_control_mode_sub{ORB_ID(vehicle_control_mode)};
    uORB::Subscription _offboard_control_mode_sub{ORB_ID(offboard_control_mode)};




    bool send() override
    {
        // PX4_INFO("[VEHICLE_TORQUE_SETPOINT] hihihihihihihihihi");

        struct vehicle_torque_setpoint_s _torque_setpoint;    // make sure vehicle_torque_setpoint_s is the definition of your uORB topic

        // ✅ ControlAllocator와 동일한 조건 사용
        offboard_control_mode_s offboard_mode{};
        _offboard_control_mode_sub.copy(&offboard_mode);
        const bool is_offboard_actuator = offboard_mode.actuator;

        vehicle_control_mode_s control_mode{};
        _vehicle_control_mode_sub.copy(&control_mode);
        const bool is_offboard_mode = control_mode.flag_control_offboard_enabled;
        const bool is_rate_control_mode = control_mode.flag_control_rates_enabled;
        const bool is_attitude_control_mode = control_mode.flag_control_attitude_enabled;

        bool updated = false;

        // ✅ ControlAllocator.cpp와 동일한 조건
        if (!is_rate_control_mode && is_offboard_mode && is_offboard_actuator) {
            // Offboard 모드: offboard 토픽 사용
            updated = _torque_setpoint_offboard_sub.update(&_torque_setpoint);

        } else if (is_rate_control_mode && is_attitude_control_mode && !is_offboard_actuator) {
            // 내부 Rate Controller 모드: 내부 토픽 사용
            updated = _torque_setpoint_sub.update(&_torque_setpoint);
        }


        if (updated) {

            mavlink_custom_vehicle_torque_setpoint_t _msg_torque_setpoint{};  // make sure mavlink_vehicle_torque_setpoint_t is the definition of your custom MAVLink message

            _msg_torque_setpoint.timestamp = _torque_setpoint.timestamp;
            _msg_torque_setpoint.timestamp_sample = _torque_setpoint.timestamp_sample;
            _msg_torque_setpoint.x = _torque_setpoint.xyz[0];
            _msg_torque_setpoint.y = _torque_setpoint.xyz[1];
            _msg_torque_setpoint.z = _torque_setpoint.xyz[2];

            // PX4_INFO("[VEHICLE_TORQUE_SETPOINT] Torque setpoints received in PX4 module: [%f, %f, %f]",
            //          static_cast<double>(_msg_torque_setpoint.x),
            //          static_cast<double>(_msg_torque_setpoint.y),
            //          static_cast<double>(_msg_torque_setpoint.z));

            mavlink_msg_custom_vehicle_torque_setpoint_send_struct(_mavlink->get_channel(), &_msg_torque_setpoint);

            return true;
        }

        return false;
    }
};

#endif // CUSTOM_VEHICLE_TORQUE_SETPOINT_HPP
