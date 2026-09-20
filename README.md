# Avalon-MM LED Demo

This project demonstrates control of the DE1-SoC user LEDs from the Hard Processor System (HPS) through the **Lightweight HPS-to-FPGA bridge**. The FPGA fabric exposes a small Avalon Memory-Mapped (Avalon-MM) LED controller, allowing Linux software running on the HPS to read and write FPGA registers.

At a high level, the data path is:

```text
HPS/Linux
   |
   | Lightweight HPS-to-FPGA Bridge
   v
Platform Designer Interconnect
   |
   | Avalon-MM
   v
LED Controller
   |
   v
DE1-SoC LEDs
```

The project is intended as a small hardware/software co-design example showing how an HPS application can access a custom memory-mapped FPGA peripheral.

## Prerequisites

### FPGA project

- **Quartus Prime Lite 26.1**
- Terasic DE1-SoC development board

### Testbench

The supplied testbench is run with:

- **Cadence Xcelium 25.09**

A different SystemVerilog simulator may also be used, but the supplied `run.f` file and commands are written for Xcelium and may require modification for another simulator.

## Running the Testbench

From the testbench directory, run:

```bash
xrun -f run.f
```

The `run.f` file is the Xcelium file list for the simulation. It centralizes the source-file paths and simulator options required to compile and run the DUT and testbench, so they do not need to be entered individually on the command line.

To launch the Xcelium graphical interface, append the `-gui` option:

```bash
xrun -f run.f -gui
```

## Creating the Quartus Project

The Quartus project can be recreated using the supplied `create_project.tcl` script. From the directory containing the script, run:

```bash
quartus_sh -t create_project.tcl
```

The script defines the project device, top-level entity, RTL source files, pin assignments, I/O standards, timing constraints, and build-output location required for the demo.

After running the script, open the generated `avalon-mm-led-demo.qpf` project in Quartus Prime Lite.

## Running the Demo from the HPS

After programming the FPGA and booting Linux on the DE1-SoC HPS, connect to the board over SSH:

```bash
ssh user@server
```

Replace `user@server` with the username and network address assigned to your board.

The Avalon-MM peripheral is exposed to the HPS through the Lightweight HPS-to-FPGA bridge. Linux can access the registers directly using `devmem2`.

### LED control register

The LED control register is located at HPS address `0x07200000`.

Read the current LED register value:

```bash
devmem2 0x07200000 w
```

Write a value to the LEDs, for example enabling all ten user LEDs:

```bash
devmem2 0x07200000 w 0x3FF
```

Only the lower ten bits are used for the ten DE1-SoC user LEDs.

### Fake device register

The demo also provides a read-only fake device register at Avalon-MM register address `1`. Because the Avalon-MM interface uses 32-bit words, register address `1` appears to the HPS at byte offset `0x4`:

```bash
devmem2 0x07200004 w
```

## Address Map

Platform Designer handles the address decoding between the HPS Lightweight bridge and the Avalon-MM LED controller. The HPS sees the peripheral beginning at base address `0x07200000`, with a `0x10`-byte address span (`0x0` through `0xF`).

For a 32-bit Avalon-MM slave, each Avalon register address advances by four bytes in the HPS address space:

| Avalon-MM Address | HPS Offset | HPS Address | Access | Description |
|---:|---:|---:|:---:|---|
| `0` | `0x0` | `0x07200000` | R/W | LED control register |
| `1` | `0x4` | `0x07200004` | R | Fake device register |
| `2` | `0x8` | `0x07200008` | — | Unused / reserved |
| `3` | `0xC` | `0x0720000C` | — | Unused / reserved |

In other words, Platform Designer assigns the LED controller a `0x0-0xF` region within the FPGA-side address map, while the HPS accesses that same region beginning at `0x07200000`:

```text
HPS address       HPS offset       Avalon address
0x07200000   ->      0x0      ->        0
0x07200004   ->      0x4      ->        1
0x07200008   ->      0x8      ->        2
0x0720000C   ->      0xC      ->        3
```

This address translation allows software running on the HPS to interact with the custom Avalon-MM peripheral using ordinary memory-mapped reads and writes.
