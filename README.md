# MIPS32 Pipelined Processor with Performance Monitoring Unit (PMU)

A structural-behavioral 5-stage pipelined MIPS32 processor core engineered in Verilog. This architecture replaces complex dynamic hazard-forwarding logic with a predictable, hazard-free software-spaced configuration using a non-FIFO, dual-phase clocking scheme. To profile execution overhead dynamically, the design features an embedded silicon-level Performance Monitoring Unit (PMU) that tracks clock cycles, instruction retirement rates, and core CPI metrics in real time.

---

## 📖 Architectural Design & Overview

Traditional basic pipeline layouts operate as architectural "black boxes"—making tracking and diagnostic monitoring on real hardware highly opaque. This processor implements an external observation layer directly on top of a classic RISC execution datapath. 

Instead of routing massive, error-prone bypass busses across long silicon distances to fix data dependencies dynamically, this design decouples the hazards at the software layer using explicit spacing constraints. This layout allows for high-frequency operations by keeping the logic pathways of individual stages incredibly lean.

[Image of 5 stage MIPS pipeline datapath]

### The Non-FIFO Dual-Phase Clocking Strategy
The processor operates using two discrete clock trees (`clk1` and `clk2`) running completely out of phase:
* **`clk1`** drives the Instruction Fetch (IF), Execute (EX), and Write Back (WB) stages.
* **`clk2`** drives the Instruction Decode (ID) and Memory Access (MEM) stages.

By shifting consecutive execution segments onto alternating half-cycles, the architecture eliminates the requirement for complex structural FIFO buffers between pipeline registers, ensuring synchronized data transitions across stage boundaries.

---

## 🧩 The 5 Core Pipeline Stages

The structural execution stream splits the instruction lifecycle across 5 distinct hardware domains:

1. **Instruction Fetch (IF):** Evaluates branch target decisions from the EX/MEM stage or increments the Program Counter (`PC`) consecutively by 4 bytes to latch the next machine word from instruction memory (`Mem`).
2. **Instruction Decode (ID):** Maps instructions into structural parameters (`RR_ALU`, `RM_ALU`, `LOAD`, `STORE`, `BRANCH`), extracts immediate values with full 32-bit sign extension, and retrieves operands out of the Register File (`Reg`).
3. **Execute (EX):** Computes operations through a custom combinational logic unit supporting standard math, comparison arrays, logical strings, and dedicated hardware-level multiplication blocks (`MUL`).
4. **Memory Access (MEM):** Handles data memory interfaces. Reads data words from RAM via Load Word (`LW`) using the ALU output as an address, or commits data directly to storage during Store Word (`SW`) cycles.
5. **Write Back (WB):** Commits retired computation results or memory read streams permanently back into the target destination register within the Register File and checks for termination codes (`HLT`) to safely park the core.

---

## 📊 Performance Monitoring Unit (PMU) Diagnostics

The embedded **Performance Monitoring Unit (PMU)** acts as an on-chip logic analyzer, tapping directly into pipeline register control lines from the outside to generate concrete performance analytics:

* **Total Clock Cycles:** Measures absolute hardware execution duration.
* **Instructions Retired:** Increments only when a valid operation clears the final Write Back stage (ignoring padding or speculative entries).
* **Software-Injected Bubbles:** Measures the exact code density overhead required to maintain data dependency safety.
* **Core CPI Computation:** Computes the mathematical efficiency threshold of the compilation stream:
  $$\text{CPI} = \frac{\text{Total Elapsed Clock Cycles}}{\text{Valid Retired Instructions}}$$

---

## 🚀 Simulation Commands & Verification Waveforms

### 1. Toolchain Setup
Compile the design and view the hardware trace layout via Icarus Verilog and GTKWave using your terminal terminal engine:

```bash
# Compile the module and testbench together
iverilog -o mips_pmu_sim pipe_MIPS32.v tb_pipe_MIPS32.v

# Execute simulation to generate trace file (.vcd)
vvp mips_pmu_sim

# Open trace file inside GTKWave
gtkwave mips_pipeline.vcd
