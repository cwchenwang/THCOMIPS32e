//coding: utf-8

//Author: 张岱墀

//Created: 2018/10/27

//实现了最上层需要的自动机(由于同样的理由应该会有syntax error)，即根据控制信号来转移到读操作或者写操作

module write_read_FSM (
    input wire clk, rst,
    input wire sig，
    output wire[1:0] curr_state,
    );
    
    localparam  S0 = 2'b01,
                S1 = 2'b10,
                S2 = 2'b11,
    
    reg [1:0] m_curr_state, m_next_state;

    initial begin

      clk = 0;
      rst = 1;
      sig = 0;

    end

    assign curr_state = m_curr_state;

    always @ (posedge clk or posedge rst) begin
        if(rst) 
            m_curr_state <= S0;
        else
            m_curr_state <= m_next_state;
    end

    always @(m_curr_state) begin
        case(m_curr_state)
        S0：begin
                m_next_state <= S1;
            end
        S1：begin
                m_next_state <= S0;
            end
        S2: begin
                m_next_state <= S0;
            end
        default: begin
                m_next_state <= S0;
            end
        endcase
    end

endmodule