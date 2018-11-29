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
// Module:  ctrl
// File:    ctrl.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 控制模块，控制流水线的刷新、暂停等
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`include "defines.vh"

module Ctrl(
	input wire				rst,

	input wire[31:0]       excepttype_i,
	input wire[`RegBus]    cp0_epc_i,

	input wire             stallreq_from_id,

	//来自执行阶段的暂停请求
    input wire             stallreq_from_ex,
//    input wire             struct_conflict_from_ex,

	output reg[`RegBus]    new_pc,
	output reg             flush,	
	output reg[4:0]        stall       
);

	always @ (*) begin
		if (rst == `RstEnable) begin
			stall <= 5'b00000;
			flush <= 1'b0;
			new_pc <= `PC_INIT_ADDR;
		end else if (excepttype_i != `ZeroWord) begin
            stall <= 5'b00000;
			flush <= 1'b1;
			case (excepttype_i)
            32'h00000001: begin   //interrupt
                new_pc <= `PC_INT_ADDR;
            end
            32'h00000008: begin   //syscall
                new_pc <= `PC_SYSCALL_ADDR;
            end
            32'h0000000a: begin   //inst_invalid
                new_pc <= `PC_INSTINVALID_ADDR;
            end
            32'h0000000d: begin   //trap
                new_pc <= `PC_TRAP_ADDR;
            end
            32'h0000000c: begin   //ov
                new_pc <= `PC_OVERFLOW_ADDR;
            end
            32'h0000000e: begin   //eret
                new_pc <= `PC_ERET_ADDR;
            end
            default: begin
                new_pc <= `PC_INSTINVALID_ADDR; // Not used
            end
			endcase 						
		end else if (stallreq_from_ex == `Stop) begin
            // Stall EX, insert nop to MEM
            stall <= 5'b00111;
            flush <= 1'b0;		
            new_pc <= `PC_INIT_ADDR;    // Not used
		end else if (stallreq_from_id == `Stop) begin
            // Stall ID, insert nop to EX
			stall <= 5'b00011;	
			flush <= 1'b0;
			new_pc <= `PC_INIT_ADDR;     // Not used
		end else begin
			stall <= 5'b00000;
			flush <= 1'b0;
			new_pc <= `PC_INIT_ADDR;		
		end    //if
	end      //always
			

endmodule