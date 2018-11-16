`timescale 1ns / 1ps
`include "defines.vh"

module MEM(
    input wire rst,

    // From EX/MEM
    input wire ld_src_i,
    
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire[`RegBus] wdata_i,
    
    input wire[`DataBus] cp0_data_i,
    input wire[`RegAddrBus] cp0_wr_addr_i,
    input wire cp0_we_i,
    
    input wire[`AluOpBus] aluop_i,
    input wire[`RegBus] mem_addr_i,
    input wire[`RegBus] reg2_i,

    // From RAM
    input wire[`RegBus] mem_data_i,

    // To MEM/WB
    output reg ld_src_o,
    
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,

    output reg[`DataBus] cp0_data_o,
    output reg[`RegAddrBus] cp0_wr_addr_o,
    output reg cp0_we_o,

    // To RAM
    output reg[`RegBus] mem_addr_o,
    output wire mem_we_o,
    output reg[3:0] mem_sel_o,
    output reg[`RegBus] mem_data_o,
    output reg mem_ce_o
);

endmodule
