// Module RAMWrapper that adaptas a SRAM module as declared in thinpad_top.v 
// to a RAM / ROM module.
// Author: LYL
// Created on: 2018/11/24

`timescale 1ns / 1ps
`include "defines.vh"

module RAMWrapper(
    input wire rst,

	input wire clk,
	
	// From MEM
    input wire ce_i,
    input wire we_i,
    input wire[`DataAddrBus] addr_i,
    input wire[3:0] sel_i,
    input wire[`DataBus] data_i,

    input wire[`AluOpBus]        aluop_i,
    input wire[`RegBus]          reg2_i,
    
    // To MEM
    output reg[`DataBus] data_o,
    
    // Adaptee
    inout wire[`InstBus] ram_data,  // RAM数据
    output reg[19:0] ram_addr,      // RAM地址
    output reg[3:0] ram_be_n,       // RAM字节使能，低有效。如果不使用字节使能，请保持为0
    output reg ram_ce_n,            // RAM片选，低有效
    output reg ram_oe_n,            // RAM读使能，低有效
    output reg ram_we_n,            // RAM写使能，低有效

    // for Base Ram
    input wire					 tbre,
	input wire					 tsre,
	input wire					 data_ready,
	inout wire[`ByteWidth]		 base_ram_data,
	output reg 				     base_ram_ce_n,
    output reg 		       		 base_ram_oe_n,
    output reg					 base_ram_we_n,
	output reg     				 rdn,
	output reg  				 wrn
);

    // for Base Ram
    reg write_prep;
	reg read_prep;
	reg[`RegBus] data_o_temp;
	reg wdata_flag = 1'b0;
	reg[`ByteWidth] final_base_ram_data;
    
    assign base_ram_data = final_base_ram_data;

    //两种情况对data_o_temp的最终赋值
	always @ (data_o_temp or base_ram_data) begin
		if(wdata_flag == 1'b0) begin
			data_o <= data_o_temp;
		end else if(wdata_flag == 1'b1) begin
			data_o <= base_ram_data;
			wdata_flag <= 1'b0;
		end
	end	
	
	// ram_we control
	always @ (posedge rst or posedge clk) begin
		if(rst == `RstEnable) begin
			base_ram_we_n <= 1'b1;
		end else begin
			base_ram_we_n <= 1'b1;
		end
	end

	// wrn control
	always @ (posedge rst or posedge clk or write_prep) begin
		if(rst == `RstEnable) begin
			wrn <= 1'b1;
		end else if(write_prep == `ChipEnable) begin
			wrn <= clk;
		end else begin
			wrn <= 1'b1;
		end
	end

	// rdn control
	always @ (posedge rst or posedge clk or read_prep) begin
		if(rst == `RstEnable) begin
			rdn <= 1'b1;
		end else if(read_prep == `ChipEnable) begin
			rdn <= clk;
		end else begin
			rdn <= 1'b1;
		end
	end

    always @ (*) begin
        case (aluop_i)
            `EXE_LB_OP:	begin
                // 读串口
                if(addr_i == 32'hBFD003F8) begin
                    base_ram_ce_n <= 1'b1;
                    base_ram_oe_n <= 1'b1;
                    final_base_ram_data <= 8'bz;
                    read_prep <= `ChipEnable;
                    write_prep <= `ChipDisable;

                    wdata_flag <= 1'b1;
                    
                //读串口标志位
                end else if(addr_i == 32'hBFD003FC) begin
                    base_ram_ce_n <= 1'b0;
                    base_ram_oe_n <= 1'b1;
                    read_prep <= `ChipDisable;
                    write_prep <= `ChipDisable;

                    if(data_ready == 1'b1 && tbre == 1'b1 && tsre == 1'b1) begin
                        // 串口可读可写
                        data_o_temp <= 8'b00000011;
                    end else if (tbre == 1'b1 && tsre == 1'b1) begin
                        // 串口只写
                        data_o_temp <= 8'b00000001;
                    end else if(data_ready == 1'b1) begin
                        // 串口只读
                        data_o_temp <= 8'b00000010;
                    end else begin
                        // 串口不读不写
                        data_o_temp <= 8'b00000000;
                    end
            end

            `EXE_SB_OP: begin
                // 写串口
                if(mem_addr_i == 8'hBFD003F8) begin
                    base_ram_ce_n <= 1'b1;
                    base_ram_oe_n <= 1'b1;
                    final_base_ram_data <= reg2_i[7:0];
                    read_prep <= `ChipDisable;
                    write_prep <= `ChipEnable;
                end
            end
    end

    // Tri-state
    assign ram_data = (ce_i == `ChipEnable && we_i == `WriteEnable) ? data_i : {`DataWidth{1'bz}};
    
    // Read data_o_temp from ram_data
    always @(*) begin
        if (ce_i == `ChipEnable && we_i == `WriteDisable) 
            data_o_temp <= ram_data;
        else
            data_o_temp <= 0;
    end
   
    always @ (*) begin
        ram_be_n <= 0;
        ram_addr <= addr_i[21:2];   // Only use low 20 bits, index by 32-bit word
        if (ce_i == `ChipDisable) begin
            ram_ce_n <= 1;
            ram_oe_n <= 1;
            ram_we_n <= 1;
//            ram_be_n <= 0;
        end else begin
            ram_ce_n <= 0;
            if (we_i == `WriteEnable) begin
                ram_oe_n <= 1;
                ram_we_n <= !clk;   // LOW at the first half cycle, HIGH for the rest
                ram_be_n <= ~sel_i;  // Happily, their meanings are almost the same
            end else begin  
                ram_oe_n <= 0;
                ram_we_n <= 1;
//                ram_be_n <= 0;
            end
        end
    end 
    
endmodule