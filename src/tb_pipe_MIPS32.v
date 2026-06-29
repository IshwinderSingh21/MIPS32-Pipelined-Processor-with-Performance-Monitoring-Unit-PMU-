`timescale 1ns/1ps

module tb_pipe_MIPS32;

    reg clk1;
    reg clk2;
    reg rst;

    pipe_MIPS32 uut (
        .clk1(clk1),
        .clk2(clk2),
        .rst(rst)
    );

    always begin
        clk1 = 1'b1; clk2 = 1'b0; #5;
        clk1 = 1'b0; clk2 = 1'b0; #5;
        clk1 = 1'b0; clk2 = 1'b1; #5;
        clk1 = 1'b0; clk2 = 1'b0; #5;
    end

    real cpi;

    initial begin
        $dumpfile("mips_pipeline.vcd");
        $dumpvars(0, tb_pipe_MIPS32);

        rst = 1'b1;
        #20;
        rst = 1'b0;

        uut.Mem[0] = {6'b100010, 5'b00000, 5'b00001, 16'd24};   
        uut.Mem[1] = {6'b100010, 5'b00000, 5'b00010, 16'd4};    
        uut.Mem[2] = {6'b000110, 26'b0};                        
        uut.Mem[3] = {6'b000110, 26'b0};                        
        uut.Mem[4] = {6'b000000, 5'b00001, 5'b00010, 5'b00011, 11'b0}; 
        uut.Mem[5] = {6'b000001, 5'b00001, 5'b00010, 5'b00100, 11'b0}; 
        uut.Mem[6] = {6'b000110, 26'b0};                        
        uut.Mem[7] = {6'b000110, 26'b0};                        
        uut.Mem[8] = {6'b000101, 5'b00010, 5'b00100, 5'b01000, 11'b0}; 
        uut.Mem[9] = {6'b000110, 26'b0};                        
        uut.Mem[10]= {6'b000110, 26'b0};                        
        uut.Mem[11]= {6'b100001, 5'b00000, 5'b01000, 16'd40};   
        uut.Mem[12]= {6'b000110, 26'b0};                        
        uut.Mem[13]= {6'b000110, 26'b0};                        
        uut.Mem[14]= {6'b100000, 5'b00000, 5'b01011, 16'd40};   
        uut.Mem[15]= {6'b000110, 26'b0};                        
        uut.Mem[16]= {6'b000110, 26'b0};                        
        uut.Mem[17]= {6'b100011, 5'b01011, 5'b01100, 16'd80};   
        uut.Mem[18]= {6'b000110, 26'b0};                        
        uut.Mem[19]= {6'b000110, 26'b0};                        
        uut.Mem[20]= {6'b101110, 5'b01100, 26'd1};              
        uut.Mem[21]= {6'b000110, 26'b0};                        
        uut.Mem[22]= {6'b111111, 26'b0};                        

        uut.PC           = 32'd0;
        uut.HALTED       = 1'b0;

        wait(uut.HALTED == 1'b1);
        #40;

        cpi = $itor(uut.cycle_count) / $itor(uut.instruction_count);

        $display("\n=======================================================");
        $display("   MIPS32 CORE SIMULATION AND PERFORMANCE AUDIT REPORT ");
        $display("=======================================================");
        $display(" Execution Time:   %0dns", $time);
        $display(" Final Status:     PROCESSOR HALTED (SUCCESS)");
        $display("-------------------------------------------------------");
        $display(" [PMU METRICS]");
        $display("   Total Clock Cycles Elapsed : %0d", uut.cycle_count);
        $display("   Valid Instructions Retired : %0d", uut.instruction_count);
        $display("   Software-Injected Bubbles  : %0d", uut.nop_count);
        $display("   Branches Executed          : %0d", uut.branch_count);
        $display("   Calculated Core CPI        : %2.2f", cpi);
        $display("-------------------------------------------------------");
        $display(" [ARCHITECTURAL REGISTER STATE]");
        $display("   R1  = %d  |  R2  = %d  |  R3  = %d", uut.Reg[1], uut.Reg[2], uut.Reg[3]);
        $display("   R4  = %d  |  R8  = %d  |  R11 = %d", uut.Reg[4], uut.Reg[8], uut.Reg[11]);
        $display("   R12 = %d", uut.Reg[12]);
        $display("-------------------------------------------------------");
        $display(" [RAM BOUNDARY CELL MATRIX]");
        $display("   Mem[10] (Byte Addr 40) = %d", uut.Mem[10]);
        $display("=======================================================\n");

        $finish;
    end

endmodule
