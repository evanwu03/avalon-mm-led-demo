//------------------------------------------------------------------------------
// Author: Evan Wu
// Date: 9/10/2026
//
// Module: led_ctrL-tb
// Description: testbench module for avalon_mm_led_ctrl
//------------------------------------------------------------------------------

`timescale 1ns / 100ps
`default_nettype none

module led_ctrl_tb;

  localparam int AddressWidth = 2;
  localparam int DataWidth = 32;
  localparam int CLK_PERIOD_NS = 20;

  // Local Register addresses
  localparam int ADDR_LED_CTRL = 2'd0;
  localparam int ADDR_DEVICE_ID = 2'd1;

  // Device ID register value
  localparam logic [DataWidth-1:0] DEVICE_ID = DataWidth'(32'h1234_5678);


  // Clock reset
  logic clk_i;
  logic rst_i;

  // Avalon-MM interface signals
  logic [AddressWidth-1:0] csr_address;
  logic csr_write;
  logic [DataWidth-1:0] csr_writedata;
  logic csr_read;
  logic [DataWidth-1:0] csr_readdata;
  logic csr_waitrequest;
  logic csr_readdatavalid;

  // LED output
  logic [9:0] led_o;

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


  // Generate 50 MHz clock
  initial clk_i = 1'b0;
  always #(CLK_PERIOD_NS / 2) clk_i = ~clk_i;


  // Initial inputs
  initial begin
    rst_i = 1'b0;

    csr_address = '0;
    csr_write = 1'b0;
    csr_writedata = '0;
    csr_read = 1'b0;

  end


  initial begin
    test_write_all_leds();
    test_walking_led();
    test_read_device_id();
    repeat (5) @(posedge clk_i);
    $finish;
  end


  task automatic reset_dut();
    $display("[RESET] Resetting DUT...");
    rst_i = 1'b1;
    repeat (2) @(posedge clk_i);
    rst_i = 1'b0;
    repeat (5) @(posedge clk_i);
    $display("[RESET] Device coming out of reset");
  endtask


  // ------------------------------------------------------------
  // Avalon-MM write
  // ------------------------------------------------------------
  task automatic reg_write(input logic [1:0] address, input logic [31:0] data);

    // Drive half a cycle before DUT samples
    @(negedge clk_i);

    csr_address   = address;
    csr_writedata = data;
    csr_write     = 1'b1;
    csr_read      = 1'b0;

    // DUT accepts write here
    @(posedge clk_i);

    // Remove request after acceptance
    @(negedge clk_i);

    csr_write     = 1'b0;
    csr_address   = '0;
    csr_writedata = '0;

  endtask


  // ------------------------------------------------------------
  // Avalon-MM read
  // ------------------------------------------------------------
  task automatic reg_read(input logic [1:0] address, output logic [31:0] data);

    @(negedge clk_i);

    csr_address = address;
    csr_read    = 1'b1;
    csr_write   = 1'b0;

    // Read command accepted by DUT
    @(posedge clk_i);

    // Your DUT registers readdata/readdatavalid at this edge.
    // Sample at the next negedge so NBA updates are finished.
    @(negedge clk_i);

    if (!csr_readdatavalid) begin
      $error("Expected csr_readdatavalid for read address %0h", address);
    end

    data = csr_readdata;

    csr_read    = 1'b0;
    csr_address = '0;

  endtask


  // ------------------------------------------------------------
  // test_write_all_leds
  // ------------------------------------------------------------
  task automatic test_write_all_leds();

    logic [31:0] write_data;

    $display("[TEST]: Start of test_write_all_leds");

    reset_dut();

    for (int i = 0; i < 10; i++) begin

      write_data = 32'(1 << i);

      reg_write(ADDR_LED_CTRL, write_data);

      if (led_o !== write_data[9:0]) begin
        $error("LED test failed: LED %0d expected=%10b actual=%10b", i, write_data[9:0], led_o);
      end else begin
        $display("LED %0d PASS: (LED_CTRL)=%10b", i, led_o);
      end
    end

    $display("[TEST]: End of test_write_all_leds");
  endtask


  // ------------------------------------------------------------
  // test_read_device_id
  // ------------------------------------------------------------
  task automatic test_read_device_id();

    logic [31:0] read_data;

    $display("[TEST]: Start of test_read_device_id");

    reset_dut();

    reg_read(ADDR_DEVICE_ID, read_data);

    if (read_data != DEVICE_ID) begin
      $error("DEVICE_ID read test failed: expected=%h actual %h", DEVICE_ID, read_data);
    end else begin
      $display("DEVICE_ID read test PASS");
    end

    $display("[TEST]: End of test_read_device_id");
  endtask


  // ------------------------------------------------------------
  // test_walking_led
  // ------------------------------------------------------------
  task automatic test_walking_led();

    logic [9:0] expected;


    $display("[TEST]: Start of test_walking_led");
    reset_dut();


    @(negedge clk_i);

    csr_address = ADDR_LED_CTRL;
    csr_write   = 1'b1;
    csr_read    = 1'b0;

    expected = '0;

    for (int i = 0; i < 10; i++) begin

      expected[i]   = 1'b1;
      //csr_writedata = {{22{1'b0}}, expected};
      csr_writedata = {22'(1'b0), expected};

      // Write accepted
      @(posedge clk_i);

      // Check after the register's NBA update,
      // while also preparing next write.
      @(negedge clk_i);

      if (led_o !== expected) begin
        $error("LED %0d failed: expected=%10h actual=%10h", i, expected, led_o);
      end else begin
        $display("LED %0d PASS: (LED_CTRL)=%10b", i, led_o);
      end

    end

    csr_write     = 1'b0;
    csr_address   = '0;
    csr_writedata = '0;

    $display("[TEST]: End of test_walking_led");

  endtask
endmodule

`resetall
