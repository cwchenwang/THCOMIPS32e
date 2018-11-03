`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/02 18:39:11
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "RAM.v"

module CPU(
    input wire clk,
    input wire rst
    );
    
    wire reg_dst, branch, jump, mem_read, mem_to_reg, 
        mem_write, alu_src, reg_write, zero;
    wire[1:0] alu_op;
    wire[3:0] alu_ctrl;
    wire[25:0] jump_addr;
    wire[31:0] pc_value;
    wire[31:0] inst;
    wire[31:0] alu_result;
    wire[31:0] writeback;
    wire[31:0] reg1, reg2;
    wire[31:0] data_ram_output;
    wire[31:0] ext_imm;
    
    assign ext_imm = {{16{inst[15]}}, inst[15:0]};  // Sign-extended imm
    assign writeback = mem_to_reg ? data_ram_output : alu_result;
    assign jump_addr = inst[25:0];
    
    PC pc(
        .clk(clk), 
        .rst(rst), 
        .branch_i(branch),
        .zero(zero),
        .jump_i(jump),
        .addr_i(jump_addr),
        .offset_i(ext_imm),
        .pc_o(pc_value)
    );
    
    RAM #(.LoadFib(1)) inst_ram(
        .clk(clk),
        .mode_i(`RAM_READ_MODE),
        .addr_i(pc_value),
        .data_i(32'bz),
        .data_o(inst)
    );
    
    Control ctrl(
        .op(inst[31:26]),
        .reg_dst(reg_dst),
        .jump(jump),
        .branch(branch),
        .mem_read(mem_read),    // Not used actually
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write)
    );
    
    RegFile regfile(
        .clk(clk),
        .rd1_i(inst[25:21]),
        .rd2_i(inst[20:16]),
        .wr_i(reg_dst ? inst[15:11] : inst[20:16]),
        .we_i(reg_write),
        .data_i(writeback),
        .data1_o(reg1),
        .data2_o(reg2)
    );
    
    ALUControl alu_control(
        .alu_op(alu_op),
        .funct(inst[5:0]),
        .alu_ctrl(alu_ctrl)
    );
    
    ALU alu(
        .alu_ctrl(alu_ctrl),
        .arg1(reg1),
        .arg2(alu_src ? ext_imm : reg2),
        .result(alu_result),
        .zero(zero)
    );
    
    RAM data_ram(
        .clk(clk),
        .mode_i(mem_write ? `RAM_WRITE_MODE : `RAM_READ_MODE),  // Always OK to read 
        .addr_i(alu_result),
        .data_i(reg2),
        .data_o(data_ram_output)
    );
    
endmodule
