//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  if_id
// File:    if_id.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: IF/ID阶段的寄存器
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`include "defines.vh"

module IF_ID(
	input wire					clk,
	input wire					rst,

	//来自控制模块的信息
	input wire[4:0]            stall,	
	input wire                 flush,

    // From PC
    input wire                 is_load_store,
    input wire[`InstAddrBus]   if_pc,
	
	// From ROM
	input wire[`InstBus]		if_inst,
	
	// To ID
	output reg[`InstAddrBus]    id_pc,
	output reg[`InstBus]        id_inst  
);

    reg[`InstAddrBus] last_pc;
    reg[`InstBus] last_inst;
    reg[4:0] last_stall;
    
    // History info; useful when stall in the middle of loading / storing ROM.
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
			last_pc <= `PC_INIT_ADDR;
            last_inst <= 0;
            last_stall <= 0;        
        end else begin
            if (if_pc != last_pc) begin
                // When a normal stall is requested when ROM is loading / storing,
                // if_inst becomes:
                // t = 0: instruction 
                // t = 1: ?? (writing to ROM)
                // t = 2: ??
                last_inst <= if_inst;
                last_pc <= if_pc;
            end
            last_stall <= stall;
        end
    end

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end else if (flush) begin
			id_pc <= `PC_INIT_ADDR;
			id_inst <= `ZeroWord;	
		end else if (is_load_store && last_stall[0] == `Stop && stall[0] == `NoStop) begin	
            // Given is_load_store, we were still dealing with structural conflict;
            // Changed from stalled to not stalled -> we have stored an instruction 
            // (last_inst), so send it to ID.
            id_pc <= last_pc;
            id_inst <= last_inst;
		end else if ((stall[0] == `Stop && stall[1] == `NoStop) || is_load_store) begin
			id_pc <= `PC_INIT_ADDR;
			id_inst <= `ZeroWord;	
		end else if (stall[0] == `NoStop) begin
			id_pc <= if_pc;
			id_inst <= if_inst;
		end	// Implied: nothing changes
	end

endmodule