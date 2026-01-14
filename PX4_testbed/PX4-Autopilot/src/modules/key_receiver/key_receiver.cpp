#include <px4_platform_common/px4_config.h>
#include <px4_platform_common/tasks.h>
#include <px4_platform_common/posix.h>
#include <px4_platform_common/log.h>  // 로그 매크로 사용을 위한 헤더
#include <unistd.h>
#include <stdio.h>
#include <poll.h>
#include <string.h>
#include <math.h>

#include <uORB/uORB.h>
#include <uORB/topics/key_command.h>
// # include <uORB/topics/debug_key_value.h>

extern "C" __EXPORT int key_receiver_main(int argc, char **argv);

int key_receiver_main(int argc, char **argv)
{
    int key_sub_fd = orb_subscribe(ORB_ID(key_command));
    orb_set_interval(key_sub_fd, 200); // limit the update rate to 200ms

    px4_pollfd_struct_t fds[] = {
        { .fd = key_sub_fd,   .events = POLLIN },
    };

    int error_counter = 0;

    for (int i = 0; i < 10; i++)
    {
        int poll_ret = px4_poll(fds, 1, 1000);

        if (poll_ret == 0)
        {
            PX4_ERR("Got no data within a second");
        }
        else if (poll_ret < 0)
        {
            if (error_counter < 10 || error_counter % 50 == 0)
            {
                PX4_ERR("ERROR return value from poll(): %d", poll_ret);
            }

            error_counter++;
        }
        else
        {
            if (fds[0].revents & POLLIN)
            {
                // struct key_command_s input;
                key_command_s input{};
                orb_copy(ORB_ID(key_command), key_sub_fd, &input);

                double received_time_boot_ms = static_cast<double>(input.timestamp);
                (void)received_time_boot_ms;  // 이 한 줄로 경고 제거 끝!
                // PX4_INFO("[key_receiver] Received Time Boot (ms) in PX4 module: %f", received_time_boot_ms);

                char received_key[10];
                strncpy(received_key, input.key, 10);
                // double received_key = static_cast<double>(input.key);
                // PX4_INFO("[key_receiver] Received Char in PX4 module: %s", received_key);

                double received_value = static_cast<double>(input.value);
                (void)received_value;  // 이 한 줄로 경고 제거 끝!
                // PX4_INFO("[key_receiver] Received value in PX4 module: %f", received_value);
             }
        }
    }
    return 0;
}
