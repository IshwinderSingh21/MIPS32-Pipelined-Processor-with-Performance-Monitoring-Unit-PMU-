# Stage 2: Instruction Decode (ID)

## 🎯 Objective
Acts as the translation unit of the core. It parses the incoming raw 32-bit machine word to determine execution control routes and coordinates register file access.

## ⚙️ Hardware Operation
* **Bitfield Slicing:** Extracts the distinct architectural components from the instruction word:
  * `[31:26]` - Opcode Identifier
  * `[25:21]` - Source Register RS
  * `[20:16]` - Source/Destination Register RT
  * `[15:11]` - Destination Register RD
  * `[15:0]`  - 16-bit Immediate Constant
* **Register File Read Access:** Connects the sliced RS and RT bitfields directly to the read ports of the central Register File (`Reg`). It fetches the 32-bit operand values simultaneously.
* **Sign Extension:** Expands 16-bit immediate values to a full 32-bit data width by duplicating the MSB (sign bit) across the upper 16 bits:
  $$\text{SignExtImm} = \{\{16\{\text{IR}[15]\}\}, \text{IR}[15:0]\}$$
* **Type Assignment:** Utilizes a combinational decoder block to map the opcode field to a simplified 3'b core identifier (`RR_ALU`, `RM_ALU`, `LOAD`, etc.), packing everything into the `ID_EX` stage registers.
