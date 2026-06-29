# Stage 1: Instruction Fetch (IF)

## 🎯 Objective
The entry boundary of the synchronous pipeline. Its sole responsibility is to orchestrate the retrieval of raw 32-bit machine word instructions from the instruction memory array based on the current state of the execution tracking registers.

## ⚙️ Hardware Operation
* **Memory Indexing:** The stage uses the value held inside the Program Counter (`PC`) register as a word pointer to address the instruction RAM block (`Mem[PC >> 2]`).
* **Sequence Increment:** While fetching, the hardware evaluates an adder circuit to pre-compute the next logical sequential address: 
  $$\text{Next\_PC} = \text{PC} + 4$$
* **Control Flow Hijack:** If a branch instruction in the pipeline evaluates to a "taken" status, the default increment path is overridden. The stage updates the `PC` to the calculated branch destination target address computed upstream, altering the instruction stream execution on the subsequent clock edge.
* **Pipeline Latch:** The retrieved 32-bit instruction and its corresponding Next PC calculation are latched directly into the `IF_ID` register boundary.
