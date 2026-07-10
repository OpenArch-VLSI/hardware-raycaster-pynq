# Hardware Raycaster — PYNQ-Z2 Implementation Guide

## 1. Project Overview

This project implements a raycasting renderer running entirely in the FPGA fabric. It generates a 640×480 resolution output at a 25 MHz pixel clock. The video is driven to an HDMI output using TMDS via the `dvi_top` module instantiated inside `raycast_top`. The design runs on a PYNQ-Z2 board with an xc7z020clg400-1 FPGA.

## 2. Repository Structure

  rtl/
    raycaster_pynq_z2_top.sv
    raycast_top.sv
    column_calc.sv
    controls.sv
    render.sv
    dda.sv
    newton_inv.sv
    position.sv
    rotation.sv
    pynq_z2_top.sv
    include/
      dvi_pkg.svh
      fixp_pkg.svh
      tex_pkg.svh
    dvi/
      delay.sv
      dvi_sync.sv
      tmds_encoder.sv
      serializer.sv
      ds_buf.sv
      dvi_top.sv
    memfiles/
      map.mem
      textures.mem
      recode_lut.mem
  constraints/
    pynq-z2.xdc
  vivado/
    build.tcl
    project/
  docs/
    timing_summary.rpt
    utilization.rpt
    implementation_guide.md

## 3. Module Hierarchy

  raycaster_pynq_z2_top
    └── MMCME2_ADV        (clock generation)
    └── debounce (×4)     (one per button)
    └── raycast_top
          └── render
                └── column_calc
                      └── dda
                      └── newton_inv
          └── controls
                └── position
                └── rotation
          └── dvi_top

## 4. Clock Architecture

  Input:      125 MHz (pin H16, sysclk)
  serial_clk: 125 MHz
  px_clk:     25 MHz

The input clock (sysclk) drives the MMCME2_ADV module, which generates the serial and pixel clocks. The `px_clk` (25 MHz) drives the button debounce logic. Both `serial_clk` (125 MHz) and `px_clk` (25 MHz) drive the `raycast_top` module for the raycaster and HDMI generation.

## 5. Port Map and Pin Constraints

Table 1 — raycaster_pynq_z2_top external ports:
| Port | Direction | Width | PACKAGE_PIN | IOSTANDARD | Notes |
|---|---|---|---|---|---|
| sysclk | input | 1 | H16 | LVCMOS33 | |
| btn_i | input | 4 | btn_i[0]=D19, btn_i[1]=D20, btn_i[2]=L20, btn_i[3]=L19 | LVCMOS33 | |
| hdmi_out_hpd | input | 1 | R19 | LVCMOS33 | |
| tmds_data_p | output | 3 | tmds_data_p[0]=K17, tmds_data_p[1]=K19, tmds_data_p[2]=J18 | TMDS_33 | |
| tmds_data_n | output | 3 | tmds_data_n[0]=K18, tmds_data_n[1]=J19, tmds_data_n[2]=H18 | TMDS_33 | |
| tmds_clk_p | output | 1 | L16 | TMDS_33 | |
| tmds_clk_n | output | 1 | L17 | TMDS_33 | |

Table 2 — Button-to-raycaster mapping:
| Physical Button | PACKAGE_PIN | raycast_top port | Function |
|---|---|---|---|
| BTN0 | D19 | key_forward_i | Move Forward |
| BTN1 | D20 | key_backward_i | Move Backward |
| BTN2 | L20 | key_rotate_left_i | Rotate Left |
| BTN3 | L19 | key_rotate_right_i | Rotate Right |

Note: The `key_left_i` and `key_right_i` ports on `raycast_top` are tied to 0 in the wrapper.

## 6. Build Instructions

### Prerequisites
- Vivado 2025.2 installed at C:\AMDDesignTools\2025.2\
- PYNQ-Z2 board files installed in Vivado

### Building the Bitstream

  1. Open a PowerShell window.
  2. cd C:\Users\nayak\hardware-raycaster-pynq\vivado
  3. Run: C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat -mode batch -source build.tcl
  4. Wait for "write_bitstream completed successfully" in the console.
     This takes approximately 10 minutes.
  5. Confirm the bitstream exists:
     Get-Item vivado\project\hardware-raycaster-pynq.runs\impl_1\raycaster_pynq_z2_top.bit

### Verifying the Build

  Check 1 — Should show "0 Errors":
    Select-String "Errors encountered" vivado\project\hardware-raycaster-pynq.runs\synth_1\runme.log

  Check 2 — WNS must be ≥ 0:
    Select-String "WNS" docs\timing_summary.rpt | Select-Object -First 5

  Check 3 — Bitstream must exist:
    Get-Item vivado\project\hardware-raycaster-pynq.runs\impl_1\raycaster_pynq_z2_top.bit | Select-Object Name, Length, LastWriteTime

  Expected values (from the successful build):
    WNS: 29.275 ns
    Bitstream size: 4,045,697 bytes

## 7. Programming the Board

  1. Connect the PYNQ-Z2 to the PC via the micro-USB cable into
     the port labelled PROG/UART (not the OTG port on the side).
  2. Power on the board using the toggle switch near the barrel
     jack. The red power LED should illuminate.
  3. Open Vivado 2025.2.
  4. In the Flow Navigator (left panel), click "Open Hardware Manager".
  5. At the top of the Hardware Manager window, click
     "Open Target" → "Auto Connect".
     You should see "xc7z020_1" appear in the Hardware panel.
  6. Right-click "xc7z020_1" → "Program Device".
  7. In the Bitstream File field, browse to:
       vivado\project\hardware-raycaster-pynq.runs\impl_1\raycaster_pynq_z2_top.bit
  8. Click "Program". The board LEDs will flicker briefly.
  9. Connect an HDMI cable from the board's HDMI-OUT port (labelled
     TX on the board silkscreen) to a monitor.
 10. The monitor should display the raycaster output within
     1-2 seconds. No Linux boot is required — the design runs
     entirely in the FPGA fabric.

### What to expect
  - The monitor should receive a 640×480 signal automatically.
  - If the monitor shows "No Signal", verify you are using the
    TX port (not the RX port).
  - Press BTN0-BTN3 to move. See Section 5, Table 2 for the
    button-to-movement mapping.

## 8. Controls

- BTN0: Move Forward
- BTN1: Move Backward
- BTN2: Rotate Left
- BTN3: Rotate Right

Left and Right movement (strafing) is not mapped to a physical button in this build.

## 9. Known Issues and Limitations

- Left and Right movement inputs are unconnected.
- Resolution is fixed at 640×480. Changing it requires modifying
  dvi_pkg and rebuilding.

## 10. What Was Fixed to Make This Build Work

### Fix 1 — column_calc.sv: Vivado type() on cast expressions
The problem was that Vivado cannot resolve a typedef name inside type() when its argument is a cast expression like TypeName'(sig).

The symptoms were Synth 8-660 errors indicating that the type could not be resolved during elaboration.

The fix was to introduce intermediate combinatorial signals side_x_ext, side_y_ext, and a localparam FRAME_HEIGHT_FIXP, avoiding the direct use of type() on cast expressions.

### Fix 2 — pynq-z2.xdc: TMDS port name mismatch
The problem was that the XDC used Digilent master template names like hdmi_tx_clk_p, while the RTL used tmds_clk_p etc.

The symptoms were 8 CRITICAL WARNINGs on set_property, DRC UCIO-1 errors, and no bitstream being generated.

The fix was to rename the 9 get_ports strings in the constraints file to exactly match the RTL ports.

## 11. Build Results

  Synthesis:   0 errors, 0 critical warnings, 17 warnings
  WNS:         29.275 ns (clk_25_unbuf)
  Bitstream:   raycaster_pynq_z2_top.bit — 4,045,697 bytes — 7/9/2026 8:10:39 PM
  Git commits: Fix XDC: rename TMDS port names to match raycaster_pynq_z2_top
               Add impl reports: successful raycaster_pynq_z2_top bitstream build
