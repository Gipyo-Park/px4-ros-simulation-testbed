# PX4 Testbed Directory Guide

This directory contains the PX4/Gazebo side of the octocopter SIL/HIL testbed.
The documentation focuses on project-relevant additions and modifications
rather than listing every upstream PX4 directory.

## Main Components

| Path | Role | Scope |
| --- | --- | --- |
| `PX4-Autopilot/` | PX4 firmware and Gazebo Classic simulation source | Integrated and modified |
| `PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic/` | Gazebo Classic plugins, worlds, and vehicle models | Modified |
| `octocopter_matlab/` | Octocopter model and analysis-related working files | Project-specific |
| `Filehistory` | Previous implementation and modification notes | Project-specific documentation |
| `Troubleshooting` | Recorded setup and debugging notes | Project-specific documentation |

## Fault-Injection Components

| Path | Purpose |
| --- | --- |
| `.../src/gazebo_motor_failure_plugin.cpp` | Receives a selected motor-failure command and applies it to the simulated vehicle |
| `.../include/gazebo_motor_failure_plugin.h` | Motor-failure plugin interface |
| `.../src/gazebo_motor_model.cpp` | Simulated rotor force, torque, and motor response |
| `.../include/gazebo_motor_model.h` | Motor-model parameters and interfaces |
| `.../models/octocopter3/` | Octocopter model used for nominal and fault scenarios |
| `.../models/octocopter3_hitl/` | Vehicle model configuration prepared for HITL operation |

The ellipsis above refers to:

```text
PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic
```

## Wind-Disturbance Components

| Path | Purpose |
| --- | --- |
| `.../src/gazebo_wind_plugin.cpp` | Applies wind velocity and disturbance conditions in Gazebo |
| `.../include/gazebo_wind_plugin.h` | Wind-plugin parameters and interfaces |
| `.../worlds/windy.world` | Gazebo world configured for wind testing |
| `.../models/octocopter3/*.sdf` | Vehicle-side plugin and aerodynamic configuration |

Wind commands are generated on the ROS side and transferred to the Gazebo
simulation. See the
[`catkin_workspace`](https://github.com/Gipyo-Park/catkin_workspace)
repository for the ROS publishers and communication packages.

## Data Flow

```mermaid
flowchart LR
    A["ROS Scenario Command"] --> B["MAVLink / Gazebo Interface"]
    B --> C["PX4 + Vehicle Model"]
    C --> D["Flight State & Control Data"]
    D --> E["MATLAB / Simulink Evaluation"]
```

## Recommended Documentation Cleanup

The existing history and troubleshooting files can be retained while giving
them standard Markdown names:

```text
docs/
├── change-history.md
└── troubleshooting.md
```

When reorganizing these files, preserve their Git history with `git mv`.

## Upstream Source

The PX4 source tree originates from
[PX4/PX4-Autopilot](https://github.com/PX4/PX4-Autopilot). Project-specific
documentation should identify which files were added or modified so that the
engineering contribution remains clear.
