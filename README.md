# Hardware Raycaster PYNQ-Z2 Port

This project is a port of the `hardware_raycast` FPGA design (originally targeting the Gowin Tang Primer 20K) to the Digilent/TUL PYNQ-Z2 board (Xilinx Zynq-7020).

## Current Status
Currently, this repository contains a **test-pattern generator milestone**. The original `raycast_top` is not yet instantiated. Instead, the video pipeline (TMDS encoding, serialization) has been ported to Xilinx primitives, and a basic color-bar test pattern is driven to the HDMI TX port to verify the physical layer and clocking.

## Porting Details
- **Target Part:** `xc7z020clg400-1` (Zynq-7020 on PYNQ-Z2)
- **Clocking:** Uses a Xilinx `MMCME2_ADV` to derive a 25.0 MHz pixel clock and 125.0 MHz serial clock from the PYNQ-Z2's 125 MHz board clock.
- **Serialization:** Uses a cascaded Master/Slave `OSERDESE2` pair to perform 10:1 DDR serialization.
- **Differential IO:** Uses `OBUFDS` primitives configured for `TMDS_33`.

For detailed decisions on the port, see `docs/porting_notes.md`.

## Building the Bitstream

Since this uses a non-project batch build, you do not need to open the Vivado GUI.

1. Open a terminal with Vivado in your PATH.
2. Navigate to the root of this project repository.
3. Run the build script:
   ```bash
   C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat -mode batch -source vivado/build.tcl
   ```
4. Once the build finishes, the output bitstream `pynq_test_pattern.bit` will be available in the root directory.
5. Timing and utilization reports will be saved in the `docs/` directory.

## License
The original `hardware_raycast` project is MIT licensed. The serialization logic is inspired by Digilent's `rgb2dvi` core (BSD-3-Clause).
