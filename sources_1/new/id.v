`timescale 1ns / 1ps
`include "defines.vh"

module ID(
    input wire rst,
    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus] inst_i,

    // value of regfile
    input wire[`RegBus] reg1_data_i,
    input wire[`RegBus] reg2_data_i,

    // From ex
    input wire ex_wreg,
    input wire[`RegBus] ex_wdata,
    input wire[`RegAddrBus] ex_wd,
    input wire[`AluOpBus] ex_aluop_i,

    // From mem
    input wire mem_wreg,
    input wire[`RegBus] mem_wdata,
    input wire[`RegAddrBus] mem_wd,

    // For branch/jump
    input wire is_in_delay_slot_i,
    // not sure
    output reg[`InstBus] next_inst_in_delay_slot_o, // LYL: appears in Chapter 8
    output reg branch_flag_o,
    output reg[`RegAddrBus] branch_target_addr_o,
    output reg[`RegAddrBus] link_addr_o,
    output reg is_in_delay_slot_o,

    // To register
    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,

    // normal to ex
    output reg[`AluOpBus] aluop_o,
    output reg[`AluSelBus] alusel_o,
    output reg[`RegBus] reg1_o,
    output reg[`RegBus] reg2_o,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output wire[`InstBus] inst_o,

    // Pipeline stop/continue
    output wire stallreq_id
);

    wire[5:0] op = inst_i[31:26];   // op
    wire[4:0] op2 = inst_i[10:6];   // shamt
    wire[4:0] op3 = inst_i[5:0];    // funct
    wire[4:0] op4 = inst_i[20:16];  // rt
    
    wire[`RegBus] pc_plus_4 = pc_i + 4;
    wire[`RegBus] pc_plus_8 = pc_i + 8;
    wire[`RegBus] imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};
    
    reg[`RegBus] imm;
    reg instvalid; 
    
    assign inst_o = inst_i;
    
    always @(*) begin
        if (rst == `RstEnable) begin
            // By Chap 5
            aluop_o <= `EXE_NOP_OP;
            alusel_o <= `EXE_RES_NOP;
            wd_o <= `NOPRegAddr;
            wreg_o <= `WriteDisable;
            instvalid <= `InstValid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= `NOPRegAddr;
            reg2_addr_o <= `NOPRegAddr;
            imm <= 32'h0;
            
            // Chap 8
            link_addr_o <= `ZeroWord;
            branch_target_addr_o <= `ZeroWord;
            branch_flag_o <= `NotBranch;
            is_in_delay_slot_o <= `NotInDelaySlot;
            
        end else begin
            // By Chap 5
            aluop_o <= `EXE_NOP_OP;
            alusel_o <= `EXE_RES_NOP;
            wd_o <= inst_i[15:11];  // rd
            wreg_o <= `WriteDisable;
            instvalid <= `InstInvalid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= inst_i[25:21];   // rs
            reg2_addr_o <= inst_i[20:16];   // rt
            imm <= `ZeroWord;
            
            // Chap 8
            link_addr_o <= `ZeroWord;
            branch_target_addr_o <= `ZeroWord;
            branch_flag_o <= `ZeroWord;
            is_in_delay_slot_o <= `NotInDelaySlot;
            
            case (op)
            `EXE_SPECIAL_INST: begin
                case (op2)
                5'b0: begin     
                    // TODO: does the manual require shamt to be zero for the following instructions?
                    case (op3)
                    // TODO: insert basic instructions here
                    `EXE_JR: begin  
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_JR_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b0;
                        link_addr_o <= `ZeroWord;
                        branch_target_addr_o <= reg1_o;
                        branch_flag_o <= `Branch;
                        is_in_delay_slot_o <= `InDelaySlot;
                        instvalid <= `InstValid;
                    end
                    `EXE_J: begin   
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_J_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        reg1_read_o <= 1'b0;
                        reg2_read_o <= 1'b0;
                        link_addr_o <= `ZeroWord;
                        branch_flag_o <= `Branch;
                        next_inst_in_delay_slot_o <= `InDelaySlot;
                        instvalid <= `InstValid;
                        branch_target_addr_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};    // pc[31:28] or pc_plus_4[31:28]??
                    end
                    `EXE_JAL: begin
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_JAL_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        reg1_read_o <= 1'b0;
                        reg2_read_o <= 1'b0;
                        wd_o <= 5'b11111;
                        link_addr_o <= pc_plus_8;
                        branch_flag_o <= `Branch;
                        next_inst_in_delay_slot_o <= `InDelaySlot;
                        instvalid <= `InstValid;
                        branch_target_addr_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
                    end
                    `EXE_BEQ: begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_BEQ_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b1;
                        instvalid <= `InstValid;
                        if (reg1_o == reg2_o) begin
                            branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o <= `Branch;
                            next_inst_in_delay_slot_o <= `InDelaySlot;
                        end                    
                    end
                    `EXE_BGTZ: begin    // bgtz
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_BGTZ_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b0;
                        instvalid <= `InstValid;
                        if (!reg1_o[31] && reg1_o != `ZeroWord) begin
                            branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o <= `Branch;
                            next_inst_in_delay_slot_o <= `InDelaySlot;
                        end
                    end
                    `EXE_BNE: begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_BLEZ_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b1;
                        instvalid <= `InstValid;
                        if (reg1_o != reg2_o) begin
                            branch_target_addr_o <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o <= `Branch;
                            next_inst_in_delay_slot_o <= `InDelaySlot;
                        end
                    end
                    endcase // case (op3)
                end
                // TODO: ...
                default: begin
                
                end
                endcase     // case (op2)
            end     // EXE_SPECIAL_INST
            
            `EXE_LB: begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LB_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end
            
            endcase // case (op)
        end // else
    end // always
    
    // TODO: ...
    
    always @(*) begin
        if (rst == `RstEnable) begin
            is_in_delay_slot_o <= `NotInDelaySlot;
        end else begin
            is_in_delay_slot_o <= is_in_delay_slot_i;
        end
    end
    
endmodule