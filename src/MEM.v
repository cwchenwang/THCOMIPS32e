`include "defines.v"

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
    output reg[`RegBus] mem_addr_o,
    output wire mem_we_o,
    output reg[3:0] mem_sel_o,
    output reg[`RegBus] mem_data_o,
    output reg mem_ce_o
);

endmodule