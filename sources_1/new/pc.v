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
    input wire[5:0] stall,  // TODO: maybe not all 6 bits are necessary
    input wire[`InstAddrBus] new_pc,    
    
    // From ID
    input wire branch_flag_i,
    input wire[`InstAddrBus] branch_target_address_i,    
    
    // From EX
    input wire[1:0] rom_op_i,
    input wire[`InstBus] rom_wr_data_i,
    input wire[`InstAddrBus] rom_rw_addr_i,
    input wire[`AluOpBus] aluop_i,
    
    // To ROM
    output reg[`InstAddrBus] addr_o,    
    output reg ce_o,
    output reg we_o,
    output reg[`InstBus] data_o,
    output reg[`AluOpBus] aluop_o,  // To determine to sel_i at the next stage
    
    // To IF/ID
    output reg insert_nop_o,  // Shouldn't conflict with normal stall signal
    output reg[`InstAddrBus] pc_o     // Proper PC, equals data_o when rom_op_i is `ROM_OP_INST
);

    // After we assign rom_rw_addr_i to addr_o, we need to be able to 
    // switch back to the real PC. Hence the following two variables. 
    reg[`InstAddrBus] m_pc;  
    wire[`InstAddrBus] m_pc_plus_4 = m_pc + 4;
    
    // Resolve data_o, rom_op_o, aluop_o
    always @(posedge clk) begin
        data_o <= rom_wr_data_i;    
        we_o <= rom_op_i == `ROM_OP_STORE ? `WriteEnable : `WriteDisable;
        aluop_o <= aluop_i;
    end

    // Resolve ce_o
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            ce_o <= `ChipDisable;
        end else begin
            ce_o <= `ChipEnable;
        end
    end

    // Resolve addr_o, pc_o, insert_nop_o, and update m_pc.
    always @(posedge clk) begin        
        if (ce_o == `ChipDisable) begin
            addr_o <= 0;
            pc_o <= 0;
            m_pc <= 0;
            insert_nop_o <= 0;
        end else if (flush) begin
            addr_o <= new_pc;
            pc_o <= new_pc;
            m_pc <= new_pc;
            insert_nop_o <= 0;
        end else begin
            // Priority of structural conflict is higher than stall!!
            // When structural conflict (detected in EX) appears, stall can 
            // only be requested from ID. In that case, we still need ROM to 
            // operate.
           case (rom_op_i)
           `ROM_OP_LOAD: begin
               addr_o <= rom_rw_addr_i;
               pc_o <= m_pc;
               insert_nop_o <= 1;
           end
           `ROM_OP_STORE: begin
               addr_o <= rom_rw_addr_i;
               pc_o <= m_pc;
               insert_nop_o <= 1;
           end
           default: begin
                insert_nop_o <= 0;
                if (stall[0] == `NoStop) begin
                    if (branch_flag_i == `Branch) begin
                        addr_o <= branch_target_address_i;
                        pc_o <= branch_target_address_i;
                        m_pc <= branch_target_address_i;
                    end else begin
                        addr_o <= m_pc_plus_4;
                        pc_o <= m_pc_plus_4;
                        m_pc <= m_pc_plus_4;
                    end 
                end
           end
           endcase 
        end
    end // always

endmodule
