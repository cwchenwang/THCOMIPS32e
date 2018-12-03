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
module vga_game
#(parameter WIDTH = 0, HSIZE = 0, HFP = 0, HSP = 0, HMAX = 0, VSIZE = 0, VFP = 0, VSP = 0, VMAX = 0, HSPP = 0, VSPP = 0)
(
    input wire clk,
    //output reg [18:0] addr,
    output reg [WIDTH - 1:0] hdata,
    output reg [WIDTH - 1:0] vdata,
    output wire hsync,
    output wire vsync,
    output wire data_enable,
    
    output wire[3:0] red,
    output wire[3:0] green,
    output wire[2:0] blue,

   input wire rst_btn,
   input wire clk_btn,
   input wire[3:0] direction
);

reg[3:0] red_temp;
reg[3:0] green_temp;
reg[3:0] blue_temp;

reg[10:0] people_center_v;
reg[10:0] people_center_h;
reg[10:0] box_center_v;
reg[10:0] box_center_h;

// init
initial begin
    hdata <= 0;
    vdata <= 0;
    red_temp <= 0;
    green_temp <= 0;
    blue_temp <= 0;
    people_center_v <= 11'b0 + 300;
    people_center_h <= 11'b0 + 100;
    box_center_v <= 11'b0 + 300;
    box_center_h <= 11'b0 + 165;
    //addr <= 19'b0;
end

/*assign red = (((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || ((hdata >= 595 && hdata <= 605) && (vdata >= 100 && vdata <= 500)) || ((hdata >= 195 && hdata <= 205) && (vdata >= 100 && vdata <= 500)) || (((hdata >= 45 && hdata <= 55) || (hdata >= 745 && hdata <= 755)) && (vdata >= 100 && vdata <= 500)) || (((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505)) && ((hdata >= 50 && hdata <= 200) ||(hdata >= 600 && hdata <= 750)))) ? 3'b111 : 0;
assign green = 0;
assign blue = 0;*/

assign red = red_temp;
assign green = green_temp;
assign blue = blue_temp;

always @ (*) begin
    //if(rst_btn) begin
        red_temp <= ((vdata == people_center_v && hdata >= people_center_h - 25 && hdata <= people_center_h + 25) || (hdata == people_center_h && vdata >= people_center_v - 25 && vdata <= people_center_v + 25) || (vdata == people_center_v + 25 && hdata >= people_center_h - 15 && hdata <= people_center_h + 15) || (hdata == people_center_h - 15 && vdata >= people_center_v + 25 && vdata <= people_center_v + 50) || (hdata == people_center_h + 15 && vdata >= people_center_v + 25 && vdata <= people_center_v + 50) || (vdata >= people_center_v - 50 && vdata <= people_center_v - 25 && hdata >= people_center_h - 10 && hdata <= people_center_h + 10)) || (vdata >= box_center_v - 50 && vdata <= box_center_v + 50 && hdata <= box_center_h + 40 && hdata >= box_center_h - 40) ? 3'b111 : 0;
        blue_temp <= 3'b000;
        green_temp <= 3'b000;
    //end
end

always @ (posedge clk_btn) begin
    if(direction == 4'b1000) begin          // up
        people_center_v <= people_center_v - 100;
        box_center_v <= box_center_v - 100;
    end else if(direction == 4'b0100) begin  //down
        people_center_v <= people_center_v + 100;
        box_center_v <= box_center_v + 100;
    end else if(direction == 4'b0010) begin  //left
        people_center_h <= people_center_h - 65;
        box_center_h <= box_center_h - 65;
    end else if(direction == 4'b0001) begin  //right
        people_center_h <= people_center_h + 65;
        box_center_h <= box_center_h + 65;
    end
  
end

//always @ (posedge right_move) begin
//    people_center_h <= people_center_h + 65;
//    box_center_h <= box_center_h + 65;
//end

//always @ (posedge left_move) begin
//    people_center_h <= people_center_h - 65;
//    box_center_h <= box_center_h - 65;
//end

//always @ (posedge down_move) begin
//    people_center_v <= people_center_v + 100;
//    box_center_v <= box_center_v + 100;
//end

//always @ (posedge up_move) begin
//    people_center_v <= people_center_v - 100;
//    box_center_v <= box_center_v - 100;
//end

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

// 待添加由地址或寄存器得到数据
/*always @ (posedge clk) begin
    if (hdata == 0 & vdata == 0) begin
        addr <= 19'b0; 
    end else begin
        if (data_enable) begin
            addr <= addr + 1;
        end
    end
end*/

// hsync & vsync & blank
assign hsync = ((hdata >= HFP) && (hdata < HSP)) ? HSPP : !HSPP;
assign vsync = ((vdata >= VFP) && (vdata < VSP)) ? VSPP : !VSPP;
assign data_enable = ((hdata < HSIZE) & (vdata < VSIZE));

endmodule