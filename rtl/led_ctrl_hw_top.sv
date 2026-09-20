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

    output wire [12:0] hps_ddr3_a,        //
    output wire [ 2:0] hps_ddr3_ba,       //
    output wire        hps_ddr3_ck_p,     //
    output wire        hps_ddr3_ck_n,     //
    output wire        hps_ddr3_cke,      //
    output wire        hps_ddr3_cs_n,     //
    output wire        hps_ddr3_ras_n,    //
    output wire        hps_ddr3_cas_n,    //
    output wire        hps_ddr3_we_n,     //
    output wire        hps_ddr3_reset_n,  //
    inout  wire [ 7:0] hps_ddr3_dq,       //
    inout  wire        hps_ddr3_dqs_p,    //
    inout  wire        hps_ddr3_dqs_n,    //
    output wire        hps_ddr3_odt,      //
    output wire        hps_ddr3_dm,       //
    input  wire        hps_ddr3_rzq,      //

    // Application-specific output
    output wire logic [9:0] led_o
);


  hw_top u0 (
      .clk_i_clk         (clk_i),             //  clk_i.clk
      .leds_output      (led_o),             //  led_o.output
      .memory_mem_a      (hps_ddr3_a),        // memory.mem_a
      .memory_mem_ba     (hps_ddr3_ba),       //       .mem_ba
      .memory_mem_ck     (hps_ddr3_ck_p),     //       .mem_ck
      .memory_mem_ck_n   (hps_ddr3_ck_n),     //       .mem_ck_n
      .memory_mem_cke    (hps_ddr3_cke),      //       .mem_cke
      .memory_mem_cs_n   (hps_ddr3_cs_n),     //       .mem_cs_n
      .memory_mem_ras_n  (hps_ddr3_ras_n),    //       .mem_ras_n
      .memory_mem_cas_n  (hps_ddr3_cas_n),    //       .mem_cas_n
      .memory_mem_we_n   (hps_ddr3_we_n),     //       .mem_we_n
      .memory_mem_reset_n(hps_ddr3_reset_n),  //       .mem_reset_n
      .memory_mem_dq     (hps_ddr3_dq),       //       .mem_dq
      .memory_mem_dqs    (hps_ddr3_dqs_p),    //       .mem_dqs
      .memory_mem_dqs_n  (hps_ddr3_dqs_n),    //       .mem_dqs_n
      .memory_mem_odt    (hps_ddr3_odt),      //       .mem_odt
      .memory_mem_dm     (hps_ddr3_dm),       //       .mem_dm
      .memory_oct_rzqin  (hps_ddr3_rzq),      //       .oct_rzqin
      .rst_i_reset       (rst_i)              //  rst_i.reset
  );


endmodule

`resetall
