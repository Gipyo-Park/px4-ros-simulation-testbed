# SILS and Scenario Injection

## Integrated Environment

The SILS environment combines:

- PX4 flight-control software
- Gazebo Classic vehicle dynamics
- ROS and MAVLink communication
- QGroundControl monitoring
- MATLAB/Simulink data collection and performance evaluation

<img src="../assets/images/integrated-sils-environment.png" width="100%" alt="Integrated SILS environment">

## Motor Fault Injection

<img src="../assets/images/motor-fault-injection.png" width="100%" alt="Motor fault injection workflow">

The test scenario selects a fault type and motor index. The command is forwarded
through ROS/MAVLink and applied to the Gazebo motor model, enabling repeatable
nominal and faulty runs under otherwise equivalent operating conditions.

## Wind Disturbance Injection

<img src="../assets/images/wind-disturbance-injection.png" width="100%" alt="Wind disturbance injection workflow">

The ROS wind publishers generate steady, gust, and stochastic wind conditions.
The Gazebo wind plugin applies these conditions to the octocopter model.

<img src="../assets/images/wind-aerodynamic-model.png" width="100%" alt="Wind and rotor aerodynamic model">

## Automation Workflow

The automation sequence is organized around four steps:

1. Select the vehicle, fault configuration, wind condition, trajectory, and controller option.
2. Start PX4, Gazebo, ROS/MAVROS, QGroundControl, and MATLAB/Simulink interfaces.
3. Execute the flight scenario and collect state, setpoint, and control-effort data.
4. Calculate tracking and controllability metrics and store the result for envelope generation.

Exact launch commands and environment versions should be recorded after the
current test configuration is confirmed.
