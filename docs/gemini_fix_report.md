# PYNQ-Z2 Hardware Raycaster Port: Bug Fix and Cleanup Report

## What Changed and Why

### 1. RTL Bug Fixes (`rtl/pynq_z2_top.sv`)
- **HPD Wiring Fix:** The `hdmi_out_hpd` port was incorrectly defined as an `output` and driven to `1'b1`. According to the TUL PYNQ-Z2 Reference Manual v1.1 (Table 7), the Hot-Plug-Detect (HPD) pin on the HDMI OUT connector is driven by the monitor toward the FPGA. Therefore, the pin was changed to an `input` and the constant assignment was removed. This resolved a "driven by constant" synthesis warning and adheres to the electrical design of the board.
- **Serial Clock Frequency Fix:** The `MMCME2_ADV` instance was dividing the 1000 MHz VCO by 4, producing a 250 MHz serial clock. However, the `OSERDESE2` cascade in DDR mode with `DATA_WIDTH=10` requires exactly a 5x multiplier relative to the 25 MHz pixel clock. The divider `CLKOUT0_DIVIDE_F` was changed from `4.000` to `8.000` to produce the correct 125 MHz serial clock. Signal names and comments were updated to reflect this fix.

### 2. Documentation and Project Cleanup
- **Porting Notes Updated:** Corrected the Clocking and HDMI Output sections in `docs/porting_notes.md` to document the 125 MHz clock requirement and the HPD input correction.
- **Legacy Files Removed:** Since `pynq_z2_top.sv` now successfully builds cleanly, the outdated `pynq_test_pattern_top.sv`, `constraints/pynq_z2.xdc` (underscore version), and `vivado/create_project.tcl` have been deleted.
- **GUI Script Updated:** `vivado/open_gui.tcl` was modified to point to the correct top module (`pynq_z2_top`) and constraint file (`pynq-z2.xdc`).
- **User Docs Cleaned:** Removed over 40 stray python scripts, duplicate markdown drafts, and text scratch files from the `user docs` folder, retaining only the core sequence of 9 design documents (`00_README.md` through `08_fixed_point_formats.md`).

## Verification

### Synthesis Log
The synthesis log confirms zero errors and zero critical warnings. Notably, the previous "driven by constant" warning on `hdmi_out_hpd` is completely gone.

Excerpt from `vivado\project\hardware-raycaster-pynq.runs\synth_1\runme.log`:
```
Synthesis finished with 0 errors, 0 critical warnings and 7 warnings.
...
42 Infos, 27 Warnings, 0 Critical Warnings and 0 Errors encountered.
```

### Timing Summary
The timing report confirms the design met all timing constraints with positive slack.

Excerpt from `docs/timing_summary.rpt`:
```
    WNS(ns)      TNS(ns)  TNS Failing Endpoints  TNS Total Endpoints      WHS(ns)      THS(ns)  THS Failing Endpoints  THS Total Endpoints     WPWS(ns)     TPWS(ns)  TPWS Failing Endpoints  TPWS Total Endpoints  
    -------      -------  ---------------------  -------------------      -------      -------  ---------------------  -------------------     --------     --------  ----------------------  --------------------  
     33.056        0.000                      0                  191        0.119        0.000                      0                  191        2.000        0.000                       0                   100  
```

## Git History

```
82ca1e4 Add new build reports
1bfd5b2 Cleanup stray scripts and scratch files in user docs
a32ad39 Cleanup legacy files and update GUI script
ec4b296 Correct Clocking and HDMI Output Pins & HPD sections
2c689dd Fix HPD wiring and Serial clock frequency bugs
```

## What I Could Not Verify
- **Hardware Behavior:** I cannot see a monitor and cannot program physical hardware. I can only verify that the design synthesizes cleanly, implements successfully, generates a bitstream, and meets timing. The actual HDMI output and visual correctness must be verified on a physical PYNQ-Z2 board.
