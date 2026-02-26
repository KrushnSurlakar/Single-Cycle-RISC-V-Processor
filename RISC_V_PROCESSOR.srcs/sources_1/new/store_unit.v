`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.02.2026 04:57:17
// Design Name: 
// Module Name: store_unit
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


module store_unit (
    input wire [31:0] alu_result,
    input wire [31:0] rs2_data,
    input wire [1:0] store_type,
    input wire [31:0] mem_read_data,
    output reg [31:0] store_data
);

    wire [1:0] byte_offset = alu_result[1:0];

    always @(*) begin
        case (store_type)
        
            2'b00: begin
                store_data = rs2_data; //SW
            end
            
            // ---------- SB ----------
            2'b01: begin
                store_data = mem_read_data;
                case (byte_offset)
                    2'b00: store_data[7:0] = rs2_data[7:0];
                    2'b01: store_data[15:8] = rs2_data[7:0];
                    2'b10: store_data[23:16] = rs2_data[7:0];
                    2'b11: store_data[31:24] = rs2_data[7:0];
                endcase
            end

            // ---------- SH ----------
            2'b10: begin
                store_data = mem_read_data;
                if (byte_offset[1] == 1'b0)
                    store_data[15:0] = rs2_data[15:0];
                else
                    store_data[31:16] = rs2_data[15:0];
            end


            default: store_data = rs2_data;
        endcase
    end
endmodule



