//------------------------------------------------------------------------------
// Author: Evan Wu
// Date: 9/10/2026
//
// Module: led_ctrl_hw_top
// Description: Avalon-MM interface for controlling 10 LEDs on DE1-SoC board
// from HPS
//------------------------------------------------------------------------------

`timescale 1ns / 100ps
`default_nettype none


module led_ctrl_hw_top #(
    parameter int AddressWidth = 2,  // Address width in bits
    parameter int DataWidth = 32  // Data width in bits
) (

    input logic clk_i,
    input logic rst_i,

    // Application-specific output
    output wire logic [9:0] led_o
);


  // Avalon-MM interface signals
  logic [AddressWidth-1:0] csr_address;
  logic csr_write;
  logic [DataWidth-1:0] csr_writedata;
  logic csr_read;
  logic [DataWidth-1:0] csr_readdata;
  logic csr_waitrequest;
  logic csr_readdatavalid;


  avalon_mm_led_ctrl #(
      .AddressWidth(AddressWidth),
      .DataWidth(DataWidth)
  ) led_ctrl_u (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .csr_address(csr_address),
      .csr_write(csr_write),
      .csr_writedata(csr_writedata),
      .csr_read(csr_read),
      .csr_readdata(csr_readdata),
      .csr_waitrequest(csr_waitrequest),
      .csr_readdatavalid(csr_readdatavalid),
      .led_o(led_o)
  );

endmodule

`resetall
