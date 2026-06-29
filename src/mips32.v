module pipe_MIPS32 (clk1, clk2, rst);

    input clk1, clk2, rst;

    reg [31:0] PC;
    reg [31:0] IF_ID_IR, IF_ID_NPC;
    reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
    reg [2:0]  ID_EX_type, EX_MEM_type, MEM_WB_type;
    reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
    reg        EX_MEM_cond;
    reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;

    reg [31:0] Reg [0:31];
    reg [31:0] Mem [0:1023];

    reg HALTED;

    parameter ADD=6'b000000, SUB=6'b000001, AND=6'b000010, OR=6'b000011,
              SLT=6'b000100, MUL=6'b000101, HLT=6'b111111, LW=6'b100000,
              SW=6'b100001, ADDI=6'b100010, SUBI=6'b100011, SLTI=6'b100100,
              BNEQZ=6'b100101, BEQZ=6'b100110;

    parameter RR_ALU = 3'b000,
              RM_ALU = 3'b001,
              LOAD   = 3'b010,
              STORE  = 3'b011,
              BRANCH = 3'b100,
              HALT   = 3'b101,
              NOP    = 3'b110;

    integer i;

    /* ====================================================================
     * PERFORMANCE MONITORING UNIT (PMU) HARDWARE COUNTERS
     * ==================================================================== */
    reg [31:0] cycle_count;
    reg [31:0] instruction_count;
    reg [31:0] branch_count;
    reg [31:0] nop_count;

    always @(posedge clk1 or posedge rst) begin
        if (rst) begin
            cycle_count       <= 32'd0;
            instruction_count <= 32'd0;
            branch_count      <= 32'd0;
            nop_count         <= 32'd0;
        end else if (!HALTED) begin
            cycle_count <= cycle_count + 1;
            if (MEM_WB_type != NOP && MEM_WB_type != HALT) begin
                instruction_count <= instruction_count + 1;
            end
            if (ID_EX_type == BRANCH) begin
                branch_count <= branch_count + 1;
            end
            if (ID_EX_type == NOP) begin
                nop_count <= nop_count + 1;
            end
        end
    end

    /* ====================================================================
     * 1. INSTRUCTION FETCH (IF) STAGE
     * ==================================================================== */
    always @(posedge clk1) begin
        if (rst) begin
            PC        <= #2 32'd0;
            IF_ID_IR  <= #2 32'h00000000;
            IF_ID_NPC <= #2 32'd0;
        end else if (HALTED == 0) begin
            if (((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_cond == 1)) || 
                ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_cond == 0))) 
            begin
                IF_ID_IR  <= #2 Mem[EX_MEM_ALUOut >> 2]; 
                IF_ID_NPC <= #2 EX_MEM_ALUOut + 4;
                PC        <= #2 EX_MEM_ALUOut + 4;
            end 
            else begin
                IF_ID_IR  <= #2 Mem[PC >> 2];            
                IF_ID_NPC <= #2 PC + 4;
                PC        <= #2 PC + 4;
            end
        end
    end

    /* ====================================================================
     * 2. INSTRUCTION DECODE (ID) STAGE
     * ==================================================================== */
    always @(posedge clk2) begin
        if (rst) begin
            ID_EX_A    <= #2 32'd0;
            ID_EX_B    <= #2 32'd0;
            ID_EX_NPC  <= #2 32'd0;
            ID_EX_IR   <= #2 32'h00000000;
            ID_EX_Imm  <= #2 32'd0;
            ID_EX_type <= #2 NOP; 
            for (i = 0; i < 32; i = i + 1) begin
                Reg[i] <= #2 32'd0; 
            end
        end else if (HALTED == 0) begin
            if (IF_ID_IR[25:21] == 5'b00000) ID_EX_A <= 0;
            else                             ID_EX_A <= #2 Reg[IF_ID_IR[25:21]];

            if (IF_ID_IR[20:16] == 5'b00000) ID_EX_B <= 0;
            else                             ID_EX_B <= #2 Reg[IF_ID_IR[20:16]];

            ID_EX_NPC <= #2 IF_ID_NPC;
            ID_EX_IR  <= #2 IF_ID_IR;
            ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}}, {IF_ID_IR[15:0]}};

            case (IF_ID_IR[31:26])
                ADD, SUB, AND, OR, SLT, MUL: ID_EX_type <= #2 RR_ALU;
                ADDI, SUBI, SLTI:            ID_EX_type <= #2 RM_ALU;
                LW:                          ID_EX_type <= #2 LOAD;
                SW:                          ID_EX_type <= #2 STORE;
                BNEQZ, BEQZ:                 ID_EX_type <= #2 BRANCH;
                HLT:                         ID_EX_type <= #2 HALT;
                default:                     ID_EX_type <= #2 NOP;
            endcase
        end
    end

    /* ====================================================================
     * 3. EXECUTE (EX) STAGE
     * ==================================================================== */
    always @(posedge clk1) begin
        if (rst) begin
            EX_MEM_type   <= #2 NOP; 
            EX_MEM_IR     <= #2 32'h00000000;
            EX_MEM_ALUOut <= #2 32'd0;
            EX_MEM_B      <= #2 32'd0;
            EX_MEM_cond   <= #2 1'b0;
        end else if (HALTED == 0) begin
            EX_MEM_type  <= #2 ID_EX_type;
            EX_MEM_IR    <= #2 ID_EX_IR;

            case (ID_EX_type)
                RR_ALU: begin
                    case (ID_EX_IR[31:26])
                        ADD:     EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_B;
                        SUB:     EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_B;
                        AND:     EX_MEM_ALUOut <= #2 ID_EX_A & ID_EX_B;
                        OR:      EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_B;
                        SLT:     EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_B;
                        MUL:     EX_MEM_ALUOut <= #2 ID_EX_A * ID_EX_B;
                        default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
                    endcase
                end

                RM_ALU: begin
                    case (ID_EX_IR[31:26])
                        ADDI:    EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
                        SUBI:    EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_Imm;
                        SLTI:    EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_Imm;
                        default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
                    endcase
                end

                LOAD, STORE: begin
                    EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
                    EX_MEM_B      <= #2 ID_EX_B;
                end

                BRANCH: begin
                    EX_MEM_ALUOut <= #2 ID_EX_NPC + (ID_EX_Imm << 2); 
                    EX_MEM_cond   <= #2 (ID_EX_A == 0);
                end
                default: begin end
            endcase
        end
    end

    /* ====================================================================
     * 4. MEMORY ACCESS (MEM) STAGE
     * ==================================================================== */
    always @(posedge clk2) begin
        if (rst) begin
            MEM_WB_type   <= #2 NOP; 
            MEM_WB_IR     <= #2 32'h00000000;
            MEM_WB_ALUOut <= #2 32'd0;
            MEM_WB_LMD    <= #2 32'd0;
        end else if (HALTED == 0) begin
            MEM_WB_type <= EX_MEM_type;
            MEM_WB_IR   <= #2 EX_MEM_IR;

            case (EX_MEM_type)
                RR_ALU, RM_ALU: begin
                    MEM_WB_ALUOut <= #2 EX_MEM_ALUOut;
                end

                LOAD: begin
                    MEM_WB_LMD    <= #2 Mem[EX_MEM_ALUOut >> 2]; 
                end

                STORE: begin
                    Mem[EX_MEM_ALUOut >> 2] <= #2 EX_MEM_B; 
                end
                default: begin end
            endcase
        end
    end

    /* ====================================================================
     * 5. WRITE BACK (WB) STAGE
     * ==================================================================== */
    always @(posedge clk1) begin
        if (rst) begin
            HALTED <= #2 1'b0;
        end else begin
            case (MEM_WB_type)
                RR_ALU:  Reg[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUOut;
                RM_ALU:  Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOut;
                LOAD:    Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD;
                HALT:    HALTED                <= #2 1'b1;
                NOP:     begin end
                default: begin end
            endcase
        end
    end

endmodule
