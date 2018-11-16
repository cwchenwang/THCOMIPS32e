`timescale 1ns / 1ps
`include "defines.vh"

module EX_MEM(
    input wire clk,
    input wire rst,

    // flush and stall
    input wire flush,
    input wire stall,

    // From EX
    input wire ld_src_i,
    
    input wire[`RegAddrBus] ex_wd,
    input wire ex_wreg,
    input wire[`RegBus] ex_wdata,
    
    input wire[`DataBus] ex_cp0_data,
    input wire[`RegAddrBus] ex_cp0_wr_addr,
    input wire ex_cp0_we,
    
    input wire[`AluOpBus] ex_aluop,
    input wire[`RegBus] ex_mem_addr,
    input wire[`RegBus] ex_reg2,

    // To MEM
    output reg ld_src_o,
    
    output reg[`RegAddrBus] mem_wd,
    output reg mem_wreg,
    output reg[`RegBus] mem_wdata,
    
    output reg[`DataBus] mem_cp0_data,
    output reg[`RegAddrBus] mem_cp0_wr_addr,
    output reg mem_cp0_we,
    
    output reg[`AluOpBus] mem_aluop,
    output reg[`RegBus] mem_mem_addr,
    output reg[`RegBus] mem_reg2
);

endmodule