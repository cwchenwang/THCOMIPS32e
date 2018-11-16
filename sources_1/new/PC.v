`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/02 15:10:41
// Design Name: 
// Module Name: PC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "defines.vh"

module PC(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire stall,
    input wire[`InstAddrBus] new_pc,
    input wire branch_flag_i,
    input wire[`RegAddrBus] branch_target_address_i,
    input wire[1:0] rom_op_i,
    input wire[`DataBus] rom_wr_data_i,     // Data to write
    input wire[`DataAddrBus] rom_rw_addr_i, // Read / write address
    
    output reg[`InstAddrBus] pc_or_addr,
    output reg ce,
    output reg rom_op_o,        // Read or write
    output reg[`DataBus] rom_wr_data_o
);

endmodule
