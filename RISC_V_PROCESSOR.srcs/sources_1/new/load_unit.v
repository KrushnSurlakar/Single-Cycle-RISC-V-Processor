`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.02.2026 04:40:06
// Design Name: 
// Module Name: load_unit
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


module load_unit (
    input  wire [31:0] mem_data,
    input  wire [31:0] alu_result,
    input  wire [2:0]  load_type,
    output reg  [31:0] load_data
);

    wire [1:0] byte_offset = alu_result[1:0]; //To check which part to load

    wire [7:0] load_byte =
    (byte_offset == 2'b00) ? mem_data[7:0]:
    (byte_offset == 2'b01) ? mem_data[15:8]:
    (byte_offset == 2'b10) ? mem_data[23:16]:
                                 mem_data[31:24];


    wire [15:0] load_half =
        (byte_offset[1] == 1'b0) ? mem_data[15:0] :
                                   mem_data[31:16];

    always @(*) begin
        case (load_type)
            3'b000: load_data = mem_data;                          // lw
            3'b001: load_data = {{24{load_byte[7]}}, load_byte};   // lb
            3'b010: load_data = {{16{load_half[15]}}, load_half};  // lh
            3'b011: load_data = {24'b0, load_byte};                // lbu
            3'b100: load_data = {16'b0, load_half};                // lhu
            default: load_data = mem_data;
        endcase
    end
endmodule

