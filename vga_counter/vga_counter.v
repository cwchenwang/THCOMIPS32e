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
module vga
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
   input wire clk_btn
);

reg[3:0] first;
reg[3:0] second;
reg[3:0] red_temp;
reg[3:0] green_temp;
reg[3:0] blue_temp;

// init
initial begin
    hdata <= 0;
    vdata <= 0;
    first <= 0;
    second <= 0;
    red_temp <= 0;
    green_temp <= 0;
    blue_temp <= 0;
    //addr <= 19'b0;
end

/*assign red = (((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || ((hdata >= 595 && hdata <= 605) && (vdata >= 100 && vdata <= 500)) || ((hdata >= 195 && hdata <= 205) && (vdata >= 100 && vdata <= 500)) || (((hdata >= 45 && hdata <= 55) || (hdata >= 745 && hdata <= 755)) && (vdata >= 100 && vdata <= 500)) || (((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505)) && ((hdata >= 50 && hdata <= 200) ||(hdata >= 600 && hdata <= 750)))) ? 3'b111 : 0;
assign green = 0;
assign blue = 0;*/

assign red = red_temp;
assign green = green_temp;
assign blue = blue_temp;

always @ (*) begin
    if(rst_btn) begin
        red_temp <= (((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || ((hdata >= 595 && hdata <= 605) && (vdata >= 100 && vdata <= 500)) || ((hdata >= 195 && hdata <= 205) && (vdata >= 100 && vdata <= 500)) || (((hdata >= 45 && hdata <= 55) || (hdata >= 745 && hdata <= 755)) && (vdata >= 100 && vdata <= 500)) || (((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505)) && ((hdata >= 50 && hdata <= 200) ||(hdata >= 600 && hdata <= 750)))) ? 3'b111 : 0;
        green_temp <= 0;
        blue_temp <= 0;
    end else begin
        if(hdata >= 400) begin
            if(first == 0) begin
                red_temp <= (((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || ((hdata >= 595 && hdata <= 605) && (vdata >= 100 && vdata <= 500)) || (((hdata >= 745 && hdata <= 755)) && (vdata >= 100 && vdata <= 500)) || (((vdata >= 95 && vdata <= 105) || (vdata >= 495 && vdata <= 505)) && ((hdata >= 600 && hdata <= 750)))) ? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(first == 1) begin
                red_temp <= (((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || ((hdata >= 595 && hdata <= 605) && (vdata >= 100 && vdata <= 500))) ? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(first == 2) begin
                red_temp <= ((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || (((hdata >= 595 && hdata <= 755) && ((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505))) || (hdata >= 745 && hdata <= 755 && vdata >= 95 && vdata <= 305) || (hdata >= 595 && hdata <= 605 && vdata >= 295 && vdata <= 505))? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(first == 3) begin
                red_temp <= ((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || (((hdata >= 595 && hdata <= 755) && ((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505))) || (hdata >= 745 && hdata <= 755 && vdata >= 95 && vdata <= 305) || (hdata >= 745 && hdata <= 755 && vdata >= 295 && vdata <= 505))? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(first == 4) begin
                red_temp <= ((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || ((vdata >= 95 && vdata <= 305 && ((hdata >= 595 && hdata <= 605) || (hdata >= 745 && hdata <= 755))) || (hdata >= 595 && hdata <= 755 && vdata >= 295 && vdata <= 305) || (hdata >= 745 && hdata <= 755 && vdata >= 295 && vdata <= 505)) ? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(first == 5) begin
                red_temp <= ((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || (((hdata >= 595 && hdata <= 755) && ((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505))) || (hdata >= 595 && hdata <= 605 && vdata >= 95 && vdata <= 305) || (hdata >= 745 && hdata <= 755 && vdata >= 295 && vdata <= 505))? 3'b111 : 0;
                green_temp <= 0;
                blue_temp  <=0;
            end else if(first == 6) begin
                red_temp <= ((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || (((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || ((hdata >= 595 && hdata <= 605) && (vdata >= 100 && vdata <= 500)) || (hdata >= 745 && hdata <= 755 && vdata >= 295 && vdata <= 505) || (((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505)) && ((hdata >= 600 && hdata <= 750)))) ? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(first == 7) begin
                red_temp <= ((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || (hdata >= 745 && hdata <= 755 && vdata >= 95 && vdata <= 505) || (hdata >= 595 && hdata <= 755 && vdata >= 95 && vdata <= 105) ? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(first == 8) begin
                red_temp <= ((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || (((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || ((hdata >= 595 && hdata <= 605) && (vdata >= 100 && vdata <= 500)) || (((hdata >= 745 && hdata <= 755)) && (vdata >= 100 && vdata <= 500)) || (((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505)) && ((hdata >= 600 && hdata <= 750)))) ? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(first == 9) begin
                red_temp <= ((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || (((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || ((hdata >= 595 && hdata <= 605) && (vdata >= 100 && vdata <= 305)) || (((hdata >= 745 && hdata <= 755)) && (vdata >= 100 && vdata <= 500)) || (((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505)) && ((hdata >= 600 && hdata <= 750)))) ? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end
        end else begin
            if(second == 0) begin
                red_temp <= (((hdata >= 195 && hdata <= 205) && (vdata >= 100 && vdata <= 500)) || (((hdata >= 45 && hdata <= 55)) && (vdata >= 100 && vdata <= 500)) || (((vdata >= 95 && vdata <= 105) || (vdata >= 495 && vdata <= 505)) && ((hdata >= 50 && hdata <= 200)))) ? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(second == 1) begin
                red_temp <= (((hdata >= 195 && hdata <= 205) && (vdata >= 100 && vdata <= 500))) ? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(second == 2) begin
                red_temp <= (((hdata >= 50 && hdata <= 200) && ((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505))) || (hdata >= 195 && hdata <= 205 && vdata >= 95 && vdata <= 305) || (hdata >= 45 && hdata <= 55 && vdata >= 295 && vdata <= 505))? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(second == 3) begin
                red_temp <= (((hdata >= 50 && hdata <= 200) && ((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505))) || (hdata >= 195 && hdata <= 205 && vdata >= 95 && vdata <= 305) || (hdata >= 195 && hdata <= 205 && vdata >= 295 && vdata <= 505))? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(second == 4) begin
                red_temp <= ((vdata >= 95 && vdata <= 305 && ((hdata >= 45 && hdata <= 55) || (hdata >= 195 && hdata <= 205))) || (hdata >= 50 && hdata <= 200 && vdata >= 295 && vdata <= 305) || (hdata >= 195 && hdata <= 205 && vdata >= 295 && vdata <= 505)) ? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(second == 5) begin
                red_temp <= (((hdata >= 50 && hdata <= 200) && ((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505))) || (hdata >= 45 && hdata <= 55 && vdata >= 95 && vdata <= 305) || (hdata >= 195 && hdata <= 205 && vdata >= 295 && vdata <= 505))? 3'b111 : 0;
                green_temp <= 0;
                blue_temp  <=0;
            end else if(second == 6) begin
                red_temp <= (((hdata >= 45 && hdata <= 55) && (vdata >= 100 && vdata <= 500)) || (hdata >= 195 && hdata <= 205 && vdata >= 295 && vdata <= 505) || (((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505)) && ((hdata >= 50 && hdata <= 200)))) ? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(second == 7) begin
                red_temp <= (hdata >= 195 && hdata <= 205 && vdata >= 95 && vdata <= 505) || (hdata >= 50 && hdata <= 200 && vdata >= 95 && vdata <= 105) ? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(second == 8) begin
                red_temp <= (((hdata >= 45 && hdata <= 55) && (vdata >= 100 && vdata <= 500)) || (((hdata >= 195 && hdata <= 205)) && (vdata >= 100 && vdata <= 500)) || (((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505)) && ((hdata >= 50 && hdata <= 200)))) ? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end else if(second == 9) begin
                red_temp <= (((hdata >= 45 && hdata <= 55) && (vdata >= 100 && vdata <= 305)) || (((hdata >= 195 && hdata <= 205)) && (vdata >= 100 && vdata <= 500)) || (((vdata >= 95 && vdata <= 105) || (vdata >= 295 && vdata <= 305) || (vdata >= 495 && vdata <= 505)) && ((hdata >= 50 && hdata <= 200)))) ? 3'b111 : 0;
                green_temp <= 0;
                blue_temp <= 0;
            end
        end
    end
end

always @ (posedge clk_btn) begin
    if(first < 9) begin
        first <= first + 1;
    end else begin
        first <= 0;
        if(second < 9) begin
            second <= second + 1;
        end else begin
            second <= 0;
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

// 顶层单测文件thinpad_top.v
/*
wire [11:0] hdata;      // �??????
wire [11:0] vdata;      // �??????

// 行控�??????
assign video_red = hdata < 266 ? 3'b111 : 0; //红色竖条
assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //绿色竖条
assign video_blue = hdata >= 532 ? 2'b11 : 0; //蓝色竖条

// 列控�??????
assign video_red = vdata < 199 ? 3'b111 : 0; //红色竖条
assign video_green = vdata < 399 && vdata >= 199 ? 3'b111 : 0; //绿色竖条
assign video_blue = vdata >= 399 ? 2'b11 : 0; //蓝色竖条

assign video_clk = clk_50M;
vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
    .clk(clk_50M), 
    .hdata(hdata), //横坐�??????
    .vdata(vdata),      //纵坐�??????
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de)
);*/
