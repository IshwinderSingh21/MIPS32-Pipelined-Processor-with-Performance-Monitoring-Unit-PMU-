# MIPS32 Pipelined Processor with Performance Monitoring Unit (PMU)

A clean, structural-behavioral 5-stage pipelined MIPS32 processor core implemented in Verilog. This architecture focuses on a streamlined baseline pipeline design where data dependencies and hazards are handled cleanly at the software layer using explicit spacing. To dynamically profile execution efficiency, the core features an integrated silicon-level Performance Monitoring Unit (PMU) that tracks clock cycles, instruction retirement rates, and real-world CPI metrics.

---

## 📖 Architectural Design & Overview

Traditional pipeline implementations often become highly complex due to massive, error-prone bypass networks and hardware interlocking blocks. This processor layout takes a different approach: it keeps the physical stage datapaths completely lean and high-frequency by offloading dependency management entirely to software spacing. 

By utilizing explicit code padding constraints, each instruction is guaranteed to have fully completed its write-back cycle before subsequent dependent operations read the register file. Built directly on top of this streamlined execution stream is an independent hardware analysis layer that tracks exactly how well the program is running.

---

## 🧩 The 5 Core Pipeline Stages



The execution datapath divides the instruction lifecycle across 5 classic synchronous hardware domains:

1. **Instruction Fetch (IF):** Evaluates branch target updates from the MEM stage or increments the Program Counter (`PC`) consecutively by 4 bytes to pull the next 32-bit machine word from instruction memory (`Mem`).
2. **Instruction Decode (ID):** Decodes raw instruction bits into core structural execution types (`RR_ALU`, `RM_ALU`, `LOAD`, `STORE`, `BRANCH`), handles 32-bit sign extension for immediates, and reads source operands out of the Register File (`Reg`).
3. **Execute (EX):** Computes arithmetic, logical, and comparison operations via a combinational ALU, featuring an integrated dedicated hardware multiplication array (`MUL`). It also evaluates branch conditions and calculates target addresses.
4. **Memory Access (MEM):** Interacts with the data memory layout. Reads data words from RAM via Load Word (`LW`) or writes register contents straight to a target address during Store Word (`SW`) cycles.
5. **Write Back (WB):** The final retirement stage. Commits computational data or memory read streams permanently back into the destination registers inside the main Register File and monitors the master termination flag (`HLT`) to safely stop the simulation.

---

## 📊 Performance Monitoring Unit (PMU) Diagnostics

The embedded **Performance Monitoring Unit (PMU)** acts as an on-chip logic analyzer, tapping directly into pipeline stage registers from the outside to generate concrete performance analytics:

* **Total Clock Cycles:** Measures absolute hardware execution runtime.
* **Instructions Retired:** Increments only when a valid operation clears the final Write Back stage (ignoring padding or speculative entries).
* **Software-Injected Bubbles:** Measures the exact code density overhead required to maintain data dependency safety.
* **Core CPI Computation:** Computes the mathematical efficiency threshold of the compilation stream:
  $$\text{CPI} = \frac{\text{Total Elapsed Clock Cycles}}{\text{Valid Retired Instructions}}$$

---

## 🚀 Simulation Commands & Verification Waveforms

### 1. Toolchain Setup
Compile the design and view the hardware trace layout via Icarus Verilog and GTKWave using your terminal engine:

```bash
# Compile the module and testbench together
iverilog -o sim_mips21 tb_pipe_MIPS32.v mips32.v

# Execute simulation to generate trace file (.vcd)
vvp sim_mips21

# Open trace file inside GTKWave
gtkwave mips_pipeline.vcd
