// Author: LYL

`timescale 1ns / 1ps
`include "defines.vh"

module ROMWrapper(
    input wire clk,

    // From PC
	input wire[`InstAddrBus] addr_i,
	input wire ce_i,
	input wire op_i,
	input wire[`InstBus] wr_data_i,
	
	// To IF/ID
	output reg[`InstBus] data_o,
	
	// Adaptee
	inout wire[`InstBus] ram_data,  // RAM数据
    output reg[19:0] ram_addr,		// RAM地址
    output reg[3:0] ram_be_n,		// RAM字节使能，低有效。如果不使用字节使能，请保持为0
    output reg ram_ce_n,			// RAM片选，低有效
    output reg ram_oe_n,			// RAM读使能，低有效
    output reg ram_we_n				// RAM写使能，低有效
);
    // Tri-state
    assign ram_data = (ce_i == `ChipEnable && op_i == `ROM_OP_WRITE) ? wr_data_i : {`InstWidth{1'bz}};
    
    // Read data_o from ram_data
    always @(*) begin
        if (ce_i == `ChipEnable && op_i == `ROM_OP_READ) 
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
        end else begin
            ram_ce_n <= 0;
            if (op_i == `ROM_OP_READ) begin
                ram_oe_n <= 0;
                ram_we_n <= 1;
            end else begin  // ROM_OP_WRITE
                ram_oe_n <= 1;
                ram_we_n <= !clk;   // LOW at the first half cycle, HIGH for the rest
            end
        end
    end 

endmodule 