# Stage 5: Write Back (WB)

## 🎯 Objective
The retirement zone of the instruction lifecycle. It permanently updates the local Register File with fresh computational data to complete an operation thread.

## ⚙️ Hardware Operation
* **Destination Multiplexing:** Evaluates the original instruction type to figure out exactly which register index is targeted for modifications:
  * Register-Register Opcode: Destination is indexed via bits `[15:11]` (RD)
  * Register-Immediate/Load Opcode: Destination is indexed via bits `[20:16]` (RT)
* **Data Selection:** Routes the correct input stream into the Register File write channel. It switches between the calculated `ALUOut` string for mathematical actions, and the newly loaded `LMD` string for memory actions.
* **State Commit:** Drives a synchronized write strobe to permanently save the raw 32-bit data back into the target register slot on the clock boundary.
* **System Termination:** Monitors for the master Halt (`HLT`) instruction parameter. Once detected at this final phase, it latches the `HALTED` state high, which gracefully anchors the clock tree to prevent further cycle ticking.
