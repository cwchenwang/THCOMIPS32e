// Testbench for module PC
// Author: LYL

`timescale 1ns / 1ps
`include "../../sources_1/new/defines.vh"

module PCTest();
    reg clk = 0, rst = 0;
    
    reg flush = 0;
    reg[5:0] stall = 0;
    
    reg branch_flag = 0;
    reg[`InstAddrBus] branch_addr = 0;
    
    reg[1:0] pc_rom_op = `PC_ROM_OP_INST;
    reg[`DataBus] rom_wr_data = 0;
    reg[`InstAddrBus] rom_rw_addr = 0;
    
    wire[`InstAddrBus] pc_value;
    wire ce;
    wire rom_op;
    wire[`DataBus] wr_data;
    
    PC pc(
       .clk(clk),
       .rst(rst),
       .flush(flush),
       .stall(stall),
       .branch_flag_i(branch_flag),
       .branch_target_address_i(branch_addr),
       .rom_op_i(pc_rom_op),
       .rom_wr_data_i(rom_wr_data),
       .rom_rw_addr_i(rom_rw_addr),
       .pc_or_addr(pc_value),
       .ce(ce),
       .rom_op_o(rom_op),
       .wr_data_o(wr_data)
    );
       
    initial begin
       rst = 1;
       #20 rst = 0;
       #80 rst = 1;
       #20 rst = 0;  
       #40 branch_flag = 1;
       #20 branch_flag = 0;
       #20 stall = 1;
       #20 stall = 0;
       #80;
       $finish;
    end
    
    always begin
        #10 clk = !clk;
    end
    
endmodule
