#ifndef CUSTOM_VEHICLE_THRUST_SETPOINT_HPP
#define CUSTOM_VEHICLE_THRUST_SETPOINT_HPP

#include <uORB/topics/vehicle_thrust_setpoint.h>
#include <uORB/topics/vehicle_control_mode.h>
#include <uORB/topics/offboard_control_mode.h>

class MavlinkStreamVehicleThrustSetpoint : public MavlinkStream
{
public:
    const char *get_name() const
    {
        return get_name_static();
    }
    static const char *get_name_static()
    {
        return "CUSTOM_VEHICLE_THRUST_SETPOINT";
    }
    static uint16_t get_id_static()
    {
        return MAVLINK_MSG_ID_CUSTOM_VEHICLE_THRUST_SETPOINT;
    }
    uint16_t get_id()
    {
        return get_id_static();
    }
    static MavlinkStream *new_instance(Mavlink *mavlink)
    {
        return new MavlinkStreamVehicleThrustSetpoint(mavlink);
    }
    unsigned get_size()
    {
        return _thrust_setpoint_sub.advertised() ? MAVLINK_MSG_ID_CUSTOM_VEHICLE_THRUST_SETPOINT_LEN + MAVLINK_NUM_NON_PAYLOAD_BYTES : 0;
    }

private:
    explicit MavlinkStreamVehicleThrustSetpoint(Mavlink *mavlink) : MavlinkStream(mavlink) {}

    uORB::Subscription _thrust_setpoint_sub{ORB_ID(vehicle_thrust_setpoint)};
    uORB::Subscription _thrust_setpoint_offboard_sub{ORB_ID(vehicle_thrust_setpoint_offboard)};
    uORB::Subscription _vehicle_control_mode_sub{ORB_ID(vehicle_control_mode)};
    uORB::Subscription _offboard_control_mode_sub{ORB_ID(offboard_control_mode)};



    bool send() override
    {
        struct vehicle_thrust_setpoint_s _thrust_setpoint;  // uORB topic definition for thrust setpoint

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
            updated = _thrust_setpoint_offboard_sub.update(&_thrust_setpoint);

        } else if (is_rate_control_mode && is_attitude_control_mode && !is_offboard_actuator) {
            // 내부 Rate Controller 모드: 내부 토픽 사용
            updated = _thrust_setpoint_sub.update(&_thrust_setpoint);
        }

        if (updated) {

            // _thrust_setpoint_sub.copy(&_thrust_setpoint);
            mavlink_custom_vehicle_thrust_setpoint_t _msg_thrust_setpoint{};  // Custom MAVLink message for thrust

            _msg_thrust_setpoint.timestamp = _thrust_setpoint.timestamp;
            _msg_thrust_setpoint.timestamp_sample = _thrust_setpoint.timestamp_sample;
            _msg_thrust_setpoint.x = _thrust_setpoint.xyz[0];
            _msg_thrust_setpoint.y = _thrust_setpoint.xyz[1];
            _msg_thrust_setpoint.z = _thrust_setpoint.xyz[2];

            // PX4_INFO("[VEHICLE_THRUST_SETPOINT] Thurst setpoints received in PX4 module: [%f, %f, %f]",
            //          static_cast<double>(_msg_thrust_setpoint.x),
            //          static_cast<double>(_msg_thrust_setpoint.y),
            //          static_cast<double>(_msg_thrust_setpoint.z));

            mavlink_msg_custom_vehicle_thrust_setpoint_send_struct(_mavlink->get_channel(), &_msg_thrust_setpoint);

            return true;
        }

        return false;
    }
};

#endif // CUSTOM_VEHICLE_THRUST_SETPOINT_HPP
