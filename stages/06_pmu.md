# Stage 6: Performance Monitoring Unit (PMU)

## 🎯 Objective
Operating as an independent, non-intrusive co-processing stage, the PMU acts as an on-chip logic analyzer layer. It profiles the entire core runtime, measuring code execution health, bubble overhead penalties, and structural efficiency metrics from the outside.

## ⚙️ Hardware Operation
* **Passive Observation Matrix:** Rather than intercepting or modifying data path routes, the PMU hooks onto the pipeline stage tracking registers to observe active state shifts.
* **Metric Counter Tracking Engine:**
  * **Clock Cycles:** Increments a master 32-bit cycle counter unconditionally on every rising edge until the system asserts a hardware halt state.
  * **Valid Instruction Retirement:** Monitored at the write-back stage. Ticks upward only when a genuine operation completes its cycle, skipping past bubble placeholders.
  * **Bubble Logging:** Keeps a running count of software-inserted `NOP` commands passing through the decode phase to measure data-dependency costs.
* **Core CPI Evaluation:** Upon core termination, the PMU reads out all accumulated tracking figures to evaluate the complete architectural **Cycles Per Instruction (CPI)** performance rating of the system:
  $$\text{CPI} = \frac{\text{Total Clock Cycles}}{\text{Valid Instructions Retired}}$$
