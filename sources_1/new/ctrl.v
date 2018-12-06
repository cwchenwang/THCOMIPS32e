`timescale 1ns / 1ps
`include "defines.vh"

module Ctrl(
    input wire             clk,     // For controlling FSM
    input wire             clk_50M,    // For VGA clock
	input wire				reset_btn,
	input wire             flash_btn,
	input wire[3:0]        touch_btn,

	input wire[31:0]       excepttype_i,
	input wire[`RegBus]    cp0_epc_i,
	
	input wire             stallreq_from_id,
    input wire             stallreq_from_ex,

    output wire            rst,    // Global reset
	output reg[`RegBus]    new_pc,
	output reg             flush,	
	output reg[4:0]        stall,
	
	// Flash
    output reg[22:1]        flash_addr,
    input wire[15:0]        flash_data,     // Data got from flash
    input wire              flash_data_ready,
    
    // From PC
    input wire[`InstAddrBus]    pc,
    input wire                  load_store_rom,
    
    // From MEM
    input wire                 ram_ce,
    input wire                 ram_we,
    input wire[`DataAddrBus]   ram_addr,
    input wire[3:0]            ram_sel,
    input wire[`DataBus]       ram_data,
    
    // To RamUartWrapper
    input wire[`DataBus]       ram_data_i,  // For VGA
    output reg                 ram_ce_o,
    output reg                 ram_we_o,
    output reg[`DataAddrBus]   ram_addr_o,
    output reg[3:0]            ram_sel_o,
    output reg[`DataBus]       ram_data_o,
    output reg                 ram_clk_o,   // For VGA
    
    // To BasicRamWrapper
    output reg                 rom_ce,
    output reg                 rom_we,
    output reg[`DataAddrBus]   rom_addr,
    output reg[3:0]            rom_sel,
    output reg[`DataBus]       rom_data,
    
    // VGA
    input wire[11:0]            vga_hdata_i,      // è¡?
    input wire[11:0]            vga_vdata_i,      // åˆ
    output wire[`DataBus]       vga_data_o,
    output wire[2:0]            vga_state_o
);

    localparam RUN = 0, LOAD_FLASH = 1, VGA_MODE_1 = 2, VGA_MODE_2 = 3, VGA_MODE_3 = 4;
    reg[2:0] state = RUN;
    
    reg[31:0] flash_data_buf = 0;
    reg load_flash_complete = 0;    // This affects CPU reset!!
    reg loaded_flash = 0;
    
    reg raw_rom_ce;
    reg raw_rom_we;
    reg[`DataAddrBus] raw_rom_addr;
    reg[`DataBus] raw_rom_data;
    reg[3:0] raw_rom_sel;
    
    wire[19:0] vga_tar_addr = 20'b0 + (vga_vdata_i * 800 + vga_hdata_i) >> 2;
    
    initial begin
        flash_addr <= 0;    
    end
    
    // Restart upon completing loading flash
    assign rst = reset_btn || load_flash_complete;  

    // Combinational part about stall, flush, new_pc.
    // This part is not affected by state.
	always @(*) begin
		if (reset_btn == `RstEnable) begin
			stall <= 5'b00000;
			flush <= 1'b0;
			new_pc <= `PC_INIT_ADDR;
		end else if (excepttype_i != `ZeroWord) begin
            stall <= 5'b00000;
			flush <= 1'b1;
			case (excepttype_i)
            32'h00000001: begin   //interrupt
                new_pc <= `PC_INT_ADDR;
            end
            32'h00000008: begin   //syscall
                new_pc <= `PC_SYSCALL_ADDR;
            end
            32'h0000000a: begin   //inst_invalid
                new_pc <= `PC_INSTINVALID_ADDR;
            end
            32'h0000000d: begin   //trap
                new_pc <= `PC_TRAP_ADDR;
            end
            32'h0000000c: begin   //ov
                new_pc <= `PC_OVERFLOW_ADDR;
            end
            32'h0000000e: begin   //eret
                new_pc <= cp0_epc_i;
            end
            default: begin
                new_pc <= `PC_INSTINVALID_ADDR; // Not used
            end
			endcase 	
		end else if (stallreq_from_ex == `Stop) begin
            // Stall EX, insert nop to MEM
            stall <= 5'b00111;
            flush <= 1'b0;		
            new_pc <= `PC_INIT_ADDR;    // Not used
		end else if (stallreq_from_id == `Stop) begin
            // Stall ID, insert nop to EX
			stall <= 5'b00011;	
			flush <= 1'b0;
			new_pc <= `PC_INIT_ADDR;     // Not used
		end else begin
			stall <= 5'b00000;
			flush <= 1'b0;
			new_pc <= `PC_INIT_ADDR;		
		end    //if
	end      //always
	
	// Combinational part about ROM
	// NOTE: this part is time critical!! If the variable "state" is of width 2 
	// and we put the following part to the next always block, we shall find errors
	// when executing "A" command (the highest byte is wrong)
    // Use most of RAM's controlling signals to ROM.
    always @(*) begin
        if (rst == `RstEnable) begin
            // Load the first instruction
            raw_rom_ce <= 1;
            raw_rom_we <= 0;
            raw_rom_addr <= `PC_INIT_ADDR;
            raw_rom_data <= 0;
            raw_rom_sel <= 4'b1111;
        end else begin
            raw_rom_data <= ram_data;
            if (load_store_rom) begin
                raw_rom_ce <= !ram_ce;  // Enable RAM, disable ROM; vice versa.
                raw_rom_we <= ram_we;   // Should suffice, since I did not change it. 
                raw_rom_addr <= ram_addr;
                raw_rom_sel <= ram_sel;                           
            end else begin
                raw_rom_ce <= 1;
                raw_rom_we <= 0;
                raw_rom_addr <= pc;
                raw_rom_sel <= 4'b1111;
            end
        end
    end
    
     // Final resolution of ROM signals
    always @(*) begin
        case (state)
        RUN: begin
            rom_addr <= raw_rom_addr;
            rom_ce <= raw_rom_ce;
            rom_we <= raw_rom_we;
            rom_data <= raw_rom_data;
            rom_sel <= raw_rom_sel;
        end
        LOAD_FLASH: begin   
            rom_addr <= {9'b0, flash_addr, 1'b0} - 4;
            rom_ce <= 1;
            rom_we <= loaded_flash && !flash_addr[1];
            rom_data <= flash_data_buf;
            rom_sel <= 4'b1111;  
        end    
        default: begin
            rom_ce <= 0;
            rom_we <= 0;
            rom_addr <= 0;
            rom_data <= 0;
            rom_sel <= 0;
        end    
        endcase
    end 
    
    // Combinational part about RAM controlling signals
    always @(*) begin
        ram_clk_o <= (state == RUN || state == LOAD_FLASH) ? clk : clk_50M;  
        
        if (rst == `RstEnable) begin
            ram_ce_o <= 0;
            ram_we_o <= 0;
            ram_addr_o <= 0;
            ram_data_o <= 0;
            ram_sel_o <= 4'b0000;
        end else if (state == RUN || state == LOAD_FLASH) begin
            ram_ce_o <= ram_ce;
            ram_we_o <= ram_we;
            ram_addr_o <= ram_addr;
            ram_data_o <= ram_data;
            ram_sel_o <= ram_sel;
        end else begin
            ram_ce_o <= 1;
            ram_we_o <= 0;
            ram_addr_o <= {10'b0, vga_tar_addr, 2'b0};
            ram_data_o <= 0;
            ram_sel_o <= 4'b1111;   
        end
    end
    
	// Sequential part which updates the FSM
    always @(posedge clk) begin
        case (state)
        RUN: begin 
            // reset_btn is directly connected to CPU
            load_flash_complete <= 0;   // Disable writing MEM
            if (!reset_btn) begin
                if (flash_btn) begin
                    state <= LOAD_FLASH;
                    flash_addr <= 0;
                    flash_data_buf <= 0;
                    loaded_flash <= 0;
                end else if (touch_btn[3]) begin
                    state <= VGA_MODE_1;                
                end else if (touch_btn[2]) begin
                    state <= VGA_MODE_2;
                end else if (touch_btn[1]) begin
                    state <= VGA_MODE_3;
                end
            end
        end
        LOAD_FLASH: begin
            if (reset_btn) begin
                // Reload flash
                flash_addr <= 0;
                flash_data_buf <= 0;
                load_flash_complete <= 0;
                loaded_flash <= 0;
            end else if (flash_addr[22]) begin  // 2M half words, 4M memory
                // Load flash done; during this cycle, the last word is written to instruction memory.
                state <= RUN;        
                load_flash_complete <= 1;
                flash_data_buf <= 0;    // Just for debug
            end else if (flash_data_ready) begin
                if (!loaded_flash) begin
                    flash_addr <= flash_addr + 1;                    
                    flash_data_buf <= {flash_data, flash_data_buf[31:16]};  // Shift right and prepend
                    loaded_flash <= 1;     // Avoid multiple reads in one flash_clk cycle
                end
            end else begin
                loaded_flash <= 0;            
            end
        end
        VGA_MODE_1: begin
            if (reset_btn) begin
                state <= RUN;
            end        
        end
        VGA_MODE_2: begin
            if (reset_btn) begin
                state <= RUN;
            end
        end
        VGA_MODE_3: begin
            if (reset_btn) begin
                state <= RUN;
            end
        end
        default: begin
            state <= RUN;
        end         
        endcase
    end
    
    // Combinational part controlling VGA
    assign vga_state_o = comp_vga_state(state);
    assign vga_data_o = ram_data_i;
    
    function automatic [2:0] comp_vga_state(input [2:0] my_state);
    begin
        case (my_state)
        VGA_MODE_1: comp_vga_state = 3'b001;
        VGA_MODE_2: comp_vga_state = 3'b010;
        VGA_MODE_3: comp_vga_state = 3'b100;
        default:    comp_vga_state = 3'b000;
        endcase
    end
    endfunction

endmodule