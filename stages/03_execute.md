# Stage 3: Execute (EX)

## 🎯 Objective
The mathematical and logical engine of the processing core. It manipulates the prepared register operands or immediate inputs to compute the final instruction data state.

## ⚙️ Hardware Operation
* **Combinational ALU Core:** Executes basic math and logical pathways based on the assigned instruction type decoding matrix:
  * Arithmetic & Logic: `ADD`, `SUB`, `AND`, `OR`, `SLT`
  * Immediate Math: `ADDI`, `SUBI`, `SLTI`
* **Dedicated Multiplier Array:** Features an explicit hardware-level multiplication circuit layout (`MUL`) running alongside the default ALU datapath to handle intensive product calculations cleanly in a single cycle.
* **Branch Offset Calculation:** Computes speculative target locations for conditional jump checks (`BEQZ`, `BNEQZ`) by shifting the sign-extended immediate value to a word offset and adding it to the tracked program sequence pointer:
  $$\text{Target\_Addr} = \text{ID\_EX\_NPC} + (\text{ID\_EX\_Imm} \ll 2)$$
* **Condition Evaluation:** Runs an internal comparator against operand register A to determine if a zero-state balance is met, asserting the `EX_MEM_cond` line forward.
