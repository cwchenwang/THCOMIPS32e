`include "defines.v"

module pc(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire stall,
    input wire[`InstAddrBus] new_pc,
    input wire branch_flag_i,
    input wire[`RegAddrBus] branch_target_address_i,
    output reg[`InstAddrBus] pc,
    output reg ce
);

endmodule