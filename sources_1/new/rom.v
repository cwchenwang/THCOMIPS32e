`timescale 1ns / 1ps
`include "defines.vh"

module ROM(
    input wire[`InstAddrBus] addr,
    input wire ce,
    input wire rom_op_o,
    input wire[`DataBus] rom_wr_data_o,
    
    output reg[`InstBus] inst_or_data   // To IF/ID and MEM/WB
    );
endmodule
