`timescale 1ns / 1ps
`include "defines.vh"

module PC(
    input wire clk,
    input wire rst,
    
    // From CTRL
    input wire flush,
    input wire[5:0] stall,  // Changed from wire to wire[5:0]
    
    // From ID
    input wire branch_flag_i,
    input wire[`InstAddrBus] branch_target_address_i,    // Changed from RegAddrBus to InstAddrBus
    
    // From EX
    input wire[1:0] rom_op_i,
    input wire[`DataBus] rom_wr_data_i,
    input wire[`InstAddrBus] rom_rw_addr_i,
    
    // To ROM
    output reg[`InstAddrBus] pc_or_addr,
    output reg ce,
    output reg rom_op_o,
    output reg[`DataBus] wr_data_o
);

    // After we assign rom_rw_addr_i to pc_or_addr, we need to be able to 
    // switch back to the real PC. Hence the following two variables. 
    reg[`InstAddrBus] pc;  
    wire[`InstAddrBus] pc_plus_4 = pc + 4;
    
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

    // Resolve pc_or_addr and update pc.
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            pc <= 0;
            pc_or_addr <= 0;
        end else if (stall[0] == `NoStop) begin 
            // Priority of stall is higher than read / write from ROM!!
            case (rom_op_i)
            `PC_ROM_OP_READ: begin
                pc_or_addr <= rom_rw_addr_i;
            end
            `PC_ROM_OP_WRITE: begin
                pc_or_addr <= rom_rw_addr_i;
            end
            default: begin
                if (branch_flag_i == `Branch) begin
                    pc_or_addr <= branch_target_address_i;
                    pc <= branch_target_address_i;
                end else begin
                    pc_or_addr <= pc_plus_4;
                    pc <= pc_plus_4;
                end
            end
            endcase
        end // else
    end // always

endmodule
