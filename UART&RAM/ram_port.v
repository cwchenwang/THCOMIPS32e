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
    inout wire [31:0] base_ram_data,
    output reg [19:0] base_ram_addr,
    output reg [15:0] leds,
    output reg wrn, rdn,
    output reg base_ram_en, base_ram_oe, base_ram_rw,
    input wire data_ready, tbre, tsre,
    input wire clk, rst,
    output wire [3:0] state
    );

reg[3:0] cur_state = 4'b0000;
reg[31:0] local_data = 32'b0;
reg[31:0] read_data = 32'b0;
reg[19:0] local_addr = 20'b0;
reg[31:0] final_data = 32'b0;

assign state = cur_state;
assign base_ram_data = final_data; 
   
always @(posedge clk or posedge rst) begin
    if(rst) begin
        cur_state = 4'b0000;
        local_data = 32'b0;
        local_addr = 20'b0;
        final_data = 32'b0;
        base_ram_addr = 20'b0;
        base_ram_en = 1'b1;
        base_ram_rw = 1'b1;
        base_ram_oe = 1'b1;
        leds = 16'b0;
        rdn = 1'b1;
        wrn = 1'b1;
    end
    else begin
            case(cur_state)
                4'b0000: begin                                  //从串口接收数据开始
                    rdn = 1'b1;
                    final_data[7:0] = 8'bz;
                    cur_state = 4'b0001;
                end
                
                4'b0001: begin
                    if(data_ready == 1'b0) begin
                        cur_state = 4'b0000;
                    end
                    else if(data_ready == 1'b1) begin
                        rdn = 1'b0;
                        cur_state = 4'b0010;
                    end
                end
                
                4'b0010: begin
                    local_data[7:0] = base_ram_data[7:0];
                    leds = local_data;
                    cur_state = 4'b0011;
                end                                             //写串口完成
                
                4'b0011: begin                                  //写RAM开始
                    rdn = 1'b1;
                    base_ram_addr = 32'b0;
                    base_ram_en = 1'b0;
                    base_ram_rw = 1'b0;
                    final_data = local_data;
                    cur_state = 4'b0100;
                end
                
                4'b0100: begin                        
                    base_ram_rw = 1'b1;
                    base_ram_en = 1'b1;
                    cur_state = 4'b0101;
                end
                
                4'b0101: begin                                      //读RAM开始
                    base_ram_addr = 32'b0;
                    base_ram_en = 1'b0;
                    base_ram_oe = 1'b0;
                    read_data = base_ram_data;
                    cur_state = 4'b0110;                            //读RAM结束
                end
                
                4'b0110: begin                                      //将数据写给调试精灵
                    wrn = 1'b1;
                    base_ram_en = 1'b1;
                    base_ram_oe = 1'b1;
                    final_data = read_data;
                    wrn = 1'b0;
                    cur_state = 4'b0111;
                end                                        
                
                4'b0111: begin          
                    wrn = 1'b1;
                    cur_state = 4'b1000;
                end                                         
                
                4'b1000: begin        
                    if(tbre == 1'b1) begin
                        cur_state = 4'b1001;
                    end
                end
                
                4'b1001: begin
                    if(tsre == 1'b1) begin
                        cur_state = 4'b1010;
                    end
                end
                
                4'b1010: begin
                    leds = read_data[15:0];
                end
                
                default: begin
                    cur_state = 4'b0000;
                end
                
            endcase                                             
    end
end

endmodule