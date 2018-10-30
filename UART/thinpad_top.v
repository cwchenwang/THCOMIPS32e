`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz ʱ������
    input wire clk_11M0592,       //11.0592MHz ʱ������

    input wire clock_btn,         //BTN5�ֶ�ʱ�Ӱ�ť���أ���������·������ʱΪ1
    input wire reset_btn,         //BTN6�ֶ���λ��ť���أ���������·������ʱΪ1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4����ť���أ�����ʱΪ1
    input  wire[31:0] dip_sw,     //32λ���뿪�أ�����"ON"ʱΪ1
    output wire[15:0] leds,       //16λLED�����ʱ1����
    output wire[7:0]  dpy0,       //����ܵ�λ�źţ�����С���㣬���1����
    output wire[7:0]  dpy1,       //����ܸ�λ�źţ�����С���㣬���1����

    //CPLD���ڿ������ź�
    output wire uart_rdn,         //�������źţ�����Ч
    output wire uart_wrn,         //д�����źţ�����Ч
    input wire uart_dataready,    //��������׼����
    input wire uart_tbre,         //�������ݱ�־
    input wire uart_tsre,         //���ݷ�����ϱ�־

    //BaseRAM�ź�
    inout wire[31:0] base_ram_data,  //BaseRAM���ݣ���8λ��CPLD���ڿ���������
    output wire[19:0] base_ram_addr, //BaseRAM��ַ
    output wire[3:0] base_ram_be_n,  //BaseRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
    output wire base_ram_ce_n,       //BaseRAMƬѡ������Ч
    output wire base_ram_oe_n,       //BaseRAM��ʹ�ܣ�����Ч
    output wire base_ram_we_n,       //BaseRAMдʹ�ܣ�����Ч

    //ExtRAM�ź�
    inout wire[31:0] ext_ram_data,  //ExtRAM����
    output wire[19:0] ext_ram_addr, //ExtRAM��ַ
    output wire[3:0] ext_ram_be_n,  //ExtRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
    output wire ext_ram_ce_n,       //ExtRAMƬѡ������Ч
    output wire ext_ram_oe_n,       //ExtRAM��ʹ�ܣ�����Ч
    output wire ext_ram_we_n,       //ExtRAMдʹ�ܣ�����Ч

    //ֱ�������ź�
    output wire txd,  //ֱ�����ڷ��Ͷ�
    input  wire rxd,  //ֱ�����ڽ��ն�

    //Flash�洢���źţ��ο� JS28F640 оƬ�ֲ�
    output wire [22:0]flash_a,      //Flash��ַ��a0����8bitģʽ��Ч��16bitģʽ������
    inout  wire [15:0]flash_d,      //Flash����
    output wire flash_rp_n,         //Flash��λ�źţ�����Ч
    output wire flash_vpen,         //Flashд�����źţ��͵�ƽʱ���ܲ�������д
    output wire flash_ce_n,         //FlashƬѡ�źţ�����Ч
    output wire flash_oe_n,         //Flash��ʹ���źţ�����Ч
    output wire flash_we_n,         //Flashдʹ���źţ�����Ч
    output wire flash_byte_n,       //Flash 8bitģʽѡ�񣬵���Ч����ʹ��flash��16λģʽʱ����Ϊ1

    //USB �������źţ��ο� SL811 оƬ�ֲ�
    output wire sl811_a0,
    //inout  wire[7:0] sl811_d,     //USB�������������������dm9k_sd[7:0]����
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    //����������źţ��ο� DM9000A оƬ�ֲ�
    output wire dm9k_cmd,
    inout  wire[15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input  wire dm9k_int,

    //ͼ������ź�
    output wire[2:0] video_red,    //��ɫ���أ�3λ
    output wire[2:0] video_green,  //��ɫ���أ�3λ
    output wire[1:0] video_blue,   //��ɫ���أ�2λ
    output wire video_hsync,       //��ͬ����ˮƽͬ�����ź�
    output wire video_vsync,       //��ͬ������ֱͬ�����ź�
    output wire video_clk,         //����ʱ�����
    output wire video_de           //��������Ч�źţ���������������
);


/* =========== Demo code begin =========== */

// PLL��Ƶʾ��
wire locked, clk_10M, clk_20M;

reg reset_of_clk10M;
// �첽��λ��ͬ���ͷ�
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

// ��������ӹ�ϵʾ��ͼ��dpy1ͬ��
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

//// 7���������������ʾ����number��16������ʾ�����������
//reg[7:0] number;
//SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0�ǵ�λ�����
//SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1�Ǹ�λ�����

//reg[15:0] led_bits;
//assign leds = led_bits;

//always@(posedge clock_btn or posedge reset_btn) begin
//    if(reset_btn)begin //��λ���£�����LED�������Ϊ��ʼֵ
//        number<=0;
//        led_bits <= 16'h1;
//    end
//    else begin //ÿ�ΰ���ʱ�Ӱ�ť���������ʾֵ��1��LEDѭ������
//        number <= number+1;
//        led_bits <= {led_bits[14:0],led_bits[15]};
//    end
//end

serial_port ex_serial_port(
    .clk(clk_11M0592), 
    .rst(reset_btn),
    .mode(dip_sw[31:30]),
    .output_mode(),
    .data(base_ram_data[7:0]),
    .data_in(dip_sw[7:0]),
    .data_out(leds[7:0]),
    .data_ready(uart_dataready),
    .tbre(uart_tbre),
    .tsre(uart_tsre),
    .out_tbre(dpy0[5]),
    .out_tsre(dpy0[4]),
    .wrn(uart_wrn),
    .rdn(uart_rdn),
    .fucku(dpy0[1]),
    .ram1_en(base_ram_ce_n),
    .ram1_oe(base_ram_oe_n),
    .ram1_rw(base_ram_we_n)
);

////ֱ�����ڽ��շ�����ʾ����ֱ�������յ��������ٷ��ͳ�ȥ
//wire [7:0] ext_uart_rx;
//reg  [7:0] ext_uart_buffer, ext_uart_tx;
//wire ext_uart_ready, ext_uart_busy;
//reg ext_uart_start, ext_uart_avai;

//async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //����ģ�飬9600�޼���λ
//    ext_uart_r(
//        .clk(clk_50M),                       //�ⲿʱ���ź�
//        .RxD(rxd),                           //�ⲿ�����ź�����
//        .RxD_data_ready(ext_uart_ready),  //���ݽ��յ���־
//        .RxD_clear(ext_uart_ready),       //������ձ�־
//        .RxD_data(ext_uart_rx)             //���յ���һ�ֽ�����
//    );
    
//always @(posedge clk_50M) begin //���յ�������ext_uart_buffer
//    if(ext_uart_ready)begin
//        ext_uart_buffer <= ext_uart_rx;
//        ext_uart_avai <= 1;
//    end else if(!ext_uart_busy && ext_uart_avai)begin 
//        ext_uart_avai <= 0;
//    end
//end
//always @(posedge clk_50M) begin //��������ext_uart_buffer���ͳ�ȥ
//    if(!ext_uart_busy && ext_uart_avai)begin 
//        ext_uart_tx <= ext_uart_buffer;
//        ext_uart_start <= 1;
//    end else begin 
//        ext_uart_start <= 0;
//    end
//end

//async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //����ģ�飬9600�޼���λ
//    ext_uart_t(
//        .clk(clk_50M),                  //�ⲿʱ���ź�
//        .TxD(txd),                      //�����ź����
//        .TxD_busy(ext_uart_busy),       //������æ״ָ̬ʾ
//        .TxD_start(ext_uart_start),    //��ʼ�����ź�
//        .TxD_data(ext_uart_tx)        //�����͵�����
//    );

////ͼ�������ʾ���ֱ���800x600@75Hz������ʱ��Ϊ50MHz
//wire [11:0] hdata;
//assign video_red = hdata < 266 ? 3'b111 : 0; //��ɫ����
//assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //��ɫ����
//assign video_blue = hdata >= 532 ? 2'b11 : 0; //��ɫ����
//assign video_clk = clk_50M;
//vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
//    .clk(clk_50M), 
//    .hdata(hdata), //������
//    .vdata(),      //������
//    .hsync(video_hsync),
//    .vsync(video_vsync),
//    .data_enable(video_de)
//);
/* =========== Demo code end =========== */

endmodule