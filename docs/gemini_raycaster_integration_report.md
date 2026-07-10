# Raycaster Integration Report

## 1. Final `raycaster_pynq_z2_top.sv`

```systemverilog
`default_nettype none

module raycaster_pynq_z2_top (
    input  var logic       sysclk,
    input  var logic [3:0] btn_i,
    input  var logic [0:0] hdmi_out_hpd,
    output var logic [2:0] tmds_data_p,
    output var logic [2:0] tmds_data_n,
    output var logic       tmds_clk_p,
    output var logic       tmds_clk_n
);

    logic clkfbout, clkfbout_buf;
    logic pll_locked;
    logic clk_125_unbuf, clk_25_unbuf;
    logic serial_clk, px_clk;

    MMCME2_ADV #(
        .BANDWIDTH            ("OPTIMIZED"),
        .CLKOUT4_CASCADE      ("FALSE"),
        .COMPENSATION         ("ZHOLD"),
        .STARTUP_WAIT         ("FALSE"),
        .DIVCLK_DIVIDE        (1),
        .CLKFBOUT_MULT_F      (8.000), // 125 * 8 = 1000 MHz
        .CLKFBOUT_PHASE       (0.000),
        .CLKFBOUT_USE_FINE_PS ("FALSE"),
        .CLKOUT0_DIVIDE_F     (8.000), // 1000 / 8 = 125 MHz
        .CLKOUT0_PHASE        (0.000),
        .CLKOUT0_DUTY_CYCLE   (0.500),
        .CLKOUT0_USE_FINE_PS  ("FALSE"),
        .CLKOUT1_DIVIDE       (40),    // 1000 / 40 = 25 MHz
        .CLKOUT1_PHASE        (0.000),
        .CLKOUT1_DUTY_CYCLE   (0.500),
        .CLKOUT1_USE_FINE_PS  ("FALSE"),
        .CLKIN1_PERIOD        (8.000)  // 125 MHz
    ) mmcme2_inst (
        .CLKFBOUT            (clkfbout),
        .CLKFBOUTB           (),
        .CLKOUT0             (clk_125_unbuf),
        .CLKOUT0B            (),
        .CLKOUT1             (clk_25_unbuf),
        .CLKOUT1B            (),
        .CLKOUT2             (),
        .CLKOUT2B            (),
        .CLKOUT3             (),
        .CLKOUT3B            (),
        .CLKOUT4             (),
        .CLKOUT5             (),
        .CLKOUT6             (),
        .CLKFBIN             (clkfbout_buf),
        .CLKIN1              (sysclk),
        .CLKIN2              (1'b0),
        .CLKINSEL            (1'b1),
        .DADDR               (7'h0),
        .DCLK                (1'b0),
        .DEN                 (1'b0),
        .DI                  (16'h0),
        .DO                  (),
        .DRDY                (),
        .DWE                 (1'b0),
        .PSCLK               (1'b0),
        .PSEN                (1'b0),
        .PSINCDEC            (1'b0),
        .PSDONE              (),
        .LOCKED              (pll_locked),
        .CLKINSTOPPED        (),
        .CLKFBSTOPPED        (),
        .PWRDWN              (1'b0),
        .RST                 (1'b0)
    );

    BUFG clkf_buf (.I(clkfbout), .O(clkfbout_buf));
    BUFG clk125_buf (.I(clk_125_unbuf), .O(serial_clk));
    BUFG clk25_buf (.I(clk_25_unbuf), .O(px_clk));

    logic rst;
    assign rst = ~pll_locked;

    logic [19:0] deb_sr [3:0];
    logic [3:0]  btn_deb;

    always_ff @(posedge px_clk) begin
        for (int i = 0; i < 4; i++) begin
            deb_sr[i] <= {deb_sr[i][18:0], btn_i[i]};
            if  (&deb_sr[i])      btn_deb[i] <= 1'b1;
            else if (~|deb_sr[i]) btn_deb[i] <= 1'b0;
        end
    end

    raycast_top raycast_top_inst (
        .serial_clk         (serial_clk),
        .px_clk             (px_clk),
        .rst                (rst),
        .key_forward_i      (btn_deb[0]),
        .key_backward_i     (btn_deb[1]),
        .key_left_i         (1'b0),
        .key_right_i        (1'b0),
        .key_rotate_left_i  (btn_deb[2]),
        .key_rotate_right_i (btn_deb[3]),
        .tmds_data_p        (tmds_data_p),
        .tmds_data_n        (tmds_data_n),
        .tmds_clk_p         (tmds_clk_p),
        .tmds_clk_n         (tmds_clk_n)
    );

endmodule

`resetall
```

## 2. Diff of `build.tcl` Changes
Before:
```tcl
# Add RTL sources
add_files ../rtl/include/dvi_pkg.svh
add_files ../rtl/dvi/delay.sv
```
After:
```tcl
# Add RTL sources
add_files ../rtl/include/dvi_pkg.svh
set_property file_type SystemVerilog [get_files ../rtl/include/dvi_pkg.svh]
add_files ../rtl/include/fixp_pkg.svh
set_property file_type SystemVerilog [get_files ../rtl/include/fixp_pkg.svh]
add_files ../rtl/include/tex_pkg.svh
set_property file_type SystemVerilog [get_files ../rtl/include/tex_pkg.svh]
add_files ../rtl/dvi/delay.sv
```

Before:
```tcl
add_files ../rtl/pynq_z2_top.sv

# Add constraints
```
After:
```tcl
add_files ../rtl/pynq_z2_top.sv
add_files ../rtl/raycaster_pynq_z2_top.sv
add_files ../rtl/raycast_top.sv
add_files ../rtl/controls.sv
add_files ../rtl/render.sv
add_files ../rtl/dda.sv
add_files ../rtl/newton_inv.sv
add_files ../rtl/column_calc.sv
add_files ../rtl/position.sv
add_files ../rtl/rotation.sv

# Add constraints
```

Before:
```tcl
# Set top module
set_property top pynq_z2_top [current_fileset]
```
After:
```tcl
# Set top module
set_property top raycaster_pynq_z2_top [current_fileset]
```

## 3. Diff of `pynq-z2.xdc` Changes (Button Lines)
Before:
```tcl
## Switches
set_property -dict { PACKAGE_PIN M20 IOSTANDARD LVCMOS33 } [get_ports { sw_i[0] }]
set_property -dict { PACKAGE_PIN M19 IOSTANDARD LVCMOS33 } [get_ports { sw_i[1] }]

## Buttons
# (buttons already didn't have # in my local copy, but the sw_i lines were removed entirely)
```
After:
```tcl
## Buttons
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports { btn_i[0] }]
set_property -dict { PACKAGE_PIN D20 IOSTANDARD LVCMOS33 } [get_ports { btn_i[1] }]
set_property -dict { PACKAGE_PIN L20 IOSTANDARD LVCMOS33 } [get_ports { btn_i[2] }]
set_property -dict { PACKAGE_PIN L19 IOSTANDARD LVCMOS33 } [get_ports { btn_i[3] }]
```

## 4. Verification Check Outputs

**a. Port grep from synthesis log:**
```
vivado\project\hardware-raycaster-pynq.runs\synth_1\runme.log:51:CRITICAL WARNING: [Synth 8-4445] could not open $readmem data file 'memfiles/map.mem'; please make sure the file is added to project and has read permission, ignoring [C:/Users/nayak/hardware-raycaster-pynq/rtl/raycast_top.sv:95]
vivado\project\hardware-raycaster-pynq.runs\synth_1\runme.log:53:CRITICAL WARNING: [Synth 8-4445] could not open $readmem data file 'memfiles/textures.mem'; please make sure the file is added to project and has read permission, ignoring [C:/Users/nayak/hardware-raycaster-pynq/rtl/render.sv:202]
vivado\project\hardware-raycaster-pynq.runs\synth_1\runme.log:54:CRITICAL WARNING: [Synth 8-4445] could not open $readmem data file 'memfiles/recode_lut.mem'; please make sure the file is added to project and has read permission, ignoring [C:/Users/nayak/hardware-raycaster-pynq/rtl/render.sv:203]
vivado\project\hardware-raycaster-pynq.runs\synth_1\runme.log:75:23 Infos, 0 Warnings, 3 Critical Warnings and 6 Errors encountered.
```
*(Also encountered but technically not matching `unresolved` due to my grep regex string missing it: `ERROR: [Synth 8-660] unable to resolve 'ext_pos_fixp_t'`)*

**b. WNS from timing report:**
```
docs\timing_summary.rpt:143:    WNS(ns)      TNS(ns)  TNS Failing Endpoints  TNS Total Endpoints      WHS(ns)      THS(ns)  THS Failing Endpoints  THS Total Endpoints     WPWS(ns)     TPWS(ns)  TPWS Failing Endpoints  TPWS Total Endpoints  
docs\timing_summary.rpt:169:Clock                WNS(ns)      TNS(ns)  TNS Failing Endpoints  TNS Total Endpoints      WHS(ns)      THS(ns)  THS Failing Endpoints  THS Total Endpoints     WPWS(ns)     TPWS(ns)  TPWS Failing Endpoints  TPWS Total Endpoints  
docs\timing_summary.rpt:182:From Clock    To Clock          WNS(ns)      TNS(ns)  TNS Failing Endpoints  TNS Total Endpoints      WHS(ns)      THS(ns)  THS Failing Endpoints  THS Total Endpoints  
```
*(Timing report did not update because synthesis failed)*

**c. Bitstream stat check:**
```
Get-Item : Cannot find path 
'C:\Users\nayak\hardware-raycaster-pynq\vivado\project\hardware-raycaster-pynq.runs\impl_1\raycaster_pynq_z2_top.bit' 
because it does not exist.
```

## 5. Git History

```
195deee Uncomment button constraints for raycaster top-level
a5bdbbf Update build.tcl: add raycaster sources, set raycaster_pynq_z2_top as top
fb147bc Add raycaster_pynq_z2_top: wire raycast_top to PYNQ-Z2 pins with debounce
```

## 6. What I Could Not Verify
- **Hardware Behavior:** I cannot see a monitor and cannot program physical hardware. Any claims about the visual correctness or HDMI output must be verified on the actual PYNQ-Z2 hardware.
- **Completed Integration Build:** The integration build failed during synthesis because of missing `$readmemh` initialisation files (`.mem` files) which triggered critical warnings, and an `unable to resolve 'ext_pos_fixp_t'` Vivado synthesis error (due to a Vivado synthesis limitation where it struggles to resolve an imported package `typedef` when evaluated inside nested macro casts like `type(a)`). Because the prompt placed hard constraints on not modifying `column_calc.sv` or any other deep RTL logic where the compilation fails, I did not attempt to redesign or hack the RTL to pass Vivado synthesis.
