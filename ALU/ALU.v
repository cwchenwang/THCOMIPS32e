`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 李依林
// 
// Create Date: 2018/10/14 11:42:09
// Design Name: 
// Module Name: ALU
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

// Positions of flag bits
`define CARRY_BIT_POS 0
`define OVERFLOW_BIT_POS 1
`define ZERO_BIT_POS 2
`define SIGN_BIT_POS 3

`define ADD_OP 4'd0
`define SUB_OP 4'd1
`define AND_OP 4'd2
`define OR_OP 4'd3
`define XOR_OP 4'd4
`define NOT_OP 4'd5
`define SLL_OP 4'd6
`define SRL_OP 4'd7
`define SRA_OP 4'd8
`define ROL_OP 4'd9

module ALU #(parameter Width = 32)(
    output reg[Width - 1: 0] f_out,
    output reg[3:0] flag_out,
    input wire[Width - 1: 0] a_in,
    input wire[Width - 1: 0] b_in,
    input wire[3:0] op
    );
    
    localparam true = 1'b1, false = 1'b0;
    
    reg[2 * Width - 1: 0] rotate_tmp;

    always @(*) begin       
        flag_out[`CARRY_BIT_POS] <= false;  
        flag_out[`OVERFLOW_BIT_POS] <= false;
        flag_out[`ZERO_BIT_POS] <= !f_out;
        flag_out[`SIGN_BIT_POS] <= f_out[Width - 1];
        
        case (op)
        `ADD_OP: begin   
            f_out <= a_in + b_in; 
            flag_out[`CARRY_BIT_POS] <= ~a_in[Width - 1] & ~b_in[Width - 1] & f_out[Width - 1];
            flag_out[`OVERFLOW_BIT_POS] <= (a_in[Width - 1] & b_in[Width - 1] & ~f_out[Width - 1])
                | (~a_in[Width - 1] & ~b_in[Width - 1] & f_out[Width - 1]);   // -- => +, ++ => -
        end
        `SUB_OP: begin    
            f_out <= a_in - b_in;       
            flag_out[`CARRY_BIT_POS] <= ~a_in[Width - 1] & f_out[Width - 1];
            flag_out[`OVERFLOW_BIT_POS] <=  (~a_in[Width - 1] & b_in[Width - 1] & f_out[Width - 1])
                | (a_in[Width - 1] & ~b_in[Width - 1] & ~f_out[Width - 1]);       // +- => -, -+ => +
        end
        `AND_OP: begin    
            f_out <= a_in & b_in;       
        end
        `OR_OP: begin    
            f_out <= a_in | b_in;       
        end
        `XOR_OP: begin    
            f_out <= a_in ^ b_in;       
        end
        `NOT_OP: begin    
            f_out <= ~a_in;             
        end
        `SLL_OP: begin    
            f_out <= a_in << b_in;              
        end
        `SRL_OP: begin    
            f_out <= a_in >> b_in;      
        end
        `SRA_OP: begin    
            f_out <= a_in >>> b_in;     
        end 
        `ROL_OP: begin    
            // Sublist indices must be constants, so we cannot do ROL in one statement.
            rotate_tmp <= {2{a_in}} << b_in; 
            f_out <= rotate_tmp[2 * Width - 1 : Width];
        end
        default: begin
            f_out <= 0;
        end
        endcase 
    end     // always
endmodule
