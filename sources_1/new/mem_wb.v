`timescale 1ns / 1ps
`include "defines.vh"

module MEM_WB(
    input wire clk,
    input wire rst,

    // flush and stall
    input wire flush,
    input wire stall,

    // From MEM
    input wire[`RegAddrBus] mem_wd,
    input wire mem_wreg,
    input wire[`RegBus] mem_wdata,

    // To WB
    output reg[`RegAddrBus] wb_wd,
    output reg wb_wreg,
    output reg[`RegBus] wb_wdata
);

endmodule
