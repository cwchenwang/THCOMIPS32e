`timescale 1ns / 1ps
`include "defines.vh"

module Regfile(
    input wire rst,
    input wire clk,

    // write
    input wire we,
    input wire[`RegAddrBus] waddr,
    input wire[`RegBus] wdata,

    // read reg1
    input wire re1,
    input wire[`RegAddrBus] raddr1,
    output reg[`RegBus] rdata1,

    //read reg2
    input wire re2,
    input wire[`RegAddrBus] raddr2,
    output reg[`RegBus] rdata2
);

endmodule
