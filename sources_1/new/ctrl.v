`timescale 1ns / 1ps
`include "defines.vh"

module CTRL(
    input wire rst,

    // From ID and EX
    input wire stallreq_from_id,
    input wire stallreq_from_ex,

    // To many modules
    output reg stall,
    output reg flush
);

endmodule
