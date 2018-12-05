`timescale 1ns / 1ps
//
// WIDTH: bits in register hdata & vdata
// HSIZE: horizontal size of visible field 
// HFP: horizontal front of pulse
// HSP: horizontal stop of pulse
// HMAX: horizontal max size of value
// VSIZE: vertical size of visible field 
// VFP: vertical front of pulse
// VSP: vertical stop of pulse
// VMAX: vertical max size of value
// HSPP: horizontal synchro pulse polarity (0 - negative, 1 - positive)
// VSPP: vertical synchro pulse polarity (0 - negative, 1 - positive)
//
module image_vga
#(parameter WIDTH = 0, HSIZE = 0, HFP = 0, HSP = 0, HMAX = 0, VSIZE = 0, VFP = 0, VSP = 0, VMAX = 0, HSPP = 0, VSPP = 0)
(
    input wire clk,
    output reg [WIDTH - 1:0] hdata,
    output reg [WIDTH - 1:0] vdata,
    output wire hsync,
    output wire vsync,
    output wire data_enable,
    
    output wire[3:0] red,
    output wire[3:0] green,
    output wire[2:0] blue,

    input wire[31:0] ram_data
);

reg[3:0] red_temp;
reg[3:0] green_temp;
reg[3:0] blue_temp;

assign red = red_temp;
assign green = green_temp;
assign blue = blue_temp;

// init
initial begin
    hdata <= 0;
    vdata <= 0;
    red_temp <= 0;
    green_temp <= 0;
    blue_temp <= 0;
    //addr <= 19'b0;
end

// hdata
always @ (posedge clk)
begin
    if (hdata == (HMAX - 1))
        hdata <= 0;
    else
        hdata <= hdata + 1;
end

// vdata
always @ (posedge clk)
begin
    if (hdata == (HMAX - 1)) 
    begin
        if (vdata == (VMAX - 1))
            vdata <= 0;
        else
            vdata <= vdata + 1;
    end
end

always @ (*) begin
    if((hdata * 800 + vdata) & 2'b11 == 2'b00) begin
        red_temp <= ram_data[31:29];
        green_temp <= ram_data[28:26];
        blue_temp <= ram_data[25:24];
    end else if((hdata * 800 + vdata) & 2'b11 == 2'b01) begin
        red_temp <= ram_data[23:21];
        green_temp <= ram_data[20:18];
        blue_temp <= ram_data[17:16];
    end else if((hdata * 800 + vdata) & 2'b11 == 2'b10) begin
        red_temp <= ram_data[15:13];
        green_temp <= ram_data[12:10];
        blue_temp <= ram_data[9:8];
    end else if((hdata * 800 + vdata) & 2'b11 == 2'b11) begin
        red_temp <= ram_data[7:5];
        green_temp <= ram_data[4:2];
        blue_temp <= ram_data[1:0];
    end
end

// hsync & vsync & blank
assign hsync = ((hdata >= HFP) && (hdata < HSP)) ? HSPP : !HSPP;
assign vsync = ((vdata >= VFP) && (vdata < VSP)) ? VSPP : !VSPP;
assign data_enable = ((hdata < HSIZE) & (vdata < VSIZE));

endmodule