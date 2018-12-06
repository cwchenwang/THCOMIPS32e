`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到"ON"时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //CPLD串口控制器信号
    output wire uart_rdn,         //读串口信号，低有效
    output wire uart_wrn,         //写串口信号，低有效
    input wire uart_dataready,    //串口数据准备好
    input wire uart_tbre,         //发送数据标志
    input wire uart_tsre,         //数据发送完毕标志

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有效
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire ext_ram_we_n,       //ExtRAM写使能，低有效

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //USB 控制器信号，参考 SL811 芯片手册
    output wire sl811_a0,
    //inout  wire[7:0] sl811_d,     //USB数据线与网络控制器的dm9k_sd[7:0]共享
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    //网络控制器信号，参考 DM9000A 芯片手册
    output wire dm9k_cmd,
    inout  wire[15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input  wire dm9k_int,

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐区
);


/* =========== Demo code begin =========== */

// PLL分频示例
wire locked, clk_10M, clk_20M;

reg reset_of_clk10M;
// 异步复位，同步释放
always@(posedge clk_10M or negedge locked) begin
    if(~locked) reset_of_clk10M <= 1'b1;
    else        reset_of_clk10M <= 1'b0;
end

always@(posedge clk_10M or posedge reset_of_clk10M) begin
    if(reset_of_clk10M)begin
        // Your Code
    end
    else begin
        // Your Code
    end
end

//assign leds[3:0] = touch_btn;
    
//    assign uart_wrn = 1'b1;
//    assign uart_rdn = 1'b1;
//    assign base_ram_be_n = 4'b0000;
    
//    wire[19:0] tar_addr;
//    wire[31:0] ram_data;
//    reg flag = 1'b1;
    
//    always @ (posedge clock_btn) begin
//        flag = ~flag;
//    end
    
//    wire [11:0] hdata;      // 行
//    wire [11:0] vdata;      // 列;
    
//    assign tar_addr = 20'b0 + (vdata * 800 + hdata) >> 2;
    
//    assign video_clk = clk_50M;
    
//    image_vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) image_vga0 (
//        .clk(clk_50M), 
//        .hdata(hdata), //横坐标
//        .vdata(vdata),      //纵坐标
//        .hsync(video_hsync),
//        .vsync(video_vsync),
//        .data_enable(video_de),
//        .red(video_red),
//        .green(video_green),
//        .blue(video_blue),
//        .ram_data(ram_data)
//    );
        
//    ram_port ram_port0(
//        .addr(tar_addr),
//        .base_ram_addr(base_ram_addr),
//        .base_ram_data(base_ram_data),
//        .base_ram_oe(base_ram_oe_n),
//        .base_ram_en(base_ram_ce_n),
//        .base_ram_rw(base_ram_we_n),
//        //.leds(leds),
//        .rst(reset_btn),
//        //.clk(clock_btn),
//        .clk(clk_50M),
//        //.data_out(ram_data[15:0])
//        .data_out(ram_data)
//    );
    
    //assign leds = flag ? ram_data[31 : 16] : ram_data[15:0];


//    always @ (posedge clk_50M) begin
//        if(flag2 == 1'b1) begin
//            flag = ~flag;
//            if(flag == 1'b1) begin
//                tar_addr = tar_addr + 1;
//            end
            
//            flag2 = 1'b0;
//        end else begin
//            flag2 = flag2 + 1;
//        end
//    end

/*assign video_clk = clk_11M0592;

vga vga0(
    .clk(clk_11M0592),
    .Hs(video_hsync),
    .Vs(video_vsync),
    .R(video_red),
    .G(video_green),
    .B(video_blue),
    .data_enable(video_de)
    //.vga_clk(video_clk)
);

assign leds[15: 8] = {video_red[2:0], video_green[2:0], video_blue[1:0], video_de};
*/
// 数码管连接关系示意图，dpy1同理
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

//// 7段数码管译码器演示，将number用16进制显示在数码管上面
//reg[7:0] number;
//SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0是低位数码管
//SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1是高位数码管

//reg[15:0] led_bits;
//assign leds = led_bits;

//always@(posedge clock_btn or posedge reset_btn) begin
//    if(reset_btn)begin //复位按下，设置LED和数码管为初始值
//        number<=0;
//        led_bits <= 16'h1;
//    end
//    else begin //每次按下时钟按钮，数码管显示值加1，LED循环左移
//        number <= number+1;
//        led_bits <= {led_bits[14:0],led_bits[15]};
//    end
//end


/*reg[22:1] addr_temp = 22'b0;

flash flash0(
    .rst(reset_btn),
    .clk(clock_btn),
    .flash_ce(flash_ce_n),
    .flash_we(flash_we_n),
    .flash_oe(flash_oe_n),
    .flash_rp(flash_rp_n),
    .flash_byte(flash_byte_n),
    .flash_vpen(flash_vpen),
    .addr(addr_temp),
    .data_out(leds),
    .flash_addr(flash_a[22:1]),
    .flash_data(flash_d)
);*/


////直连串口接收发送演示，从直连串口收到的数据再发送出去
//wire [7:0] ext_uart_rx;
//reg  [7:0] ext_uart_buffer, ext_uart_tx;
//wire ext_uart_ready, ext_uart_busy;
//reg ext_uart_start, ext_uart_avai;

//async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //接收模块，9600无检验位
//    ext_uart_r(
//        .clk(clk_50M),                       //外部时钟信号
//        .RxD(rxd),                           //外部串行信号输入
//        .RxD_data_ready(ext_uart_ready),  //数据接收到标志
//        .RxD_clear(ext_uart_ready),       //清除接收标志
//        .RxD_data(ext_uart_rx)             //接收到的一字节数据
//    );
    
//always @(posedge clk_50M) begin //接收到缓冲区ext_uart_buffer
//    if(ext_uart_ready)begin
//        ext_uart_buffer <= ext_uart_rx;
//        ext_uart_avai <= 1;
//    end else if(!ext_uart_busy && ext_uart_avai)begin 
//        ext_uart_avai <= 0;
//    end
//end
//always @(posedge clk_50M) begin //将缓冲区ext_uart_buffer发送出去
//    if(!ext_uart_busy && ext_uart_avai)begin 
//        ext_uart_tx <= ext_uart_buffer;
//        ext_uart_start <= 1;
//    end else begin 
//        ext_uart_start <= 0;
//    end
//end

//async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发送模块，9600无检验位
//    ext_uart_t(
//        .clk(clk_50M),                  //外部时钟信号
//        .TxD(txd),                      //串行信号输出
//        .TxD_busy(ext_uart_busy),       //发送器忙状态指示
//        .TxD_start(ext_uart_start),    //开始发送信号
//        .TxD_data(ext_uart_tx)        //待发送的数据
//    );

//图像输出演示，分辨率800x600@75Hz，像素时钟为50MHz
wire [11:0] hdata;      // 行
wire [11:0] vdata;      // 列
//assign leds = 16'b1111111111111111;
/*assign video_red = hdata < 266 ? 3'b111 : 0; //红色竖条
assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //绿色竖条
assign video_blue = hdata >= 532 ? 2'b11 : 0; //蓝色竖条*/
/*assign video_red = vdata < 199 ? 3'b111 : 0; //红色竖条
assign video_green = vdata < 399 && vdata >= 199 ? 3'b111 : 0; //绿色竖条
assign video_blue = vdata >= 399 ? 2'b11 : 0; //蓝色竖条*/
/*assign video_red = (((hdata >= 375 && hdata <= 425) && ((vdata >= 225 && vdata <= 275) || (vdata >= 325 && vdata <= 375))) || (hdata == 600 && (vdata >= 100 && vdata <= 500)) || (hdata == 200 && (vdata >= 100 && vdata <= 500)) || ((hdata == 50 || hdata == 750) && (vdata >= 100 && vdata <= 500)) || ((vdata == 100 || vdata == 300 || vdata == 500) && ((hdata >= 50 && hdata <= 200) ||(hdata >= 600 && hdata <= 750)))) ? 3'b111 : 0;
assign video_green = 0;
assign video_blue = 0;*/ 
assign video_clk = clk_50M;
vga_game #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
    .clk(clk_50M), 
    .hdata(hdata), //横坐标
    .vdata(vdata),      //纵坐标
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de),
    .red(video_red),
    .green(video_green),
    .blue(video_blue),
    .clk_btn(clock_btn),
    .rst_btn(reset_btn),
    .direction(touch_btn)
);

    //reg[22:1] flash_addr = 22'b0;
    //reg[15:0] flash_data_out = 16'b0;

//    wire[31:0] mem_data_o;
    
//    reg[31:0] image_addr = 32'h80400000;
    
//    assign leds = mem_data_o[15:0];
    
//    always @ (clock_btn) begin
//        image_addr <= image_addr + 1;
//    end
    
// RAMWrapper ram_wrapper(
//        .clk(clock_btn),
//        .addr_i(image_addr),
//        .ce_i(1'b1),
//        .we_i(1'b0),
//        //.data_i(mem_data_i),
//        .sel_i(4'b1111),   
//        .data_o(mem_data_o),
        
//        .ram_data(base_ram_data),
//        .ram_addr(base_ram_addr),
//        .ram_be_n(base_ram_be_n),
//        .ram_ce_n(base_ram_ce_n),
//        .ram_oe_n(base_ram_oe_n),
//        .ram_we_n(base_ram_we_n)
        
//        .tbre(uart_tbre),
//        .tsre(uart_tsre),
//        .data_ready(uart_dataready),
//        .rdn(uart_rdn),
//        .wrn(uart_wrn)
//    );

//flash flash0(
//    .rst(reset_btn),
//    .clk(clock_btn),
//    .flash_ce(flash_ce_n),
//    .flash_we(flash_we_n),
//    .flash_oe(flash_oe_n),
//    .flash_rp(flash_rp_n),
//    .flash_byte(flash_byte_n),
//    .flash_vpen(flash_vpen),
//    .addr(flash_addr),
//    .data_out(leds[15:0]),
//    //.data_out(flash_data_out),
//    .flash_addr(flash_a),
//    .flash_data(flash_d)
//);

/*image_vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) image_vga0 (
    .clk(clk_50M), 
    .hdata(hdata), //横坐标
    .vdata(vdata),      //纵坐标
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de),
    .red(video_red),
    .green(video_green),
    .blue(video_blue),
    .flash_addr(flash_addr),
    .flash_data(flash_d[15:8])
);*/
/* =========== Demo code end =========== */

endmodule