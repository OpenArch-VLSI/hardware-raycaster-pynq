# Hardware Raycaster (PYNQ-Z2 Port)

This is a port of the [hardware_raycast](https://github.com/m-byte918/hardware_raycast) project to the Digilent/TUL PYNQ-Z2 (Xilinx Zynq-7020) board.

## Current Status
- The RTL has been fully adapted for Xilinx 7-series.
- Gowin-specific IP (rPLL, CLKDIV, TLVDS_OBUF, shift register serializer) has been replaced with Xilinx primitives (`MMCME2_ADV`, `OBUFDS`, `OSERDESE2` Master/Slave cascade).
- A new top-level module (`pynq_z2_top.sv`) currently drives a **test pattern** (Color Bars) through the DVI pipeline instead of the raycaster logic, to verify the video output pipeline.
- Constraints (`pynq-z2.xdc`) are fully defined for the 125 MHz clock, buttons, switches, and HDMI TX.
- A Vivado non-project batch build script (`vivado/build.tcl`) is included.

## Next Steps

1. **Build the Bitstream:**
   Run the Vivado build script to generate the bitstream:
   ```bash
   cd vivado
   vivado -mode batch -source build.tcl
   ```
   *(Note: The automated environment did not have Vivado installed on the PATH to execute this step).*

2. **Program the Board:**
   - Power on the PYNQ-Z2 board.
   - Connect an HDMI monitor to the HDMI TX port.
   - Program the generated bitstream (`project/hardware-raycaster-pynq.runs/impl_1/pynq_z2_top.bit`) onto the FPGA.
   
3. **Verify:**
   - You should see vertical color bars (Red, Green, Blue) on the monitor at 640x480 resolution.
   - If successful, the next phase is to wire up the actual `raycast_top` module in `pynq_z2_top.sv` to render the game!

See `docs/porting_notes.md` for a detailed log of all porting decisions and architectural changes.
