`include "defines.v"

module id_ex(
    input wire clk,
    input wire rst,

    // flush and stall
    input wire flush,
    input wire stall,

    // From id
    input wire[`AluOpBus] id_aluop,
    input wire[`AluSelBus] id_alusel,
    input wire[`RegBus] id_reg1,
    input wire[`RegBus] id_reg2,
    input wire[`RegAddrBus] id_wd,
    input wire id_wreg,
    input wire[`RegBus] id_link_addr,
    input wire id_is_in_delayslot,
    // not sure
    //input wire[`InstBus] next_inst_in_delayslot_i,
    input wire[`RegBus] id_inst,

    // To ex
    output reg[`AluOpBus] ex_aluop,
    output reg[`AluSelBus] ex_alusel,
    output reg[`RegBus] ex_reg1,
    output reg[`RegBus] ex_reg2,
    output reg[`RegAddrBus] ex_wd,
    output reg ex_wreg,
    output reg[`RegBus] ex_link_addr,
    output reg ex_is_in_delayslot,
    output reg is_in_delayslot_o,
    output reg[`RegBus] ex_inst,
);

endmodule