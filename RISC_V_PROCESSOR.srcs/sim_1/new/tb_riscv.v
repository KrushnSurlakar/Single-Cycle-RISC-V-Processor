`timescale 1ns/1ps

module tb_riscv;

    // -----------------------
    // Clock & Reset
    // -----------------------
    reg clk;
    reg reset;

    // -----------------------
    // DUT
    // -----------------------
    top dut (
        .clk   (clk),
        .reset (reset)
    );

    // -----------------------
    // Clock: 10 ns period
    // -----------------------
    always begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end

    // -----------------------
    // Reset sequence
    // -----------------------
    initial begin
        reset = 1'b1;
        #20;              // hold reset for 2 cycles
        reset = 1'b0;
    end

    // -----------------------
    // Simulation control
    // -----------------------
    
    
    initial begin
        // Let program run completely
        #300

         $display("=================================");
        $display("FINAL CPU STATE");
        $display("PC  = %h", dut.pc_current);
        $display("PC_next  = %h", dut.pc_next);
        $display("x2  = %h", dut.RF.regs[2]);
        $display("x3  = %h", dut.RF.regs[3]);
        $display("x4  = %h", dut.RF.regs[4]);
        $display("x5  = %h", dut.RF.regs[5]);
        $display("x7  = %h", dut.RF.regs[7]);
        $display("x9  = %h", dut.RF.regs[9]);
        $display("mem[96]  = %h", dut.DMEM.memory[96>>2]);
        $display("mem[x3+32]  = %h", dut.DMEM.memory[(dut.RF.regs[3] + 32)>>2]);
        //$display("reg write  = %h", dut.reg_write);
        $display("=================================");
        
        $stop;
    end

endmodule
