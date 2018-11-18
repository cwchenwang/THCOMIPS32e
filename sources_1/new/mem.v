`timescale 1ns / 1ps
`include "defines.vh"

module MEM(
    input wire rst,

    // From EX/MEM
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire[`RegBus] wdata_i,
    input wire[`AluOpBus] aluop_i,
    input wire[`RegBus] mem_addr_i,
    input wire[`RegBus] reg2_i,

    // From RAM
    input wire[`RegBus] mem_data_i,

    // To MEM/WB
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,

    // To RAM
    output wire mem_we_o,
    output reg mem_ce_o,
    output reg[`RamSel] mem_sel_o,
    output reg[`DataBus] mem_data_o,
    output reg[`DataAddrBus] mem_addr_o
);

    wire[`RegBus] zero32 = `ZeroWord;
    reg mem_we;
    
    assign mem_we_o = mem_we;
    
    always @(*) begin
        if (rst == `RstEnable) begin
            wd_o <= `NOPRegAddr;
            wreg_o <= `WriteDisable;
            wdata_o <= `ZeroWord;
            mem_addr_o <= `ZeroWord;
            mem_we <= `WriteDisable;
            mem_sel_o <= 4'b0;
            mem_data_o <= `ZeroWord;
            mem_ce_o <= `ChipDisable;
            
        end else begin
            wd_o <= wd_i;
            wreg_o <= wreg_i;
            wdata_o <= wdata_i;
            mem_addr_o <= `ZeroWord;
            mem_we <= `WriteDisable;
            mem_sel_o <= 4'b1111;
            mem_data_o <= `ZeroWord;    // Not in the book
            mem_ce_o <= `ChipDisable;
            
            case (aluop_i)
            `EXE_LB_OP: begin
                mem_addr_o <= mem_addr_i;
                mem_we <= `WriteDisable;
                mem_ce_o <= `ChipEnable; 
                case (mem_addr_i[1:0])
                2'b00: begin
                    wdata_o <= sign_ext_byte(mem_data_i[31:24]);
                    mem_sel_o <= 4'b1000;
                end
                2'b01: begin
                    wdata_o <= sign_ext_byte(mem_data_i[23:16]);
                    mem_sel_o <= 4'b0100;
                end
                2'b10: begin
                    wdata_o <= sign_ext_byte(mem_data_i[15:8]);
                    mem_sel_o <= 4'b0010;
                end
                2'b11: begin
                    wdata_o <= sign_ext_byte(mem_data_i[7:0]);
                    mem_sel_o <= 4'b0001;
                end
                default: begin
                    wdata_o <= `ZeroWord;
                    // Should be fine to leave mem_sel_o, since it is already set.
                end
                
                // TODO: add other cases here
                endcase
            end
            endcase
        end
    
    end
    
    // TODO: will "automatic" result in perfomance loss? If so, can we safely remove it?
    function automatic [31:0] sign_ext_byte(input [7:0] x);
    begin
        sign_ext_byte = {{24{x[7]}}, x};
    end
    endfunction 

endmodule