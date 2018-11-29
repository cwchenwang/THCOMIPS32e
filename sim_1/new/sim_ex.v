`timescale 1ns / 1ps
`include "../../sources_1/new/define.vh"

module sim_ex();
    reg clk=0, rst=0;
    reg[`DataBus] cp0_data_i = 0;
    wire[`AluOpBus] aluop_i = `EXE_OR_OP;
    wire[`AluSelBus] alusel_i = `EXE_RES_LOGIC;
    wire[`RegBus] reg1_i = {3'h0, 2'b01000000};
    wire[`RegBus] reg2_i = {3'h0, 2'b01000010};
    wire wreg_i = 1;
    wire[`RegBus] inst_i = {4'h0};
    wire[`DataBus] wb_cp0_data = {4'h0};
    wire[`RegAddrBus] wb_cp0_addr = {4'h0};
    wire wb_cp0_we = 1;
    wire[`DataBus] mem_cp0_data = {32'b0};
    wire[`RegAddrBus] mem_cp0_addr = {32'b0};
    wire mem_cp0_we = 1;
    wire[`RegBus] link_addr_i = {32'b0};
    wire is_in_delayslot_i = 0;
endmodule
