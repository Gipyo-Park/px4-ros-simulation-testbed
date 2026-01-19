/****************************************************************************
 *
 *   Copyright (c) 2024 Your Development Team. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 * 3. Neither the name of Your Team nor the names of its contributors may be
 *    used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 ****************************************************************************/

#include "custom_motor_failure_number.hpp"

CustomMotorFailureNumber::CustomMotorFailureNumber() :
	ModuleParams(nullptr),
	ScheduledWorkItem(MODULE_NAME, px4::wq_configurations::test1)
{
}

CustomMotorFailureNumber::~CustomMotorFailureNumber()
{
	perf_free(_loop_perf);
	perf_free(_loop_interval_perf);
}

bool CustomMotorFailureNumber::init()
{
	// Run() 메서드를 매번 호출하도록 콜백을 등록
	if (!_key_command_sub.registerCallback()) {
		PX4_ERR("Callback registration failed");
		return false;
	}

	// 일정 시간 간격마다 실행을 원할 경우
	// ScheduleOnInterval(5000_us); // 예: 200 Hz로 실행

	return true;
}

void CustomMotorFailureNumber::Run()
{
	/*
	  /home/hmcl/PX4_testbed/PX4-Autopilot/ROMFS/px4fmu_common/init.d-posix/rcS 에 가서
	  custom_motor_failure_number start 를 지우면 custom_motor_failure_number 가 자동 실행이 안된다
	  내가 이렇게 해놓은 이유는
	  px4 터미널에서 custom_motor_failure_number start 명령을 실행하지 않으면 모듈이 백그라운드에서 실행되지 않기 때문에, 퍼블리시 작업도 수행되지 않아서이다.

	  PX4에서 모듈이 정상적으로 작동하려면 task_spawn() 함수가 호출되어 인스턴스가 생성되고,
	  init()이 완료된 후 Run() 메서드가 주기적으로 실행되는 흐름이 필요합니다.
	  이 흐름이 시작되려면 명령어로 모듈을 시작해야 합니다. Run() 메서드 내의 PX4_INFO 출력과 데이터 퍼블리시는 모두 Run()이 호출될 때 이루어지므로,
	  start 명령이 실행되지 않으면 이 작업들이 수행되지 않습니다
	*/
	if (should_exit()) {
		ScheduleClear();
		exit_and_cleanup();
		return;
	}

	perf_begin(_loop_perf);
	perf_count(_loop_interval_perf);

	// 파라미터 업데이트 확인 및 적용
	if (_parameter_update_sub.updated()) {
		parameter_update_s param_update;
		_parameter_update_sub.copy(&param_update);
		updateParams(); // DEFINE_PARAMETERS에 정의된 모듈 파라미터 업데이트
	}

	// 모터 고장 번호 구독 데이터 확인
	if (_key_command_sub.updated()) {

		_key_command_sub.copy(&input);

		motor_failure_data.timestamp = input.timestamp;
                // PX4_INFO("[custom_motor_failure_number] Received Time Boot (ms) in PX4 module: %llu", static_cast<unsigned long long>(motor_failure_data.timestamp));

		strncpy(motor_failure_data.key, input.key, 10);
                // PX4_INFO("[custom_motor_failure_number] Received Char in PX4 module: %s", motor_failure_data.key);

                motor_failure_data.uorb_motor_failure_number = input.value;
                // PX4_INFO("[custom_motor_failure_number] Received value in PX4 module: %f", static_cast<double>(motor_failure_data.uorb_motor_failure_number));
		// PX4_INFO("[custom_motor_failure_number] _key_command_sub is updated");

	        bool changed = false;

        	// Compare float values carefully (exact compare OK if set externally)
        	if (!std::isfinite(_prev_value) || std::fabs(input.value - _prev_value) > 1e-3f) {
        	    _prev_value = input.value;
        	    changed     = true;
        	}

        	// Compare fixed‐length C strings
        	if (strncmp(input.key, _prev_key, sizeof(_prev_key)) != 0) {
        	    strncpy(_prev_key, input.key, sizeof(_prev_key));
        	    changed = true;
        	}


		// d = 100, 단일 모터 열을 비활성화해서 FTC 고장 모드 (yaw 포기 X)
		// e = 101, 다중 모터 열을 비활성화해서 FTC 고장 모드 (yaw 포기 X)
		// f = 102, 단일 모터 열 + yaw 행을 비활성화해서 FTC 고장 모드 (yaw 포기 O)
		// g = 103, 다중 모터 열 + yaw 행을 비활성화해서 FTC 고장 모드 (yaw 포기 O)
        	if (changed) {
         		const char *mode;
    			if (_prev_key[0] == 'd') {
        			mode = "single reallocation (yaw maintained)";
    			} else if (_prev_key[0] == 'e') {
        			mode = "multi reallocation (yaw maintained)";
    			} else if (_prev_key[0] == 'f') {
        			mode = "single reallocation (yaw abandoned)";
    			} else if (_prev_key[0] == 'g') {
        			mode = "multi reallocation (yaw abandoned)";
    			} else {
        			mode = "No reallocation";
    			}
			PX4_INFO(" %s-failure mode, number: %.3f", mode, static_cast<double>(_prev_value));
        	}




	}

	_motor_failure_pub.publish(motor_failure_data); // 데이터 발행

	perf_end(_loop_perf);
}

int CustomMotorFailureNumber::task_spawn(int argc, char *argv[])
{
	CustomMotorFailureNumber *instance = new CustomMotorFailureNumber();

	if (instance) {
		_object.store(instance);
		_task_id = task_id_is_work_queue;

		if (instance->init()) {
			return PX4_OK;
		}

	} else {
		PX4_ERR("Allocation failed");
	}

	delete instance;
	_object.store(nullptr);
	_task_id = -1;

	return PX4_ERROR;
}

int CustomMotorFailureNumber::print_status()
{
	perf_print_counter(_loop_perf);
	perf_print_counter(_loop_interval_perf);
	return 0;
}

int CustomMotorFailureNumber::custom_command(int argc, char *argv[])
{
	return print_usage("Unknown command");
}

int CustomMotorFailureNumber::print_usage(const char *reason)
{
	if (reason) {
		PX4_WARN("%s\n", reason);
	}

	PRINT_MODULE_DESCRIPTION(
		R"DESCR_STR(
### Description
Example of a simple module to publish and subscribe to a custom motor failure number topic.

)DESCR_STR");

	PRINT_MODULE_USAGE_NAME("custom_motor_failure_number", "template");
	PRINT_MODULE_USAGE_COMMAND("start");
	PRINT_MODULE_USAGE_DEFAULT_COMMANDS();

	return 0;
}

extern "C" __EXPORT int custom_motor_failure_number_main(int argc, char *argv[])
{
	return CustomMotorFailureNumber::main(argc, argv);
}
