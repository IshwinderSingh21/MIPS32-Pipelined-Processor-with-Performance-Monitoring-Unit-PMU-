# Stage 4: Memory Access (MEM)

## 🎯 Objective
Interfaces directly with the physical data RAM block. It acts as the gatekeeper for reading and writing data permanently outside the local register configurations.

## ⚙️ Hardware Operation
* **Address Mapping:** Uses the final calculation output passed down from the Execute stage's ALU as a synchronized target address pointer.
* **Store Word Execution (`SW`):** When a store instruction clears the stage, the memory interface activates a write-enable state to map the 32-bit data value extracted from register B directly into the target cell location:
  $$\text{Mem}[\text{EX\_MEM\_ALUOut} \gg 2] \leftarrow \text{EX\_MEM\_B}$$
* **Load Word Execution (`LW`):** When a load instruction clears the stage, a read interface triggers to copy data out of the specific indexed RAM cell into the intermediate Load Memory Data (`MEM_WB_LMD`) register pipeline segment.
* **Passthrough Bridge:** For standard register-to-register arithmetic configurations, this block deasserts all memory interface lines and transparently routes the ALU output straight to the next stage register.
