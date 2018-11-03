`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/02 16:55:38
// Design Name: 
// Module Name: Control
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

module Control(
    input wire[5:0] op,
    output reg reg_dst,
    output reg jump,
    output reg branch,
    output reg mem_read,
    output reg mem_to_reg,
    output reg[1:0] alu_op,
    output reg mem_write,
    output reg alu_src,
    output reg reg_write
    );
    
    localparam ANY = 1'b0;
    localparam ANY_ALU_OP = 2'b00;
    
    initial begin
        reg_dst <= 0;
        jump <= 0;
        branch <= 0;
        mem_read <= 0;
        mem_to_reg <= 0;
        alu_op <= 2'b00;
        mem_write <= 0;
        alu_src <= 0;
        reg_write <= 0;
    end
    
    always @(*) begin
        case (op)
        6'b0: begin
            // R type
            reg_dst <= 1;
            jump <= 0;
            alu_src <= 0;
            mem_to_reg <= 0;
            reg_write <= 1;
            mem_read <= 0;
            mem_write <= 0;
            branch <= 0;
            alu_op <= 2'b10; 
        end
        6'b001101: begin
            // ori
            // Hopefully this is correct
            reg_dst <= 0;
            jump <= 0;
            alu_src <= 1;
            mem_to_reg <= 0;
            reg_write <= 1;
            mem_read <= 0;
            mem_write <= 0;
            branch <= 0;
            alu_op <= 2'b11; // or
        end
        6'b100011: begin
            // lw
            reg_dst <= 0;
            jump <= 0;
            alu_src <= 1;
            mem_to_reg <= 1;
            reg_write <= 1;
            mem_read <= 1;
            mem_write <= 0;
            branch <= 0;
            alu_op <= 2'b00; 
        end
        6'b101011: begin
            // sw
            reg_dst <= ANY;
            jump <= 0;
            alu_src <= 1;
            mem_to_reg <= ANY;
            reg_write <= 0;
            mem_read <= 0;
            mem_write <= 1;
            branch <= 0;
            alu_op <= 2'b00; 
        end
        6'b000100: begin
            // beq
            reg_dst <= ANY;
            jump <= 0;
            alu_src <= 0;
            mem_to_reg <= ANY;
            reg_write <= 0;
            mem_read <= 0;
            mem_write <= 0;
            branch <= 1;
            alu_op <= 2'b01; 
        end
         6'b000010: begin
            // jump
            // Hopefully this is correct.
            reg_dst <= ANY;
            jump <= 1;
            alu_src <= ANY;
            mem_to_reg <= ANY;
            reg_write <= 0;
            mem_read <= 0;
            mem_write <= 0;
            branch <= 0;
            alu_op <= ANY_ALU_OP;
        end
        default: begin
            $display("$m: invalid op %b", op);
        end
        endcase
    end
    
endmodule
