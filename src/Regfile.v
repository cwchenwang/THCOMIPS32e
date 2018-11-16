`include "defines.v"

module Regfile(
    input wire rst,
    input wire clk,

    // From MEM/WB or WB, write
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
    output reg[`RegBus] rdata2,
);

endmodule