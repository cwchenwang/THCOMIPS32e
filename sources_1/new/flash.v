`timescale 1ns / 1ps

module Flash #(reverse = 1)(
    input wire rst,
    input wire clk,
    
    input wire[22:1] addr,
    output wire[15:0] data_out, //data got from flash
    output wire data_ready,
    
    output wire flash_ce,
    output reg flash_we,
    output reg flash_oe,
    output wire flash_rp,
    output wire flash_byte,
    output wire flash_vpen,
    output reg[22:1] flash_addr,
    inout wire[15:0] flash_data
);

//    // 应该由网站平台实现
//    reg[15:0] data_flash[0:4194303];
//    initial $readmemh ("flash.data", data_flash);
//    assign flash_data = { data_flash[addr][7:0], data_flash[addr][15:8] };
    reg[15:0] final_data;
//    reg ctl_read_last;

    assign flash_rp = 1'b1;
    assign flash_ce = 1'b0;
    assign flash_vpen = 1'b1;
    assign flash_byte = 1'b1;
    assign flash_data = final_data;
    assign data_out = reverse ? {final_data[7:0], final_data[15:8]} : final_data;

    reg[2:0] cur_state = 3'b000;
    assign data_ready = cur_state == 3'b100;

    always @(posedge clk or posedge rst) begin
		if (rst) begin
			flash_oe <= 1'b1;
			flash_we <= 1'b1;
			cur_state <= 3'b000;
			final_data <= 16'bz;
        end
		else begin
			case(cur_state)
				3'b000:begin
                    flash_we <= 1'b0;
                    cur_state <= 3'b001;
				end

                3'b001:begin
					final_data <= 16'b0000000011111111;
					cur_state <= 3'b010;
                end

                3'b010:begin
					flash_we <= 1'b1;
					cur_state <= 3'b011;
                end

                3'b011:begin
					flash_oe <= 1'b0;
					flash_addr <= addr;
					final_data <= 16'bz;
					cur_state <= 3'b100;
                end

                3'b100:begin
					cur_state <= 3'b101;        // 即执行default
                end
					
				default begin
					flash_oe <= 1'b1;
					flash_we <= 1'b1;
					final_data <= 16'bz;
					cur_state <= 3'b000;
                end
			endcase
		end
	end

endmodule