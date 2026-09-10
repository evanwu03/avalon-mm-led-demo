//------------------------------------------------------------------------------
// Author: Evan Wu
// Date: 9/10/2026
//
// Module: avalon_mm_led_ctrl
// Description: Avalon-MM interface for controlling 10 LEDs on DE1-SoC board
// from HPS
//------------------------------------------------------------------------------

`timescale 1ns / 100ps
`default_nettype none


module avalon_mm_led_ctrl #(
    parameter int AddressWidth = 2,  // Address width in bits
    parameter int DataWidth = 32  // Data width in bits
) (

    input logic clk_i,
    input logic rst_i,

    // Avalon-MM interface signals
    input logic [AddressWidth-1:0] csr_address,
    input logic csr_write,
    input logic [DataWidth-1:0] csr_writedata,
    input logic csr_read,
    output logic [DataWidth-1:0] csr_readdata,
    output logic csr_waitrequest,
    output logic csr_readdatavalid,

    // Application-specific output
    output logic [9:0] led_o
);

  typedef enum logic [AddressWidth-1:0] {
    ADDR_LED_CTRL  = 2'd0,
    ADDR_DEVICE_ID = 2'd1
  } led_ctrl_regs_e;

  // Control/Status Registers
  //
  //  LED_CTRL_REG  = 00  RW
  //  DEVICE_ID_REG = 01  RO
  //
  //
  logic [9:0] led_ctrl_q;
  localparam logic [DataWidth-1:0] DEVICE_ID = DataWidth'(32'h1234_5678);

  // LED peripheral does not need to stall
  assign csr_waitrequest = 1'b0;

  // Write Interface
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      led_ctrl_q <= '0;
    end else begin

      if (csr_write && !csr_waitrequest) begin
        unique case (csr_address)
          ADDR_LED_CTRL: led_ctrl_q <= csr_writedata[9:0];
          default: ;
        endcase
      end
    end
  end

  // Read Interface
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      csr_readdatavalid <= 1'b0;
      csr_readdata <= '0;
    end else begin

      csr_readdatavalid <= csr_read && !csr_waitrequest;

      if (csr_read && !csr_waitrequest) begin
        unique case (csr_address)
          ADDR_LED_CTRL: csr_readdata <= DataWidth'(led_ctrl_q);
          ADDR_DEVICE_ID: csr_readdata <= DEVICE_ID;
          default: csr_readdata <= '0;
        endcase
      end

    end


  end


  // Application-specific output assignments
  assign led_o = led_ctrl_q;


endmodule

`resetall
