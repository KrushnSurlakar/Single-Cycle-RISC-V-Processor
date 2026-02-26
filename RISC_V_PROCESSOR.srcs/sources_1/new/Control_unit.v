`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2026 18:41:47
// Design Name: 
// Module Name: Control_unit
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


module Control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input wire [6:0] funct7,
    input wire [31:0]rs1_data,
    input wire [31:0]rs2_data,
    output reg  reg_write,
    output reg  mem_read,
    output reg  mem_write,
    output reg  alu_src,
    output reg [1:0]alu_src_a, //00: RS1 , 01 : RS1=00, 10: RS1=PC
    output reg  [1:0]imm_sel,      // 0 = I-type, 1 = S-type
    output reg [3:0]alu_ctrl,
    output reg branch_taken,
    output reg jump,
    output reg jalr,
    output reg [2:0] load_type,
    output reg [1:0] store_type
);

    always @(*) begin
        // defaults
        reg_write = 0;
        mem_read  = 0;
        mem_write = 0;
        alu_src   = 0;
        alu_src_a = 2'b00;
        imm_sel   = 2'b0;
        alu_ctrl =4'b0;
        branch_taken = 0;
        jump = 0;
        jalr = 0;
        load_type=3'b000;
        store_type=2'b00;
        
        case (opcode)

            // -------- Load--------
            7'b0000011: begin
                            reg_write = 1;
                            mem_read  = 1;
                            alu_src   = 1;
                            imm_sel   = 2'b00; // 
                            alu_ctrl =4'b0;
                                 case(funct3)
                                    3'b000: load_type = 3'b001; // lb
                                    3'b001: load_type = 3'b010; // lh
                                    3'b010: load_type = 3'b000; // lw
                                    3'b100: load_type = 3'b011; // lbu
                                    3'b101: load_type = 3'b100; // lhu
                                    default: load_type = 3'b000; // for load word normal
                                endcase 
            end

            // -------- Store --------
            7'b0100011: begin
                            reg_write =0;
                            mem_write = 1;
                            alu_src   = 1;
                            imm_sel   = 2'b01; // S-type
                            alu_ctrl =4'b0;
                            case(funct3)
                                3'b000: store_type = 2'b01; //sb
                                3'b001: store_type = 2'b10;  //sh
                                3'b010: store_type = 2'b00;  //sw
                               default: store_type = 2'b00;
                            endcase
            end
            //R type as follows
            7'b0110011: begin
                            begin alu_src = 0; reg_write =1; imm_sel = 2'bxx; end
                                case (funct3) 
                                    3'b000: if(funct7[5]==0) alu_ctrl =4'b0000; //add
                                              else alu_ctrl = 4'b0001; //sub
                                    3'b001: alu_ctrl = 4'b0101; // SLL
                                    3'b010: alu_ctrl = 4'b1000; //SLT
                                    3'b011: alu_ctrl = 4'b1001; // SLTU
                                    3'b100: alu_ctrl = 4'b0100; // XOR
                                    3'b101: if(funct7[5]==0) alu_ctrl =4'b0110; //SRL
                                              else alu_ctrl = 4'b0111; //SRA
                                    3'b110: alu_ctrl = 4'b0011; // OR
                                    3'b111: alu_ctrl = 4'b0010; // AND
                                    
                                 default: alu_ctrl = 4'b0000;
                               endcase
                        end
                 
                 //B type as follows       
               7'b1100011: begin
                            begin alu_src  = 0; imm_sel  = 2'b10; reg_write=0;  end
                                case (funct3) 
                                    3'b000: branch_taken = (rs1_data == rs2_data); // beq
                                    3'b001: branch_taken = (rs1_data != rs2_data); // bne
                                    3'b100: branch_taken = ($signed(rs1_data) <  $signed(rs2_data)); // blt
                                    3'b101: branch_taken = ($signed(rs1_data) >= $signed(rs2_data)); // bge
                                    3'b110: branch_taken = (rs1_data <  rs2_data); // bltu
                                    3'b111: branch_taken = (rs1_data >= rs2_data); // bgeu
                                    
                                 default: branch_taken=0;
                               endcase
                        end
               
               // ---------- I-TYPE ALU ----------
                7'b0010011: begin
                    reg_write = 1;
                    alu_src   = 1;
                    imm_sel   = 2'b00;   // I-type immediate
                
                    case (funct3)
                        3'b000: alu_ctrl = 4'b0000; // addi
                        3'b001: begin               // slli
                            if (funct7 == 7'b0000000)
                                alu_ctrl = 4'b0101;
                        end
                        3'b010: alu_ctrl = 4'b1000; // slti
                        3'b011: alu_ctrl = 4'b1001; // sltiu
                        3'b100: alu_ctrl = 4'b0100; // xori
                        3'b101: begin
                            if (funct7 == 7'b0000000)
                                alu_ctrl = 4'b0110; // srli
                            else if (funct7 == 7'b0100000)
                                alu_ctrl = 4'b0111; // srai
                        end
                        3'b110: alu_ctrl = 4'b0011; // ori
                        3'b111: alu_ctrl = 4'b0010; // andi

                    endcase
                end
                
                7'b1101111: begin  //JAL
                                jump = 1;
                                imm_sel = 2'b11;
                                reg_write = 1;
                            end
                
                7'b1100111: begin  //JALR
                                if(funct3==3'b000) 
                                begin
                                    jalr = 1;
                                    alu_src =1;
                                    alu_ctrl = 4'b0;
                                    imm_sel = 2'b11;
                                    reg_write = 1;
                                   
                                end
                            end
                            
               7'b0110111: begin //aui
                               reg_write =1;
                               alu_src_a = 2'b01;
                               alu_ctrl = 4'b0;
                           end
                           
              7'b0110111: begin //auipc
                               reg_write =1;
                               alu_src_a = 2'b10;
                               alu_ctrl = 4'b0;
                           end

            default: begin
                // do nothing
            end
        endcase
    end

endmodule

