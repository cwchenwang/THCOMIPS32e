`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/30 19:25:05
// Design Name: zdc
// Module Name: ram_port
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

module ram_port(
    input wire[19:0] addr,
    inout wire [31:0] base_ram_data,
    output reg [19:0] base_ram_addr,
    output reg base_ram_en, base_ram_oe, base_ram_rw,
    input wire clk, rst,
    output wire[31:0] data_out
    );

reg[31:0] read_data = 32'b0;

assign data_out = {read_data[7:0], read_data[15:8], read_data[23:16], read_data[31:24]};
//assign data_out = (flag == 1'b1) ? {read_data[7:0], read_data[15:8]} : {read_data[23:16], read_data[31:24]};

always @(posedge clk or posedge rst) begin
    if(rst) begin
        base_ram_addr = 20'b0;
        base_ram_en = 1'b1;
        base_ram_rw = 1'b1;
        base_ram_oe = 1'b1;
    end
    else begin                             //è¯»RAMå¼?å§?
        base_ram_en = 1'b0;
        base_ram_oe = 1'b0;
        base_ram_rw = 1'b1;
        base_ram_addr = addr;
        read_data = base_ram_data;    
        //base_ram_addr = base_ram_addr + 1;            
end
end

endmodule