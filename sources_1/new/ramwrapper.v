// Module RAMWrapper that adaptas a SRAM module as declared in thinpad_top.v 
// to a RAM / ROM module.
// Author: LYL, ZDC
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
    output reg ram_we_n,             // RAM写使能，低有效
    
    // For Base Ram
    input wire tbre,
    input wire tsre,
    input wire data_ready,

    output reg rdn,
    output reg wrn
);

    // for Base Ram
    reg write_uart_prep;
    reg read_uart_prep;
    reg read_flag_prep;
    reg[`RegBus] flag_value;

    // Tri-state, write to either MEM or UART
    assign ram_data = (ce_i == `ChipEnable && we_i == `WriteEnable) ? data_i : {`DataWidth{1'bz}};
    
    // Read data_o from ram_data
    always @(*) begin
        if (ce_i == `ChipEnable && we_i == `WriteDisable) 
            // UART data / UART flags / MEM 
            data_o <= read_flag_prep ? flag_value : ram_data;
        else
            data_o <= 0;
    end
    
    // wrn control
    always @ (*) begin
        if (ce_i == `ChipDisable) begin
            wrn <= 1'b1;
        end else if (write_uart_prep) begin
            wrn <= clk;
        end else begin
            wrn <= 1'b1;
        end
    end

    // rdn control
    always @ (*) begin
        if (ce_i == `ChipDisable) begin
            rdn <= 1'b1;
        end else if (read_uart_prep) begin
            rdn <= clk;
        end else begin
            rdn <= 1'b1;
        end
    end
    
    // flag_value
    always @(*) begin
        if (ce_i == `ChipDisable || !read_flag_prep) begin
            flag_value <= 0;
        end else if (data_ready && tbre && tsre) begin
            // 串口可读可写
            flag_value <= 8'b00000011;
        end else if (tbre && tsre) begin
            // 串口只写
            flag_value <= 8'b00000001;
        end else if (data_ready) begin
            // 串口只读
            flag_value <= 8'b00000010;
        end else begin
            // 串口不读不写
            flag_value <= 8'b00000000;
        end    
    end
   
    always @ (*) begin
        ram_be_n <= 0;
        ram_addr <= addr_i[21:2];   // Only use low 20 bits, index by 32-bit word
        read_uart_prep <= 0;
        write_uart_prep <= 0;
        read_flag_prep <= 0;
        
        if (ce_i == `ChipDisable) begin
            ram_ce_n <= 1;
            ram_oe_n <= 1;
            ram_we_n <= 1;
        
        end else begin
            ram_ce_n <= 0;
            if (we_i == `WriteEnable) begin
                if ((addr_i & ~(32'b111)) == (`UART_DATA_ADDR & ~(32'b111))) begin
                    // Write UART
                    ram_oe_n <= 1;
                    ram_ce_n <= 1;
                    ram_we_n <= 1;
                    write_uart_prep <= 1;
                end else begin
                    // Normal write
                    ram_oe_n <= 1;
                    ram_we_n <= !clk;   // LOW at the first half cycle, HIGH for the rest
                    ram_be_n <= ~sel_i;  // Happily, their meanings are almost the same
                end
            end else begin
                if ((addr_i & ~(32'b111)) == (`UART_DATA_ADDR & ~(32'b111))) begin 
                    if (addr_i >= `UART_FLAG_ADDR) begin 
                        // Read UART flags
                        ram_oe_n <= 1;
                        ram_ce_n <= 1;
                        ram_we_n <= 1;
                        read_flag_prep <= 1;
                    end else begin
                        // Read UART
                        ram_oe_n <= 1;
                        ram_ce_n <= 1;
                        ram_we_n <= 1;
                        read_uart_prep <= 1;
                    end
                end else begin 
                    // Normal read
                    ram_oe_n <= 0;
                    ram_we_n <= 1;
                end
            end
        end
    end 
    
endmodule
