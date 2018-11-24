// Testbench for ROMWrapper.
// Author: LYL 

`timescale 1ns / 1ps
`include "../../sources_1/new/defines.vh"

module ROMWrapperTest();
    localparam half_cycle = 10;
    localparam cycle = 2 * half_cycle;

    reg clk;

    // Adapter
    reg[`InstAddrBus] inst_addr;
    reg rom_ce;
    reg rom_op;
    reg[`InstBus] rom_wr_data;
    wire[`InstBus] inst;
    
    // Adaptee
    wire[`InstBus] base_ram_data; //BaseRAM数据，低8位与CPLD串口控制器共享
    wire[19:0] base_ram_addr; //BaseRAM地址 只使用低20位
    wire[3:0] base_ram_be_n;  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    wire base_ram_ce_n;       //BaseRAM片选，低有效
    wire base_ram_oe_n;       //BaseRAM读使能，低有效
    wire base_ram_we_n;       //BaseRAM写使能，低有效
    
    integer count;
    
    sram_model base1(/*autoinst*/
        .DataIO(base_ram_data[15:0]),
        .Address(base_ram_addr[19:0]),
        .OE_n(base_ram_oe_n),
        .CE_n(base_ram_ce_n),
        .WE_n(base_ram_we_n),
        .LB_n(base_ram_be_n[0]),
        .UB_n(base_ram_be_n[1])
    );
                
    sram_model base2(/*autoinst*/
        .DataIO(base_ram_data[31:16]),
        .Address(base_ram_addr[19:0]),
        .OE_n(base_ram_oe_n),
        .CE_n(base_ram_ce_n),
        .WE_n(base_ram_we_n),
        .LB_n(base_ram_be_n[2]),
        .UB_n(base_ram_be_n[3])
    );
                
    ROMWrapper rom_wrapper(
        .clk(clk),
        .addr_i(inst_addr),
        .ce_i(rom_ce),
        .op_i(rom_op),
        .wr_data_i(rom_wr_data),
        .data_o(inst),
        
        .ram_data(base_ram_data),
        .ram_addr(base_ram_addr),
        .ram_be_n(base_ram_be_n),
        .ram_ce_n(base_ram_ce_n),
        .ram_oe_n(base_ram_oe_n),
        .ram_we_n(base_ram_we_n)
    );
    
        initial begin
        clk = 1;
        forever #half_cycle clk = !clk;
    end
    
    initial begin
        // Initialization for unknown reason
        rom_ce = 1;
        rom_wr_data = ~0;
        inst_addr = ~0;    
        rom_op = `ROM_OP_WRITE;
        #(cycle * 1)
        rom_op = `ROM_OP_READ;
        #(cycle * 1);
        
        // Write sequentially then read backwords
        inst_addr = 0;
        rom_wr_data = 0;
        
        rom_op = `ROM_OP_WRITE;
        for (count = 0; count != 4; count = count + 1) begin
            #cycle;
            inst_addr = inst_addr + 4;
            rom_wr_data = rom_wr_data + 1;
        end
        
        rom_op = `ROM_OP_READ;
        for (count = 0; count != 4; count = count + 1) begin
            inst_addr = inst_addr - 4;
            #cycle;
        end
        
        // Write sequentially and read in the same order
        rom_op = `ROM_OP_WRITE;
        inst_addr = 0;
        rom_wr_data = 0;
        for (count = 0; count != 4; count = count + 1) begin
            #cycle;
            inst_addr = inst_addr + 4;
            rom_wr_data = rom_wr_data + 1;
        end
        
        rom_op = `ROM_OP_READ;
        inst_addr = inst_addr - 16;
        for (count = 0; count != 4; count = count + 1) begin
            #cycle;
            inst_addr = inst_addr + 4;
        end
        
        // Raed after write
        rom_op = `ROM_OP_WRITE;
        inst_addr = 'h1000;
        rom_wr_data = 'h2333;
        #cycle;
        
        rom_op = `ROM_OP_READ;
        #cycle;
                
        $stop;
    end


endmodule
