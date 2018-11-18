`timescale 1ns / 1ps
`include "defines.vh"

module EX(
    input wire rst,
    
    // From CP0
    input wire[`DataBus] cp0_data_i,

    // From ID/EX
    input wire[`AluOpBus] aluop_i,
    input wire[`AluSelBus] alusel_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire[`RegBus] inst_i,
    
    // From MEM/WB
    input wire[`DataBus] wb_cp0_data,
    input wire[`RegAddrBus] wb_cp0_addr,
    input wire wb_cp0_we,
    
    // From MEM
    input wire[`DataBus] mem_cp0_data,
    input wire[`RegAddrBus] mem_cp0_addr,
    input wire mem_cp0_we,

    // To wd
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,

    // B&J
    input wire[`RegBus] link_addr_i,
    input wire is_in_delayslot_i,
    
    // To CP0
    output reg[`RegAddrBus] cp0_rd_addr_o,    

    // To EX/MEM
    output reg ld_src_o,
    output reg[`AluOpBus] aluop_o,
    output reg[`RegBus] mem_addr_o,
    output reg[`RegBus] reg2_o,

    // Pipeline stop/continue
    output reg stallreq_ex
);

    wire[`DataBus] logicout;
    wire[`DataBus] shiftres;
    wire[`DataBus] moveres;
    wire[`DataBus] arithmeticres;
    wire[`DataBus] link_address_i;

    always @(*) begin
    // TODO: ...
    
        case (alusel_i) 
        `EXE_RES_LOGIC:
            wdata_o <= logicout;
        `EXE_RES_SHIFT:
            wdata_o <= shiftres;
        `EXE_RES_MOVE:
            wdata_o <= moveres;
        `EXE_RES_ARITHMETIC:
            wdata_o <= arithmeticres;
        `EXE_RES_JUMP_BRANCH:
            wdata_o <= link_address_i;
        default:
            wdata_o <= `ZeroWord;
        endcase
    end

endmodule
