`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/02 15:12:32
// Design Name: 
// Module Name: RAMTest
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

`include "../../sources_1/new/RAM.v"

module RAMTest();
    reg clk;
    reg mode;
    reg[31:0] addr;
    reg[31:0] wr_data;
    wire[31:0] rd_data;

    RAM ram(.clk(clk), .mode_i(mode), .addr_i(addr), .data_i(wr_data), .data_o(rd_data));
    
    integer counter = 0;
    initial begin
        mode = `RAM_WRITE_MODE;
        addr = 0;
        clk = 0;
        for (counter = 0; counter != 4; counter = counter + 1) begin
            wr_data = counter;
            #10 clk = 1;
            #10 clk = 0;
            addr = addr + 4;
        end
        
        mode = `RAM_READ_MODE;
        addr = 0;
        for (counter = 0; counter != 4; counter = counter + 1) begin
            #10 clk = 1;
            $display("%d", rd_data);  
            #10 clk = 0;
            addr = addr + 4;
        end
        
        $finish;
    end

endmodule
