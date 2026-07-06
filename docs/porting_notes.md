# Porting Notes: Tang Primer 20K to PYNQ-Z2

This document details the decisions made while porting the `hardware_raycast` project to the PYNQ-Z2 board.

## Clocking
- **Decision:** Used `MMCME2_ADV` to multiply the 125 MHz reference clock up to 1000 MHz, then divided it down to 250 MHz (Serial TMDS Clock) and 25 MHz (Pixel Clock).
- **Reasoning:** 640x480 standard VGA timing uses a 25.175 MHz pixel clock. Synthesizing exactly 25.175 MHz from 125 MHz requires complex fractional PLL settings which can introduce jitter and limit performance. A 25.0 MHz pixel clock results in a ~59.5 Hz refresh rate, which is within the tolerance of virtually all modern HDMI/DVI monitors.
- **Alternatives Considered:** Fractional multipliers (`CLKFBOUT_MULT_F = 37.8`) were considered but `OSERDESE2` high-speed clocks are better generated with integer divides where possible, and 25.0 MHz is a safe and reliable approximation.

## Serializer
- **Decision:** Implemented a 10:1 Master/Slave cascaded `OSERDESE2` structure in DDR mode (5:1 DDR).
- **Reasoning:** The 7-series `OSERDESE2` primitive only supports up to 8:1 serialization. To achieve the 10:1 serialization required for TMDS (10 bits per pixel), two `OSERDESE2` instances must be cascaded. This structure was adapted from Digilent's BSD-3 `rgb2dvi` reference design.
- **Data ordering:** `OSERDESE2` sends `D1` first. TMDS requires the LSB to be sent first. A `generate` loop maps `data_i[0]` to the first transmitted bit (`D1` of Slave, via `pDataOut_q[14]`, based on the cascading).

## HDMI Output Pins & HPD
- **Decision:** Replaced the Gowin `TLVDS_OBUF` with Xilinx `OBUFDS` for the differential TMDS data and clock signals.
- **Decision:** Explicitly tied the HDMI HPD (Hot Plug Detect) pin (R19) to `1'b1`.
- **Reasoning:** Unlike simpler FPGA boards that pull HPD high with a physical resistor, the PYNQ-Z2 routes the HPD signal directly to the FPGA PL. If this pin is left floating or driven low, the connected monitor may assume no source is connected and remain in sleep mode, ignoring valid TMDS data.

## Buttons and Switches
- **Decision:** Mapped the 4 buttons and 2 switches on the PYNQ-Z2 to the `keys` inputs, and omitted the active-low inversion.
- **Reasoning:** The original Gowin design used active-low buttons (`keys_inv_i`). The PYNQ-Z2 uses active-high buttons and switches. Therefore, the `~` inversion was removed in `pynq_z2_top.sv`.

## Reset Strategy
- **Decision:** Removed the external reset pin (`rst_n`).
- **Reasoning:** The PYNQ-Z2 has only 6 inputs (4 buttons, 2 switches), all of which are needed for the 6 movement controls of the raycaster. Instead of mapping a button to reset, the design now relies entirely on the internal power-on reset counter, ensuring the system resets correctly upon bitstream configuration.
