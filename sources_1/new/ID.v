`timescale 1ns / 1ps
`include "defines.vh"

module ID(
    input wire rst,
    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus] inst_i,

    // value of regfile
    input wire[`RegBus] reg1_data_i,
    input wire[`RegBus] reg2_data_i,

    // From ex
    input wire ex_wreg,
    input wire[`RegBus] ex_wdata,
    input wire[`RegAddrBus] ex_wd,
    input wire[`AluOpBus] ex_aluop_i,

    // From mem
    input wire mem_wreg,
    input wire[`RegBus] mem_wdata,
    input wire[`RegAddrBus] mem_wd,

    // For branch/jump
    input wire is_in_delay_slot_i,
    // not sure
    // output reg[`InstBus] next_inst_in_delay_slot_o,
    output reg branch_flag_o,
    output reg[`RegAddrBus] branch_target_addr_o,
    output reg[`RegAddrBus] link_addr_o,
    output reg is_in_delay_slot_o,

    // To register
    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,

    // normal to ex
    output reg[`AluOpBus] aluop_o,
    output reg[`AluSelBus] alusel_o,
    output reg[`RegBus] reg1_o,
    output reg[`RegBus] reg2_o,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output wire[`InstBus] inst_o,

    // Pipeline stop/continue
    output wire stallreq_id
);

endmodule