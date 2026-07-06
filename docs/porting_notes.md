# Porting Notes: hardware_raycast to PYNQ-Z2

## Decisions and Reasoning

### 1. Clock Generation (`pynq_test_pattern_top.sv`)
- **Original:** Gowin `rPLL` generated 252 MHz from 27 MHz, then divided by 2 (126 MHz) and 5 (25.2 MHz).
- **Target:** PYNQ-Z2 has a fixed 125 MHz reference clock.
- **Decision:** Used a Xilinx `MMCME2_BASE` (Clocking Wizard primitive) to multiply the 125 MHz clock by 8 (VCO = 1000 MHz) and divide by 8 (125 MHz for serial clock) and 40 (25 MHz for pixel clock). 
- **Reasoning:** Since the PYNQ-Z2 reference clock is exactly 125 MHz, standard VGA 640x480 timing (25.175 MHz) can be closely approximated by a 25.0 MHz pixel clock. 25.0 MHz is a <1% deviation and is universally supported by modern monitors. This avoids fractional synthesis complexities and provides perfectly clean 5x multiplication (125 MHz) required for 10:1 DDR serialization.

### 2. TMDS Serializer (`rtl/dvi/serializer.sv`)
- **Original:** Simple behavioral shift register clocked at 252 MHz (SDR).
- **Target:** Xilinx 7-Series `OSERDESE2` running in DDR mode.
- **Decision:** Replaced the behavioral register with a cascaded Master/Slave `OSERDESE2` pair.
- **Reasoning:** In 7-series FPGAs, a single `OSERDESE2` in DDR mode only supports up to 8:1 serialization. To serialize 10 bits of TMDS data per pixel clock cycle, two `OSERDESE2` primitives must be cascaded in a Master/Slave configuration using `DATA_WIDTH=10`. This mirrors the robust approach used in Digilent's `rgb2dvi` IP, guaranteeing correct high-speed IO timing without relying on fabric routing for shift registers.

### 3. Differential Output Buffer (`rtl/dvi/ds_buf.sv`)
- **Original:** Gowin `TLVDS_OBUF`.
- **Target:** Xilinx `OBUFDS`.
- **Decision:** Replaced the Gowin primitive with Xilinx's standard `OBUFDS` with `IOSTANDARD("TMDS_33")` and `SLEW("FAST")`.
- **Reasoning:** Standard procedure for Xilinx 7-series when driving TMDS/HDMI directly from PL pins.

### 4. HDMI HPD (Hot Plug Detect) Handling
- **Original:** Not handled (or board-specific).
- **Target:** PYNQ-Z2 `hdmi_tx_hpdn` (Pin R19).
- **Decision:** Tied `hdmi_tx_hpdn` to `1'b1` (high) as an output in `pynq_test_pattern_top.sv`.
- **Reasoning:** While typically an input from the monitor, on boards where TMDS lines are wired directly to the PL, this pin is sometimes connected to an inline level shifter's Output Enable (OE). Driving it high guarantees that if a level shifter exists on this path, it is enabled, fulfilling the requirement that HPD/HDMI out is "driven appropriately" to let the monitor recognize the source.

### 5. Button Polarity
- **Original:** Active-low buttons (`keys = ~keys_inv_i`).
- **Target:** PYNQ-Z2 pushbuttons.
- **Decision:** Mapped `keys` directly without inversion.
- **Reasoning:** PYNQ-Z2 pushbuttons (BTN0-3) and switches (SW0-1) are active-high. Inverting them would result in permanently pressed virtual buttons.

### 6. Build System (`vivado/build.tcl`)
- **Original:** Gowin IDE project or synthesis script.
- **Target:** Xilinx Vivado.
- **Decision:** Created a non-project batch-mode Tcl script.
- **Reasoning:** Allows for quick, reproducible, and headless builds from the command line without cluttering the repository with large Vivado `.xpr` project files.
