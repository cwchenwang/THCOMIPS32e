`include "defines.v"

module EX_MEM(
    input wire clk,
    input wire rst,

    // flush and stall
    input wire flush,
    input wire stall,

    // From EX
    input wire[`RegAddrBus] ex_wd,
    input wire ex_wreg,
    input wire[`RegBus] ex_wdata,
    input wire[`AluOpBus] ex_aluop,
    input wire[`RegBus] ex_mem_addr,
    input wire[`RegBus] ex_reg2,

    // To MEM
    output reg[`RegAddrBus] mem_wd,
    output reg mem_wreg,
    output reg[`RegBus] mem_wdata,
    output reg[`AluOpBus] mem_aluop,
    output reg[`RegBus] mem_mem_addr,
    output reg[`RegBus] mem_reg2,
);

endmodule