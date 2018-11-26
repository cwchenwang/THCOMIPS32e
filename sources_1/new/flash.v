`include "defines.v"

module flash(
    input wire rst,
    input wire clk,
    output wire flash_ce,
    output wire flash_we,
    output wire flash_oe,
    output wire flash_rp,
    output wire flash_byte,
    output wire flash_vpen,

    input wire[22:1] addr,
    output wire[15:0] data_out,
    output wire[22:1] flash_addr,
    inout wire[15:0] flash_data
);

    // 应该由网站平台实现
    /*reg[15:0] data_flash[0:4194303];
    initial $readmemh ("flash.data", data_flash);
    assign flash_data = { data_flash[addr][7:0], data_flash[addr][15:8] };*/

    assign flash_rp = 1'b1;
    assign flash_ce = 1'b0;
    assign flash_vpen = 1'b1;
    assign flash_byte = 1'b1;

    reg[2:0] cur_state = 3'b000;

    always @(posedge clk or posedge rst) begin
		if (reset) begin
			flash_oe <= 1'b1;
			flash_we <= 1'b1;
			cur_state <= 3'b000;
			flash_data <= 16'bz;
            //ctl_read_last <= ctl_read;
        end
		else begin
			case(cur_state)
				3'b000:begin
                    flash_we <= 1'b0;
                    cur_state <= 3'b001;
                    //if (ctl_read /= ctl_read_last) then
                    //ctl_read_last <= ctl_read;
				end

                3'b001 begin
					flash_data <= 4'h00FF;
					cur_state <= 3'b010;
                end

                3'b010 begin
					flash_we <= 1'b1;
					cur_state <= 3'b011;
                end

                3'b011 begin
					flash_oe <= 1'b0;
					flash_addr <= addr;
					flash_data <= 16'bz;
					cur_state <= 3'b100;
                end

                3'b100 begin
					data_out <= flash_data;
					state <= 3'b101;        // 即执行default
                end
					
				default begin
					flash_oe <= 1'b1;
					flash_we <= 1'b1;
					flash_data <= 16'bz;
					state <= 3'b000;
                end

			endcase

		end

	end

endmodule