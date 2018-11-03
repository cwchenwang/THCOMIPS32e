`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/02 14:42:14
// Design Name: 
// Module Name: RAM
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

`define RAM_READ_MODE 1'b0
`define RAM_WRITE_MODE 1'b1

module RAM #(Capacity = 64, LoadFib = 0)(
    input wire clk,
    input wire mode_i,
    input wire[31:0] addr_i,
    input wire[31:0] data_i, 
    output reg[31:0] data_o
    );
    
    reg[7:0] memory[0: Capacity - 1]; // 最多16个数据，因为好像模拟器上限好像是64个寄存器
    
    initial begin
        data_o <= 0;
        
        if (LoadFib) begin
            if (Capacity < 60) begin
                $display("%m: capacity %d is not enough to hold the program", Capacity);
            end else begin
                // Load Fibonacci program
                // ori zero, zero, 0
                set(0, 32'b001101_00000_00000_0000_0000_0000_0000);
                // ori $t1, zero ,1
                set(4, 32'b001101_00000_01001_0000_0000_0000_0001);
                // ori $t2, zero, 1
                set(8, 32'b001101_00000_01010_0000_0000_0000_0001);
                // ori $t3, zero, 0	# Address
                set(12, 32'b001101_00000_01011_0000_0000_0000_0000);
                // ori $t4, zero, 8
                set(16, 32'b001101_00000_01100_0000_0000_0000_1000);
                // ori $t5, zero, 8
                set(20, 32'b001101_00000_01101_0000_0000_0000_1000);
                // ori $t6, zero, -1	
                set(24, 32'b001101_00000_01110_1111_1111_1111_1111);
                // sw $t1, 0($t3)
                set(28, 32'b101011_01011_01001_0000_0000_0000_0000);
                // sw $t2, 4($t3)	# imm = 4
                set(32, 32'b101011_01011_01010_0000_0000_0000_0100);
                // addu $t1, $t1, $t2
                set(36, 32'b000000_01001_01010_01001_00000_100001); 
                // addu $t2, $t1, $t2
                set(40, 32'b000000_01001_01010_01010_00000_100001); 
                // addu $t3, $t3, $t4	# t3 += 8
                set(44, 32'b000000_01011_01100_01011_00000_100001);
                // addu $t5, $t5, $t6
                set(48, 32'b000000_01101_01110_01101_00000_100001);
                // beq t5, zero, 1
                set(52, 32'b000100_01101_00000_0000_0000_0000_0001);
                // j 28 (address = 7) 
                set(56, 32'b000010_00_0000_0000_0000_0000_0000_0111);
            end
        end
    end
     
    always @(negedge clk) begin // 解决冒险与竞争问题，只使用一个
        if (mode_i == `RAM_WRITE_MODE)  // 1 为 写
            // Big endian (different from source)
            set(addr_i, data_i);
    end
    
    always @(*) begin
        data_o <= {memory[addr_i], memory[addr_i + 1], memory[addr_i + 2], memory[addr_i + 3]};
    end
    
    task automatic set(input [31:0] pos, input [31:0] data);
    begin
        {memory[pos], memory[pos + 1], memory[pos + 2], memory[pos + 3]} <= data;
    end
    endtask
    
endmodule 
