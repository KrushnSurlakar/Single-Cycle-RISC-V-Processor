`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2026 18:41:47
// Design Name: 
// Module Name: ALU
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


module ALU (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input wire [3:0] alu_ctrl,
    output reg [31:0] result
);
    
    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a + b; //add
            4'b0001: result = a - b; //sub
            4'b0010: result = a & b; //and
            4'b0011: result = a | b; //or
            4'b0100: result = a ^ b; //xor
            4'b0101: result = a << b[4:0]; //sll
            4'b0110: result = a >> b[4:0]; //srl
            4'b0111: result = $signed(a) >>> b[4:0]; //sra
            4'b1000: result = ($signed(a) < $signed(b)); //slt
            4'b1001: result = (a < b); //sltu
            default: result = 32'b0;
        endcase
    end

endmodule

