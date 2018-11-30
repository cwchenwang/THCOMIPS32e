// Module PC with structural conflict signals
// Author: LYL
// Created on: 2018/11/22

`timescale 1ns / 1ps
`include "defines.vh"

module PC(
    input wire clk,
    input wire rst,
    
    // From CTRL
    input wire flush,
    input wire[4:0] stall,  
    input wire[`InstAddrBus] new_pc,  
    input wire load_store_rom_i,
    
    // From ID
    input wire branch_flag_i,
    input wire[`InstAddrBus] branch_target_address_i,    
    
    // To ROM & IF_ID
    output reg[`InstAddrBus] pc_o,     // Proper PC
    output reg load_store_rom_o  
);

    wire[`InstAddrBus] pc_plus_4 = pc_o + 4;

    always @(posedge clk) begin        
        if (rst == `RstEnable) begin
            pc_o <= `PC_INIT_ADDR;
            load_store_rom_o <= 0;
        end else if (flush) begin
            pc_o <= new_pc;
            load_store_rom_o <= load_store_rom_i;
        end else begin
            load_store_rom_o <= load_store_rom_i;
            if (stall[0] == `NoStop && !load_store_rom_i) begin
                if (branch_flag_i == `Branch) begin
                    pc_o <= branch_target_address_i;
                end else begin
                    pc_o <= pc_plus_4;
                end 
            end
        end
    end // always

endmodule
