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
reg[10:0] target_center_v;
reg[10:0] target_center_h;

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
    target_center_v <= 11'b0 + 500;
    target_center_h <= 11'b0 + 620;
    //addr <= 19'b0;
end

assign red = red_temp;
assign green = green_temp;
assign blue = blue_temp;

always @ (*) begin
    red_temp <= (((vdata == people_center_v && hdata >= people_center_h - 25 && hdata <= people_center_h + 25) || (hdata == people_center_h && vdata >= people_center_v - 25 && vdata <= people_center_v + 25) || (vdata == people_center_v + 25 && hdata >= people_center_h - 15 && hdata <= people_center_h + 15) || (hdata == people_center_h - 15 && vdata >= people_center_v + 25 && vdata <= people_center_v + 50) || (hdata == people_center_h + 15 && vdata >= people_center_v + 25 && vdata <= people_center_v + 50) || (vdata >= people_center_v - 50 && vdata <= people_center_v - 25 && hdata >= people_center_h - 10 && hdata <= people_center_h + 10)) || (vdata >= box_center_v - 50 && vdata <= box_center_v + 50 && hdata <= box_center_h + 40 && hdata >= box_center_h - 40)) ? 3'b111 : 0;
    blue_temp <= (hdata >= target_center_h - 40 && hdata <= target_center_h + 40 && vdata >= target_center_v - 50 && vdata <= target_center_v + 50 ) ? 3'b011:0;
    green_temp <= (vdata >= 350 && hdata >= 530 && hdata <= 580) || (vdata <= 350 && hdata >= 205 && hdata <= 255) ? 3'b011:0;
end

always @ (posedge clk_btn or posedge rst_btn) begin
    if(rst_btn) begin
        people_center_v <= 11'b0 + 300;
        people_center_h <= 11'b0 + 100;
        box_center_v <= 11'b0 + 300;
        box_center_h <= 11'b0 + 165;
    end else begin
    if(direction == 4'b1000) begin          // up
        if(people_center_h == box_center_h && box_center_v == people_center_v - 100 && (box_center_v - 50 - 100 < 75 || (box_center_v - 350 == 50 && people_center_h == 230))) begin
        
        end else if(people_center_v - 350 <= 50 && people_center_h >= 205 && people_center_h <= 255) begin
        
        end else if(people_center_v - 50 - 100 >= 75) begin
            people_center_v <= people_center_v - 100;
            if(box_center_v == people_center_v - 100 && people_center_h == box_center_h) begin
                if(box_center_v - 50 - 100 >= 75 && 350 - box_center_v >= 50) begin
                    box_center_v <= box_center_v - 100;
                end
            end
        end
    end else if(direction == 4'b0100) begin  //down
        if(people_center_h == box_center_h && box_center_v == people_center_v + 100 && (box_center_v + 50 + 100 > 599 || (350 - box_center_v == 50 && people_center_h == 555))) begin
        
        end else if(350 - people_center_v <= 50 && people_center_h >= 530 && people_center_h <= 580) begin
        
        end else if(people_center_v + 50+ 100 <= 599) begin
            people_center_v <= people_center_v + 100;
            if(box_center_v == people_center_v + 100 && people_center_h == box_center_h) begin
                if(box_center_v + 50 + 100 <= 599 && box_center_v - 350 >= 50) begin
                    box_center_v <= box_center_v + 100;
                end
            end
        end
    end else if(direction == 4'b0010) begin  //left
        if(people_center_v == box_center_v &&  box_center_h == people_center_h - 65 && (box_center_h - 37 - 65 < 20 || (box_center_h - 580 == 40 && box_center_v > 350) || (box_center_h - 255 == 40 && box_center_v < 350))) begin
        
        end else if((people_center_h - 580 <= 40 && people_center_v >= 350) || (people_center_h - 255 <= 40 && people_center_v <= 350)) begin
        
        end else if(people_center_h - 25 - 65 >= 20) begin
            people_center_h <= people_center_h - 65;
            if(box_center_h == people_center_h - 65 && people_center_v == box_center_v) begin
                if(box_center_h - 37 - 65 >= 20 && box_center_h - 580 >= 40 && box_center_h - 255 >= 40) begin
                    box_center_h <= box_center_h - 65;
                end
            end
        end
    end else if(direction == 4'b0001) begin  //right
        if(people_center_v == box_center_v && box_center_h == people_center_h + 65 && (box_center_h + 37 + 65 > 799 || (530 - box_center_h == 40 && box_center_v > 350) || (205 - box_center_h == 40 && box_center_v < 350))) begin
        
        end else if((530 - people_center_h <= 40 && people_center_v >= 350) || (205 - people_center_h <= 40 && people_center_v <= 350)) begin
        
        end else if(people_center_h + 25 + 65 <= 799) begin
            people_center_h <= people_center_h + 65;
            if(box_center_h == people_center_h + 65 && people_center_v == box_center_v) begin
                if(box_center_h + 37 + 65 <= 799 && 530 - box_center_h >= 40 && 205 - box_center_h >= 40) begin
                    box_center_h <= box_center_h + 65;
                end
            end
        end
    end
    end
  
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

// hsync & vsync & blank
assign hsync = ((hdata >= HFP) && (hdata < HSP)) ? HSPP : !HSPP;
assign vsync = ((vdata >= VFP) && (vdata < VSP)) ? VSPP : !VSPP;
assign data_enable = ((hdata < HSIZE) & (vdata < VSIZE));

endmodule