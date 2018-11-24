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
// Module:  openmips_min_sopc
// File:    openmips_min_sopc.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 基于OpenMIPS处理器的一个简单SOPC，用于验证具备了
//              wishbone总线接口的openmips，该SOPC包含openmips、
//              wb_conmax、GPIO controller、flash controller，uart 
//              controller，以及用来仿真flash的模块flashmem，在其中
//              存储指令，用来仿真外部ram的模块datamem，在其中存储
//              数据，并且具有wishbone总线接口    
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.vh"

module openmips_min_sopc(
	input wire clk,
	input wire rst
);
      // Instruction memory
      // Adapter
      wire[`InstAddrBus] inst_addr;
      wire rom_ce;
      wire rom_we;
      wire[`InstBus] rom_wr_data;
      wire[`InstBus] inst;
      
//      // Adaptee
//      wire[`InstBus] base_ram_data; //BaseRAM数据，低8位与CPLD串口控制器共享
//      wire[`InstAddrBus] base_ram_addr; //BaseRAM地址 只使用低20位
//      wire[3:0] base_ram_be_n;  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
//      wire base_ram_ce_n;       //BaseRAM片选，低有效
//      wire base_ram_oe_n;       //BaseRAM读使能，低有效
//      wire base_ram_we_n;       //BaseRAM写使能，低有效
      
      // Data memory
      wire mem_we_i;
      wire[`RegBus] mem_addr_i;
      wire[`RegBus] mem_data_i;
      wire[`RegBus] mem_data_o;
      wire[3:0] mem_sel_i; 
      wire mem_ce_i;   
      
      // Interrupt
      wire[5:0] int;
      wire timer_int;
     
      //assign int = {5'b00000, timer_int, gpio_int, uart_int};
      assign int = {5'b00000, timer_int};
    
     THCOMIPS32e cpu(
        .clk(clk),
        .rst(rst),
    
        .rom_addr_o(inst_addr),
        .rom_ce_o(rom_ce),
        .rom_we_o(rom_we),
        .rom_wr_data_o(rom_wr_data),
        .rom_data_i(inst),

        .int_i(int),

        .ram_we_o(mem_we_i),
        .ram_addr_o(mem_addr_i),
        .ram_sel_o(mem_sel_i),
        .ram_data_o(mem_data_i),
        .ram_data_i(mem_data_o),
        .ram_ce_o(mem_ce_i),
        
        .timer_int_o(timer_int)			
    );
	
//	sram_model base1(/*autoinst*/
//        .DataIO(base_ram_data[15:0]),
//        .Address(base_ram_addr[19:0]),
//        .OE_n(base_ram_oe_n),
//        .CE_n(base_ram_ce_n),
//        .WE_n(base_ram_we_n),
//        .LB_n(base_ram_be_n[0]),
//        .UB_n(base_ram_be_n[1])
//    );
                
//    sram_model base2(/*autoinst*/
//        .DataIO(base_ram_data[31:16]),
//        .Address(base_ram_addr[19:0]),
//        .OE_n(base_ram_oe_n),
//        .CE_n(base_ram_ce_n),
//        .WE_n(base_ram_we_n),
//        .LB_n(base_ram_be_n[2]),
//        .UB_n(base_ram_be_n[3])
//    );
    
//    RAMWrapper rom_wrapper(
//        .clk(clk),
//        .addr_i(inst_addr),
//        .ce_i(rom_ce),
//        .we_i(rom_we),
//        .data_i(rom_wr_data),
//        .data_o(inst),
//        .sel_i(4'b1111),    // Always write all 32 bits
        
//        .ram_data(base_ram_data),
//        .ram_addr(base_ram_addr),
//        .ram_be_n(base_ram_be_n),
//        .ram_ce_n(base_ram_ce_n),
//        .ram_oe_n(base_ram_oe_n),
//        .ram_we_n(base_ram_we_n)
//    );

	inst_rom inst_rom0(
		.ce(rom_ce),
		.addr(inst_addr),
		.inst(inst)	
	);

	data_ram data_ram0(
		.clk(clk),
		.ce(mem_ce_i),
		.we(mem_we_i),
		.addr(mem_addr_i),
		.sel(mem_sel_i),
		.data_i(mem_data_i),
		.data_o(mem_data_o)	
	);

endmodule