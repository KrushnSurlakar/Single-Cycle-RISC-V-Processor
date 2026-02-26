`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2026 18:41:47
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top (
    input wire clk,
    input wire reset
);

   wire [31:0] pc_current;
    wire [31:0]  pc_next, pc_plus4;
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] imm;
    wire branch_taken;
    wire jump;
    wire jalr;
    wire imm_u;

    PC pc (
        clk,
        reset,
        pc_next,
        pc_current
    );

    assign pc_plus4 = pc_current + 32'b0100;
    assign pc_next = jalr ? (rs1_data + imm): 
                        ( branch_taken ? (pc_current + imm)  :
                         (jump ? (pc_current + imm) : pc_plus4) );

    // ---------------- Instruction Fetch ----------------
    wire [31:0] instr;

    Instr_mem IMEM (
        pc_current,
        instr
    );

    // ---------------- Decode ----------------
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [4:0] rd = instr[11:7];
    wire [6:0] funct7 = instr[31:25];
    


    // ---------------- Control ----------------
    wire reg_write, mem_read, mem_write;
    wire alu_src;
     wire [1:0]imm_sel;
     wire [3:0]alu_ctrl;
    wire [2:0] load_type;
    wire [1:0] store_type;
    wire [1:0] alu_src_a;

    Control_unit CU (
        opcode,
        funct3,
        funct7,
        rs1_data,
        rs2_data,
        reg_write,
        mem_read,
        mem_write,
        alu_src,
        alu_src_a,
        imm_sel,
        alu_ctrl,
        branch_taken,
        jump,
        jalr,
        load_type,
        store_type
    );

    // ---------------- Immediate ---------------

    Imm_gen IMM (
        instr,
        imm_sel,
        imm
    );

    // ---------------- Register File ----------------
    
     wire [31:0] mem_data;
     wire [31:0] write_data;
     wire [31:0] alu_result;
     wire [31:0] store_data; //for stype
     
    Register_file RF (
        clk,
        reset,
        reg_write,
        rs1,
        rs2,
        rd,
        write_data,
        rs1_data,
        rs2_data
    );

    // ---------------- ALU ----------------
    wire [31:0] alu_b, alu_a;
   assign imm_u = {instr[31:12],12'b0};
   
   assign alu_a = (alu_src_a == 2'b01) ? 31'b0 : ( (alu_src_a == 2'b10) ? pc_current : rs1_data );
    assign alu_b = (alu_src_a[0] || alu_src_a[1]) ? imm_u : (alu_src ? imm : rs2_data);

    ALU alu(
        rs1_data,
        alu_b,
        alu_ctrl,
        alu_result
    );


    // ---------------- Data Memory ----------------
   
    
    


    wire [31:0] load_data;
    
    load_unit LU (
        mem_data,
        alu_result,
        load_type,
        load_data
    );
    
    assign write_data= (jump||jalr)? (pc_plus4) : (mem_read ? load_data : alu_result) ;
    
    store_unit SU (
        alu_result,
        rs2_data,
        store_type,
        mem_data,
        store_data
    );
    
    Data_mem DMEM (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(alu_result),
        .write_data(store_data),
        .read_data(mem_data)
    );
endmodule

