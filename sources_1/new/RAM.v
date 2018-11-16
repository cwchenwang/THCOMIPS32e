`timescale 1ns / 1ps
`include "defines.vh"

module MEM(
    input wire rst,

    // From EX/MEM
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire[`RegBus] wdata_i,
    input wire[`AluOpBus] aluop_i,
    input wire[`RegBus] mem_addr_i,
    input wire[`RegBus] reg2_i,

    // From RAM
    input wire[`RegBus] mem_data_i,

    // To MEM/WB
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,

    // To RAM
    output wire mem_we_o,
    output reg mem_ce_o,
    output reg[`RamSel] mem_sel_o,
    output reg[`DataBus] mem_data_o,
    output reg[`DataAddrBus] mem_addr_o
);

endmodule