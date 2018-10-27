//coding: utf-8

//Author: 张岱墀

//Created: 2018/10/27

/*按照要求，借鉴了一些代码写的控制程序
  由于没有环境以及verilog语言掌握不扎实应该会有syntax error(裸写真刺激，下次出门得记得把硬盘拿上)
  按照书上的要求完成读写任务的过程，寄存器用变量代替
  没有测试不知道task里面按顺序写clk的触发是不是相当于已完成自动机(据网上所说是)
*/

module control_ram (
    input reg clk,
    input reg rst,
    output reg wr_en_o,
    output reg rd_en_o,
    output reg [17:0] addr_o,
    inout [15:0] data_io
  );

    reg[15:0] WriteReg;         //模拟寄存器，书上写的是先暂存到寄存器里

    initial begin

      WriteReg = 0;
      clk = 0;
      rst = 1;
      wr_en_o = 0;
      rd_en_o = 0;
      addr_o = 0;

    end

    assign data_io = wr_en_o ? WriteReg : 16'bz;  //由使能信号判断是从寄存器里面拿数据还是置高阻

    task write(
      input[17:0] addr,
      input[15:0] data
      );
      
      begin

        @(posedge clk);      
          addr_o <= addr;
          WriteRAM <= data;
          wr_en_o <= 1'b1;

        @(posedge clk);
          wr_en_o <= 1'b0;

      end
    
    endtask
    

   task read( 
    input[17:0] addr
    );

    begin

      @(posedge clk);
        addr_o <= addr;
        rd_en_o <= 1'b1;
      
      @(posedge clk);
      rd_en_o <= 1'b0;

    end

  endtask 

endmodule