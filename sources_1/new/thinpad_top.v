`default_nettype none
`timescale 1ns / 1ps
`include "defines.vh"

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时为1
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

    //// PLL分频示例
    wire locked; //, clk_10M, clk_20M;
    wire clk_22M5, clk_25M;
    clk_wiz_1 clock_gen 
    (
      // Clock out ports
      .clk_out1(clk_22M5), // 时钟输出1，频率在IP配置界面中设置
      .clk_out2(clk_25M), // 时钟输出2，频率在IP配置界面中设置
      // Status and control signals
      .reset(/*reset_btn*/ 0), // PLL复位输入
      .locked(locked), // 锁定输出，"1"表示时钟稳定，可作为后级电路复位
     // Clock in ports
      .clk_in1(clk_50M) // 外部时钟输入
     );
    
    //reg reset_of_clk10M;
    //// 异步复位，同步释放
    //always@(posedge clk_10M or negedge locked) begin
    //    if(~locked) reset_of_clk10M <= 1'b1;
    //    else        reset_of_clk10M <= 1'b0;
    //end
    
    //always@(posedge clk_10M or posedge reset_of_clk10M) begin
    //    if(reset_of_clk10M)begin
    //        // Your Code
    //    end
    //    else begin
    //        // Your Code
    //    end
    //end
    
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
    
    reg clk_12M5 = 0;
    reg clk_12M5_count = 0;
    always @(posedge clk_50M) begin
        if (clk_12M5_count)
            clk_12M5 <= !clk_12M5;
        clk_12M5_count <= !clk_12M5_count;
    end

    wire clk = clk_22M5;
    wire flash_clk = clk_12M5;  // clk_11M0592 is problematic
    wire flash_btn = clock_btn;
    
    // Instruction memory
    wire[`InstAddrBus] rom_addr;
    wire rom_ce;
    wire rom_we;
    wire[`InstBus] rom_wr_data;
    wire[`InstBus] rom_rd_data;
    wire[3:0] rom_sel;
    
    // Data memory
    wire mem_we_i;
    wire[`RegBus] mem_addr_i;
    wire[`RegBus] mem_data_i;
    wire[`RegBus] mem_data_o;
    wire[3:0] mem_sel_i; 
    wire mem_ce_i;
    wire mem_clk;  
    
    // Flash 
    wire[22:1] flash_ctrl_addr;
    wire[15:0] flash_ctrl_data;
    wire flash_ctrl_data_ready;
    
    // Interrupt 
    wire timer_int;
    wire[5:0] interrupt = {5'b00000, timer_int};
//    wire[5:0] interrupt = {5'b00000, timer_int, gpio_int, uart_int};

    // VGA
    wire[11:0] vga_hdata;     
    wire[11:0] vga_vdata;      
    wire[`DataBus] vga_data;
    wire[2:0] vga_state;

    BasicRamWrapper rom_wrapper(
       .clk(clk),
       .addr_i(rom_addr),
       .ce_i(rom_ce),
       .we_i(rom_we),
       .data_i(rom_wr_data),
       .sel_i(rom_sel),    
       .data_o(rom_rd_data),
       
       .ram_data(ext_ram_data),
       .ram_addr(ext_ram_addr),
       .ram_be_n(ext_ram_be_n),
       .ram_ce_n(ext_ram_ce_n),
       .ram_oe_n(ext_ram_oe_n),
       .ram_we_n(ext_ram_we_n)
    );

    RamUartWrapper ram_wrapper(
        .clk(mem_clk),
        .addr_i(mem_addr_i),
        .ce_i(mem_ce_i),
        .we_i(mem_we_i),
        .data_i(mem_data_i),
        .sel_i(mem_sel_i),   
        .data_o(mem_data_o),
        
        .ram_data(base_ram_data),
        .ram_addr(base_ram_addr),
        .ram_be_n(base_ram_be_n),
        .ram_ce_n(base_ram_ce_n),
        .ram_oe_n(base_ram_oe_n),
        .ram_we_n(base_ram_we_n),
        
        .tbre(uart_tbre),
        .tsre(uart_tsre),
        .data_ready(uart_dataready),
        .rdn(uart_rdn),
        .wrn(uart_wrn)
    );
    
    THCOMIPS32e cpu(
        .clk(clk),
        .clk_50M(clk_50M),
        .reset_btn(reset_btn),
        .flash_btn(clock_btn),
        .touch_btn(touch_btn),
        
        .rom_addr_o(rom_addr),
        .rom_ce_o(rom_ce),
        .rom_we_o(rom_we),
        .rom_data_o(rom_wr_data),
        .rom_sel_o(rom_sel),
        .rom_data_i(rom_rd_data),
        
        .ram_we_o(mem_we_i),
        .ram_addr_o(mem_addr_i),
        .ram_sel_o(mem_sel_i),
        .ram_data_o(mem_data_i),
        .ram_data_i(mem_data_o),
        .ram_ce_o(mem_ce_i),
        .ram_clk_o(mem_clk),
        
        .flash_addr(flash_ctrl_addr),
        .flash_data(flash_ctrl_data),    
        .flash_data_ready(flash_ctrl_data_ready),
        
        .vga_hdata_i(vga_hdata),      
        .vga_vdata_i(vga_vdata),      
        .vga_data_o(vga_data),
        .vga_state_o(vga_state),
        
        .int_i(interrupt),
        .timer_int_o(timer_int)			
    );
    
    Flash #(.reverse(0)) flash_ctrl(
        .rst(reset_btn),
        .clk(flash_clk),
        
        .addr(flash_ctrl_addr),
        .data_out(flash_ctrl_data), 
        .data_ready(flash_ctrl_data_ready),
        
        .flash_ce(flash_ce_n),
        .flash_we(flash_we_n),
        .flash_oe(flash_oe_n),
        .flash_rp(flash_rp_n),
        .flash_byte(flash_byte_n),
        .flash_vpen(flash_vpen),
        .flash_addr(flash_a[22:1]),
        .flash_data(flash_d)
    );
    assign flash_a[0] = 0;
    
    assign video_clk = clk_50M;
    final_vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) final_vga0 (
        .clk(clk_50M), 
        .hdata(vga_hdata), 
        .vdata(vga_vdata), 
        .hsync(video_hsync),
        .vsync(video_vsync),
        .data_enable(video_de),
        .red(video_red),
        .green(video_green),
        .blue(video_blue),
        .clk_btn(clock_btn),
        .rst_btn(reset_btn),
        .direction(touch_btn),
        .ram_data(vga_data),
        .state(vga_state)
    );
    
    SEG7_LUT lo_seg(dpy0, {1'b0, cpu.ctrl.state});
    assign leds = cpu.pc_value[15:0];

endmodule
