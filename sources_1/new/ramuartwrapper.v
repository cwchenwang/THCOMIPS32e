// Module RamUartWrapper that contorls data memory and UART. 
// to a RAM / ROM module.
// Author: LYL, ZDC
// Created on: 2018/11/24

`timescale 1ns / 1ps
`include "defines.vh"

module RamUartWrapper(
	input wire clk,
	
	// From MEM
    input wire ce_i,
    input wire we_i,
    input wire[`DataAddrBus] addr_i,
    input wire[3:0] sel_i,
    input wire[`DataBus] data_i,
    
    // To MEM
    output reg[`DataBus] data_o,
    
    // UART signals for Base Ram
    input wire tbre,
    input wire tsre,
    input wire data_ready,
    output reg rdn,
    output reg wrn,
    
    // Adaptee protected
    inout wire[`InstBus] ram_data,  // RAM数据
    
    // Adaptee private
    output wire[19:0] ram_addr,      // RAM地址
    output wire[3:0] ram_be_n,       // RAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ram_ce_n,            // RAM片选，低有效
    output wire ram_oe_n,            // RAM读使能，低有效
    output wire ram_we_n             // RAM写使能，低有效
);

    // For Base Ram
    // These signals have considered ce_i; no need test ce_i again.
    reg write_uart_prep;
    reg read_uart_prep;
    reg read_flag_prep;
    reg[7:0] flag_value;
    
    wire[`DataBus] basic_wrapper_data_o;

    // Tri-state, write to UART
    assign ram_data = write_uart_prep ? {24'bz, data_i[7:0]} : {`DataWidth{1'bz}};
            
    BasicRamWrapper basic_wrapper(
        .clk(clk),
        .ce_i(ce_i && !write_uart_prep && !read_uart_prep && !read_flag_prep),
        .we_i(we_i && !write_uart_prep),
        .addr_i(addr_i),
        .sel_i(sel_i),
        .data_i(data_i),
        .data_o(basic_wrapper_data_o),
        .ram_data(ram_data),        // RAM数据
        .ram_addr(ram_addr),        // RAM地址
        .ram_be_n(ram_be_n),        // RAM字节使能，低有效。如果不使用字节使能，请保持为0
        .ram_ce_n(ram_ce_n),        // RAM片选，低有效
        .ram_oe_n(ram_oe_n),        // RAM读使能，低有效
        .ram_we_n(ram_we_n)         // RAM写使能，低有效
    );
    
    // Read data_o from UART flag / UART data / basic wrapper (memory)
    always @(*) begin
        data_o <= read_flag_prep ? {4{flag_value}} : read_uart_prep ? {4{ram_data[7:0]}} : basic_wrapper_data_o;
    end
    
    // wrn control
    always @(*) begin
        if (write_uart_prep) begin
            wrn <= clk;
        end else begin
            wrn <= 1'b1;
        end
    end

    // rdn control
    always @(*) begin
        if (read_uart_prep) begin
            rdn <= clk;
        end else begin
            rdn <= 1'b1;
        end
    end
    
    // flag_value
    always @(*) begin
        if (!read_flag_prep) begin
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
   
    always @(*) begin
        read_uart_prep <= 0;
        write_uart_prep <= 0;
        read_flag_prep <= 0;
        if (ce_i == `ChipEnable) begin
            if (we_i == `WriteEnable) begin
                if ((addr_i & ~(32'b111)) == (`UART_DATA_ADDR & ~(32'b111))) begin
                    // Write UART
                    write_uart_prep <= 1;
                end 
            end else begin
                if ((addr_i & ~(32'b111)) == (`UART_DATA_ADDR & ~(32'b111))) begin 
                    if (addr_i >= `UART_FLAG_ADDR) begin 
                        // Read UART flags
                        read_flag_prep <= 1;
                    end else begin
                        // Read UART
                        read_uart_prep <= 1;
                    end
                end 
            end
        end
    end 
    
endmodule
