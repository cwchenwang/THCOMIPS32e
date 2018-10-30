`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Clarence Wang
// 
// Create Date: 2018/10/29 22:13:32
// Design Name: 
// Module Name: serial_port
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


module serial_port(
    input wire clk, rst,
    input wire[1:0] mode,
    output wire[1:0] output_mode,
    inout wire[7:0] data, //串口的输入输出
    input wire[7:0] data_in, 
    output reg [7:0] data_out,
    input wire data_ready, tbre, tsre,
    output wire out_tsre,
    output wire out_tbre,
    output reg wrn, rdn,
    output reg fucku,
    output reg ram1_en, ram1_oe, ram1_rw //使能，写使能，读使能
    );

reg[10:0] counter;
reg[3:0] cur_state;
reg[7:0] local_data;

assign out_tsre = tsre;
assign out_tbre = tbre;
assign output_mode =  mode;
assign data = local_data;
//assign data = (cur_state != 4'b0000 && mode == 2'b00) ? data_in : 0;

initial begin
    counter = 0;
    cur_state = 4'b0000;
    local_data = 8'b00000000;
    end 
 
always @(posedge clk or posedge rst) begin
    if(rst) begin
        cur_state = 4'b0000;
    end
    else if(counter == 1023) begin
        if(mode == 2'b00) begin
            case(cur_state)
                4'b0000: begin
                    wrn = 1;
                    ram1_en = 1;
                    ram1_rw = 1;
                    ram1_oe = 1;
                    cur_state = 4'b0001;
                end
                4'b0001: begin
                    wrn = 0;
                    local_data = data_in;
                    cur_state = 4'b0010;
                end
                4'b0010: begin
                    wrn = 1;
                    cur_state = 4'b0011;
                end
                4'b0011: begin
                    if(tbre == 1) begin
                        cur_state = 4'b0100;
                    end
                end
                4'b0100: begin
                    if(tsre == 1) begin
                        cur_state = 4'b0000;
                        fucku = 1;
                    end
                end
                default: begin
                    cur_state = 4'b0000;
                end
            endcase
        end
        else if(mode == 2'b01) begin
            case(cur_state)
                4'b0000: begin
                    ram1_en = 1;
                    ram1_rw = 1;
                    ram1_oe = 1;
                    cur_state = 4'b0001;
                end
                4'b0001: begin
                    local_data = 8'bzzzzzzzz;
                    rdn = 1;
                    cur_state = 4'b0010;
                end
                4'b0010: begin
                    if(data_ready == 0) begin
                        cur_state = 4'b0001;
                    end
                    else begin
                        rdn = 0;
                        cur_state = 4'b0011;
                    end
                end
                4'b0011: begin
                    data_out = data;
                    cur_state = 4'b0000;
                end
                default: begin
                    cur_state = 4'b0000;
                end
            endcase
        end
        counter = 0;
    end
    else if(counter < 1024) begin
        counter = counter + 1;
    end
end

endmodule
