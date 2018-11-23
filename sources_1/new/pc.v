`timescale 1ns / 1ps
`include "defines.vh"

module PC(
    input wire clk,
    input wire rst,
    
    // From CTRL
    input wire flush,
    input wire[5:0] stall,  // Changed from wire to wire[5:0]
    input wire[`InstAddrBus] new_pc,    // Necessary??
    
    // From ID
    input wire branch_flag_i,
    input wire[`InstAddrBus] branch_target_address_i,    // Changed from RegAddrBus to InstAddrBus
    
    // From EX
    input wire[1:0] rom_op_i,
    input wire[`DataBus] rom_wr_data_i,
    input wire[`InstAddrBus] rom_rw_addr_i,
    
    // To ROM
    output reg[`InstAddrBus] addr,
    output reg ce,
    output reg rom_op_o,
    output reg[`DataBus] wr_data_o
);

    // After we assign rom_rw_addr_i to addr, we need to be able to 
    // switch back to the real PC. Hence the following two variables. 
    reg[`InstAddrBus] m_pc;  
    wire[`InstAddrBus] m_pc_plus_4 = m_pc + 4;
    
    // Resolve wr_data_o and rom_op_o
    always @(*) begin
        wr_data_o <= rom_wr_data_i;    
        rom_op_o <= rom_op_i == `PC_ROM_OP_WRITE ? `ROM_OP_WRITE : `ROM_OP_READ;
    end

    // Resolve ce
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable;
        end else begin
            ce <= `ChipEnable;
        end
    end

    // Resolve addr and update m_pc.
    always @(posedge clk) begin        
        if (ce == `ChipDisable) begin
            addr <= 0;
            m_pc <= 0;
        end else if (flush) begin
            addr <= new_pc;
            m_pc <= new_pc;
        end else if (stall[0] == `NoStop) begin 
            // Priority of stall is higher than read / write from ROM!!
            case (rom_op_i)
            `PC_ROM_OP_READ: begin
                addr <= rom_rw_addr_i;
            end
            `PC_ROM_OP_WRITE: begin
                addr <= rom_rw_addr_i;
            end
            default: begin
                if (branch_flag_i == `Branch) begin
                    addr <= branch_target_address_i;
                    m_pc <= branch_target_address_i;
                end else begin
                    addr <= m_pc_plus_4;
                    m_pc <= m_pc_plus_4;
                end
            end
            endcase
        end // else
    end // always

endmodule
