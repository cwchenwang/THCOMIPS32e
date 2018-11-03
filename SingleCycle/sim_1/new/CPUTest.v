`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/02 20:31:24
// Design Name: 
// Module Name: CPUTest
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


module CPUTest();
    reg clk = 0, rst = 0;
    CPU cpu(.clk(clk), .rst(rst));
    
    integer counter = 0;
    initial begin
        // 6 + 8 * 8 - 2 = 68 cycles
        for (counter = 0; counter != 68 * 2; counter = counter + 1) 
            #10 clk = !clk;
        $finish;
    end
endmodule
