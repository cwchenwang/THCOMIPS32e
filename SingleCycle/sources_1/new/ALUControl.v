`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/02 17:18:03
// Design Name: 
// Module Name: ALUControl
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

// 4-bit ALU control signals
`define ALU_ADDU 4'b0010
`define ALU_SUBU 4'b0110
`define ALU_AND 4'b0000
`define ALU_OR 4'b0001
`define ALU_SLT 4'b0111

module ALUControl(
    input wire[1:0] alu_op,
    input wire[5:0] funct,
    output reg[3:0] alu_ctrl
    );
    
    initial begin
        alu_ctrl <= `ALU_ADDU;
    end
    
    always @(*) begin
        case (alu_op)
        2'b00:
            alu_ctrl <= `ALU_ADDU;
        2'b01: 
            alu_ctrl <= `ALU_SUBU;
        2'b10: 
            case (funct)
            6'b100000:  alu_ctrl <= `ALU_ADDU;  // add
            6'b100001:  alu_ctrl <= `ALU_ADDU;  // addu
            6'b100010:  alu_ctrl <= `ALU_SUBU;  // sub
            6'b100011:  alu_ctrl <= `ALU_SUBU;  // subu
            6'b100100:  alu_ctrl <= `ALU_AND;   // and
            6'b100101:  alu_ctrl <= `ALU_OR;    // or
            6'b101010:  alu_ctrl <= `ALU_SLT;   // slt
            default:    error;
            endcase
        2'b11:
            alu_ctrl <= `ALU_OR;
        default: 
            error;
        endcase
    end
    
    task automatic error;
    begin
        $display("$m: invalid input: alu_op = %b, funct = %b", alu_op, funct);
    end
    endtask
    
endmodule
