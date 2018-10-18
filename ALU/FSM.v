`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/14 21:14:32
// Design Name: 
// Module Name: FSM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define FSM_STATE_WIDTH 4
`define FSM_STATE_0 4'b0001
`define FSM_STATE_1 4'b0010
`define FSM_STATE_2 4'b0100
`define FSM_STATE_3 4'b1000

module FSM #(parameter Width = 32)(
    output reg[Width - 1: 0] a, b, 
    output reg[3:0] op,
    output wire[3:0] curr_state,   // So that top component can select the data to display
    input wire clk, rst,
    input wire[Width - 1: 0] inputsw
    );
    
    localparam  S0 = `FSM_STATE_0,
                S1 = `FSM_STATE_1,
                S2 = `FSM_STATE_2,
                S3 = `FSM_STATE_3;
    
    reg [3:0] m_curr_state, m_next_state;
    
    assign curr_state = m_curr_state;  
     
    // Transition 
    always @(posedge clk or posedge rst) begin
        if (rst)
            m_curr_state <= S0;
        else
            m_curr_state <= m_next_state;
    end
     
     // Next state
    always @(m_curr_state) begin   
        case (m_curr_state)
        S0: begin
            m_next_state = S1;
        end
        S1: begin
            m_next_state = S2;
        end
        S2: begin
            m_next_state = S3;
        end
        S3: begin
            m_next_state = S0;
        end
        default: begin
            m_next_state = S0;
        end
        endcase
    end
    
    // Output
    always @(*) begin  
        case (m_curr_state)
        S0: begin
            a <= inputsw;
        end
        S1: begin
            b <= inputsw;
        end
        S2: begin
            op <= inputsw[3:0];
        end
        S3: begin
        
        end
        default: begin
        
        end
        endcase
    end
     
endmodule
