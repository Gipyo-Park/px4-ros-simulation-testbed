# Performance and Control-Authority Evaluation

## Control Authority

<img src="../assets/images/control-authority-analysis.png" width="100%" alt="Control authority analysis">

The available roll, pitch, yaw-moment, and thrust combinations are compared for
nominal and faulty actuator configurations. The resulting hulls visualize how
each fault changes the feasible control allocation space.

## Safety-Performance Envelope

The operating-condition grid is evaluated using:

- Trajectory-tracking error
- Feasible controllability or control-margin metric
- Threshold-based valid operating area
- Fault configuration and wind condition

### Nominal Configuration

<img src="../assets/images/safety-envelope-nominal.png" width="100%" alt="Nominal safety envelope">

### Single-Motor Fault

<img src="../assets/images/safety-envelope-single-fault.png" width="100%" alt="Single-motor fault safety envelope">

### Double-Motor Fault Comparisons

<img src="../assets/images/safety-envelope-double-fault-critical.png" width="100%" alt="Critical double-motor fault safety envelope">

<img src="../assets/images/safety-envelope-double-fault-tolerant.png" width="100%" alt="Fault-tolerant double-motor safety envelope">

The comparison shows that fault geometry can be as important as fault count.
Different double-motor combinations may leave substantially different feasible
control regions.

## Active Sampling

<img src="../assets/images/active-sampling-workflow.png" width="100%" alt="Active sampling workflow">

Simulation samples are used to train a Gaussian-process surrogate. Predicted
mean and uncertainty maps guide selection of the next operating condition,
reducing redundant simulations while refining the estimated safety envelope.

<img src="../assets/images/active-sampling-results.png" width="100%" alt="Active sampling results">

The comparison reports prediction error against the number of simulations for
random, passive, and active-sampling strategies.
