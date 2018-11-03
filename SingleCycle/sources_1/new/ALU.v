`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/02 17:32:36
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

`include "ALUControl.v"

module ALU(
    input wire[3:0] alu_ctrl,
    input wire[31:0] arg1, arg2, 
    output reg[31:0] result,
    output reg zero
    );
    
    initial begin
        result <= 0;
        zero <= 0;
    end
    
    always @(*) begin
        zero <= result ? 0 : 1;
    end
    
    always @(*) begin
        case (alu_ctrl) 
        `ALU_ADDU:   result <= arg1 + arg2;
        `ALU_SUBU:   result <= arg1 - arg2;
        `ALU_AND:   result <= arg1 & arg2;
        `ALU_OR:    result <= arg1 | arg2;
        `ALU_SLT:   result <= arg1 < arg2;
        default:    $display("%m: invalid alu_ctrl %b", alu_ctrl);
        endcase    
    end
    
endmodule
