`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/02 16:07:47
// Design Name: 
// Module Name: PCTest
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


module PCTest();
    reg clk, rst;
    reg branch = 0, jump = 0, zero = 1;
    reg[25:0] jump_addr = 0;
    reg[31:0] offset = 0;
    wire[31:0] pc_value;
    
    PC pc(
        clk, 
        rst,  // Synchronized reset
        branch,
        zero,
        jump,
        jump_addr,
        offset,   // Extended branch offset
        pc_value
        );
       
    integer t = 0;        
    initial begin
        clk = 0;
        rst = 0;
        $display("%d", pc_value);
        for (t = 0; t != 4; t = t + 1) begin
            #10 clk = 1;
            #10 $display("%d", pc_value);
            clk = 0;
       end
       
       // Jump to 0x8
       jump_addr = 'b10;    // Jump to 0b1000 = 8
       jump = 1;
       #10 clk = 1;
       #10 $display("%d", pc_value);
       clk = 0;
       
       // Branch to 0
       jump = 0;
       branch = 1;
       offset = -3; // Branch to 8 + 4 - 3 * 4 = 0
       #10 clk = 1;
       #10 $display("%d", pc_value);
       clk = 0;
       
       // No branch when zero = 0, PC = 0x4
       offset = -3; // Branch to 8 + 4 - 3 * 4 = 0
       zero = 0;
       #10 clk = 1;
       #10 $display("%d", pc_value);
       clk = 0;
       $finish;
    end
    
endmodule
