`define STATE_WIDTH 4
`define STATE_0 4'b0000
`define STATE_1 4'b0001
`define STATE_2 4'b0010
`define STATE_3 4'b0100
`define STATE_4 4'b1000
`define STATE_5 4'b0011
`define STATE_6 4'b0101
`define STATE_7 4'b1001
`define STATE_8 4'b0110
`define STATE_9 4'b1010
`define STATE_10 4'b1100
`define STATE_11 4'b0111

module control_ram (
    input reg clk,
    input reg rst,
    input reg [15:0] sw,
    output reg ram1_en,
    output reg ram1_oe,
    output reg ram1_we,
    output reg ram2_en,
    output reg ram2_oe,
    output reg ram2_we,
    output reg wr_en_o,
    output reg rd_en_o,
    output reg [19:0] addr_1,
    output reg [19:0] addr_2,
    inout reg [15:0] data_1,
    inout reg [15:0] data_2,
    output reg [7:0] led_data,
    output reg [7:0] led_addr
  );

    reg[15:0] data_reg;         //模拟寄存器，暂存数据
    reg[19:0] addr_reg;         //模拟寄存器，暂存地址

    reg [1:0] m_curr_state, m_next_state;
    parameter ans = 0;

    localparam  S0 = `STATE_0,
                S1 = `STATE_1,
                S2 = `STATE_2,
                S3 = `STATE_3,
                S4 = `STATE_4,
                S5 = `STATE_5,
                S6 = `STATE_6,
                S7 = `STATE_7,
                S8 = `STATE_8,
                S9 = `STATE_9,
                S10 = `STATE_10,
                S11 = `STATE_11,


    initial begin
      clk = 0;
      rst = 1;
      sw = 0;
      wr_en_o = 0;
      rd_en_o = 0;
      addr_1 = 0;
      addr_2 = 0;
      data_1 = 0;
      data_2 = 0;
      data_reg = 0;
      addr_reg = 0;
      m_curr_state = S0;
      m_next_state = S0;
      ram1_en = 0;
      ram2_en = 0;
      ram1_oe = 1;
      ram2_oe = 1;
      ram1_we = 1;
      ram2_we = 1;
      ans = 0;
    end

    assign led_addr = addr_reg;
    assign led_data = data_reg;

    //转移
    always @(posedge rst or posedge clk) begin
        if (rst)
            m_curr_state <= S0;
        else if(clk)
            m_curr_state <= m_next_state;
    end

    //每一状态动作
    always @(m_curr_state) begin   
        case (m_curr_state)

        S0: begin
          addr_reg = sw;
          m_next_state = S1;
        end

        S1: begin
          data_reg = sw;
          addr_1 = addr_reg;
          data_1 = data_reg;
          ans = ans + 1;
          m_next_state = S2;
        end

        S2: begin
          ram1_we = 1;
          m_next_state = S3;
        end

        S3: begin
          ram1_we = 0;
          addr_reg = addr_reg + 1;
          data_reg = data_reg + 1;
          addr_1 = addr_reg;
          data_1 = data_reg;
          ans = ans + 1;
          if(ans < 10) begin
            m_next_state = S2;
          end
          else begin
            ans = 0;
            m_next_state = S4;
          end
        end

        S4: begin
          data_1 = 16'bzzzzzzzzzzzzzzzz;
          ram1_we = 1;
          ram1_oe = 0;
          addr_1 = addr_reg;
          m_next_state = S5;
        end

        S5: begin
          data_reg = data_1;
          addr_reg = addr_reg - 1;
          addr_1 = addr_reg;
          ans = ans + 1;
          if(ans == 10) begin
            ans = 0;
            m_next_state = S6;
            addr_1 = addr_reg + 1;
          end 
          else begin
            m_next_state = S5;
          end
        end

        S6: begin
          ram1_we = 1;
          ram1_oe = 1;
          addr_reg = addr_reg + 1;
          data_reg = data_reg - 1;
          m_next_state = S7;
        end

        S7: begin
          ram2_we = 0;
          data_2 = data_reg;
          addr_2 = addr_reg;
          ans = ans + 1;
          m_next_state = S8;
        end

        S8: begin
          ram2_we = 1;
          m_next_state = S9;
        end

        S9: begin
          ram2_we = 0;
          data_reg = data_reg + 1;
          addr_reg = addr_reg + 1;
          data_2 = data_reg;
          addr_2 = addr_reg;
          ans = ans + 1;
          if(ans < 10) begin
            m_next_state = S8;
          end
          else begin
            ans = 0;
            m_next_state = S10;
          end
        end

        S10: begin
          data_2 = 16'bzzzzzzzzzzzzzzzz;
          ram2_we = 1;
          ram2_oe = 0;
          m_next_state = S11;
        end

        S11: begin
          data_reg = data_2;
          addr_reg = addr_reg - 1;
          addr_2 = addr_reg;
          ans = ans + 1;
          if(ans == 10) begin
            ans = 0;
            m_next_state = S0;
            addr_2 = addr_reg + 1;
          end

        default: begin
            m_next_state = S0;
        end

        endcase
    end

endmodule
