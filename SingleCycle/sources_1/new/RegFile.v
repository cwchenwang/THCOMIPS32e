`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/02 14:57:11
// Design Name: 
// Module Name: RegFile
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

module RegFile(
    input wire clk,
    input wire[4:0] rd1_i, rd2_i, wr_i,
    input wire we_i,  // 1 for enable
    input wire[31:0] data_i,
    output wire[31:0] data1_o, data2_o
    );
  
    reg[31:0] regs[0:31];
    
    assign data1_o = rd1_i ? regs[rd1_i] : 0;
    assign data2_o = rd2_i ? regs[rd2_i] : 0;
  
    always @(posedge clk) begin
        if (we_i) 
            regs[wr_i] <= data_i;
    end
endmodule
