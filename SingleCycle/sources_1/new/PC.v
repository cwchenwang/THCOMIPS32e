`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/02 15:10:41
// Design Name: 
// Module Name: PC
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

module PC(
    input wire clk, 
    input wire rst,  // Synchronized reset
    input wire branch_i,
    input wire zero,
    input wire jump_i,
    input wire[25:0] addr_i,     // Jump address
    input wire[31:0] offset_i,   // Unshifted sign-extended branch offset
    output reg[31:0] pc_o
    );
  
    wire[31:0] pc_plus_4 = pc_o + 4; 
    reg[31:0] next_pc = 0;
    
    initial begin
        pc_o <= 0;
    end
    
    always @(*) begin
        if (jump_i) begin
            next_pc <= {pc_plus_4[31:28], addr_i, 2'd0};   // 4 + 26 + 2 = 32
        end else if (branch_i && zero) begin
            next_pc <= pc_plus_4 + (offset_i << 2);
        end else begin
            next_pc <= pc_plus_4;
        end
    end
  
    always @(posedge clk) begin
        if (rst) begin    
            pc_o = 0;
        end else begin 
            pc_o <= next_pc;
        end
    end
endmodule
