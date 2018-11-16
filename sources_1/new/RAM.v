`include "defines.v"

module RAM(
    input wire clk,

    // From MEM
    input wire ce,
    input wire we,
    input wire[`RamSel] sel,
    input wire[`DataAddrBus] addr,
    input wire[`DataBus] data,

    // To MEM
    output wire[`DataBus] data_o
);

endmodule