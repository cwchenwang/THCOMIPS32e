`timescale 1ns / 1ps
// author by zdc
/* �?终综合的vga模板，用�?个状态机实现了�?�共三种状�?�的切换：计数器，推箱子，图片显示器�?
   切换状�?�方法为按住四个touch_btn�?左边两个时按下clock_btn，切换状态依次为计数器，推箱子，图片显示�?
   除了图片显示器外，剩余两个状态有重置方式，具体操作为：按住touch_btn�?右边两个之后按下clock_btn（使用这种方法的原因是直接使用reset_btn莫名不行�?
   计数器操作为按下clock计数器加�?；推箱子操作为按住touch_btn之后按下clock_btn，四个touch_btn左往右依次为上下左右方向；图片显示器画质存在�?定问�?
   具体在上层例化时，由于显示图片涉及访问BaseRAM且由0地址�?始访问，故例化时�?要一个访存模块，单独测试时写了一个叫ram_port的模块来实现这个功能，同时，上层还需要维护一个自动机以及控制串口使能，测试时的具体实现如下：

    reg [2:0] state;               //001-counter, 010-game, 100-image
    
    initial begin
        state <= 3'b000;
    end
    
    always @ (posedge clock_btn) begin
        if(touch_btn == 4'b1100) begin
            if(state == 3'b000) begin
                state <= 3'b001;
            end else if(state == 3'b001) begin
                state <= 3'b010; 
            end else if(state == 3'b010) begin
                state <= 3'b100;
            end else begin
                state <= 3'b000;
            end
        end
    end

    wire [11:0] hdata;      // �?
    wire [11:0] vdata;      // �?
    assign video_clk = clk_50M;
    
    assign uart_wrn = 1'b1;
    assign uart_rdn = 1'b1;
    assign base_ram_be_n = 4'b0000;
    
    wire[19:0] tar_addr;
    wire[31:0] ram_data;
    
    assign tar_addr = 20'b0 + (vdata * 800 + hdata) >> 2;
    
    final_vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) final_vga0 (
        .clk(clk_50M), 
        .hdata(hdata), //横坐�?
        .vdata(vdata),      //纵坐�?
        .hsync(video_hsync),
        .vsync(video_vsync),
        .data_enable(video_de),
        .red(video_red),
        .green(video_green),
        .blue(video_blue),
        .clk_btn(clock_btn),
        .rst_btn(reset_btn),
        .direction(touch_btn),
        .ram_data(ram_data),
        .state(state)
    );
        
    ram_port ram_port0(
        .addr(tar_addr),
        .base_ram_addr(base_ram_addr),
        .base_ram_data(base_ram_data),
        .base_ram_oe(base_ram_oe_n),
        .base_ram_en(base_ram_ce_n),
        .base_ram_rw(base_ram_we_n),
        .rst(reset_btn),
        .clk(clk_50M),
        .data_out(ram_data)
    );

*/

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
module final_vga
#(parameter WIDTH = 0, HSIZE = 0, HFP = 0, HSP = 0, HMAX = 0, VSIZE = 0, VFP = 0, VSP = 0, VMAX = 0, HSPP = 0, VSPP = 0)
(
    input wire clk,
    //output reg [18:0] addr,
    output reg [WIDTH - 1:0] hdata,
    output reg [WIDTH - 1:0] vdata,
    output wire hsync,
    output wire vsync,
    output wire data_enable,
    
    output wire[2:0] red,
    output wire[2:0] green,
    output wire[1:0] blue,

    input wire rst_btn,
    input wire clk_btn,

    // for game
    input wire[3:0] direction,

    // for image
    input wire[31:0] ram_data,

    input wire[2:0] state
);

    reg[3:0] red_temp;
    reg[3:0] green_temp;
    reg[3:0] blue_temp;

    assign red = red_temp;
    assign green = green_temp;
    assign blue = blue_temp;

    // for counter
    reg[3:0] first;
    reg[3:0] second;

    // for game
    reg[10:0] people_center_v;
    reg[10:0] people_center_h;
    reg[10:0] box_center_v;
    reg[10:0] box_center_h;
    reg[10:0] target_center_v;
    reg[10:0] target_center_h;

    initial begin
        hdata <= 0;
        vdata <= 0;
        red_temp <= 0;
        green_temp <= 0;
        blue_temp <= 0;

        // for counter
        first <= 0;
        second <= 0;

        // for game
        people_center_v <= 11'b0 + 300;
        people_center_h <= 11'b0 + 100;
        box_center_v <= 11'b0 + 300;
        box_center_h <= 11'b0 + 165;
        target_center_v <= 11'b0 + 500;
        target_center_h <= 11'b0 + 620;
    end

    always @ (*) begin
        if(state == 3'b001) begin   // counter
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
        end else if(state == 3'b010) begin
            red_temp <= (((vdata == people_center_v && hdata >= people_center_h - 25 && hdata <= people_center_h + 25) || (hdata == people_center_h && vdata >= people_center_v - 25 && vdata <= people_center_v + 25) || (vdata == people_center_v + 25 && hdata >= people_center_h - 15 && hdata <= people_center_h + 15) || (hdata == people_center_h - 15 && vdata >= people_center_v + 25 && vdata <= people_center_v + 50) || (hdata == people_center_h + 15 && vdata >= people_center_v + 25 && vdata <= people_center_v + 50) || (vdata >= people_center_v - 50 && vdata <= people_center_v - 25 && hdata >= people_center_h - 10 && hdata <= people_center_h + 10)) || (vdata >= box_center_v - 50 && vdata <= box_center_v + 50 && hdata <= box_center_h + 40 && hdata >= box_center_h - 40)) ? 3'b111 : 0;
            blue_temp <= (hdata >= target_center_h - 40 && hdata <= target_center_h + 40 && vdata >= target_center_v - 50 && vdata <= target_center_v + 50 ) ? 3'b011:0;
            green_temp <= (vdata >= 350 && hdata >= 530 && hdata <= 580) || (vdata <= 350 && hdata >= 205 && hdata <= 255) ? 3'b011:0;
        end else if(state == 3'b100) begin
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
    end

    always @ (posedge clk_btn) begin
        if(state == 3'b001) begin
            if(direction == 4'b0011) begin
                first <= 0;
                second <= 0;
            end else begin
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
        end else if(state == 3'b010) begin
            if(direction == 4'b0011) begin
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
    end

    // hdata
    always @ (posedge clk) begin
        if (hdata == (HMAX - 1))
            hdata <= 0;
        else
            hdata <= hdata + 1;
    end

    // vdata
    always @ (posedge clk) begin
        if (hdata == (HMAX - 1)) 
        begin
            if (vdata == (VMAX - 1))
                vdata <= 0;
            else
                vdata <= vdata + 1;
        end
    end

    // hsync & vsync & blank
    assign hsync =  ((hdata >= HFP) && (hdata < HSP)) ? HSPP : !HSPP;
    assign vsync = ((vdata >= VFP) && (vdata < VSP)) ? VSPP : !VSPP;
    assign data_enable = ((hdata < HSIZE) & (vdata < VSIZE));

endmodule