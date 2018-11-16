`include "defines.v"

module EX(
    input wire rst,

    // From ID/EX
    input wire[`AluOpBus] aluop_i,
    input wire[`AluSelBus] alusel_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire[`RegBus] inst_i,

    // To wd
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,

    // B&J
    input wire[`RegBus] link_addr_i,
    input wire is_in_delayslot_i,

    // To EX/MEM
    output wire[`AluOpBus] aluop_o,
    output wire[`RegBus] mem_addr_o,
    output wire[`RegBus] reg2_o,

    // Pipeline stop/continue
    output wire stallreq_ex
);

endmodule