// Module RAMWrapper that adaptas a SRAM module as declared in thinpad_top.v 
// to a RAM / ROM module.
// Author: LYL
// Created on: 2018/11/24

`timescale 1ns / 1ps
`include "defines.vh"

module RAMWrapper(
	input wire clk,
	
	// From MEM
    input wire ce_i,
    input wire we_i,
    input wire[`DataAddrBus] addr_i,
    input wire[3:0] sel_i,
    input wire[`DataBus] data_i,
    
    // To MEM
    output reg[`DataBus] data_o,
    
    // Adaptee
    inout wire[`InstBus] ram_data,  // RAM数据
    output reg[19:0] ram_addr,      // RAM地址
    output reg[3:0] ram_be_n,       // RAM字节使能，低有效。如果不使用字节使能，请保持为0
    output reg ram_ce_n,            // RAM片选，低有效
    output reg ram_oe_n,            // RAM读使能，低有效
    output reg ram_we_n             // RAM写使能，低有效
);

    // Tri-state
    assign ram_data = (ce_i == `ChipEnable && we_i == `WriteEnable) ? data_i : {`DataWidth{1'bz}};
    
    // Read data_o from ram_data
    always @(*) begin
        if (ce_i == `ChipEnable && we_i == `WriteDisable) 
            data_o <= ram_data;
        else
            data_o <= 0;
    end
   
    always @ (*) begin
        ram_be_n <= 0;
        ram_addr <= addr_i[21:2];   // Only use low 20 bits, index by 32-bit word
        if (ce_i == `ChipDisable) begin
            ram_ce_n <= 1;
            ram_oe_n <= 1;
            ram_we_n <= 1;
//            ram_be_n <= 0;
        end else begin
            ram_ce_n <= 0;
            if (we_i == `WriteEnable) begin
                ram_oe_n <= 1;
                ram_we_n <= !clk;   // LOW at the first half cycle, HIGH for the rest
                ram_be_n <= ~sel_i;  // Happily, their meanings are almost the same
            end else begin  
                ram_oe_n <= 0;
                ram_we_n <= 1;
//                ram_be_n <= 0;
            end
        end
    end 
    
endmodule
