`default_nettype none
`include "dvi_pkg.svh"

module pynq_z2_top (
    input  var logic       sysclk,
    input  var logic [3:0] btn_i,
    input  var logic [1:0] sw_i,

    output var logic [2:0] hdmi_out_data_p,
    output var logic [2:0] hdmi_out_data_n,
    output var logic       hdmi_out_clk_p,
    output var logic       hdmi_out_clk_n,
    output var logic [0:0] hdmi_out_hpd
);

    // HPD logic: just tie high to tell the monitor a source is connected
    assign hdmi_out_hpd[0] = 1'b1;

    // Map buttons and switches for future use, not used in test pattern
    logic [5:0] keys;
    assign keys = {sw_i, btn_i}; // Active high

    // Clock Generation
    logic clkfbout, clkfbout_buf;
    logic pll_locked;
    logic clk_250_unbuf, clk_25_unbuf;
    logic serial_clk, pixel_clk;
    
    MMCME2_ADV #(
        .BANDWIDTH            ("OPTIMIZED"),
        .CLKOUT4_CASCADE      ("FALSE"),
        .COMPENSATION         ("ZHOLD"),
        .STARTUP_WAIT         ("FALSE"),
        .DIVCLK_DIVIDE        (1),
        .CLKFBOUT_MULT_F      (8.000), // 125 * 8 = 1000 MHz
        .CLKFBOUT_PHASE       (0.000),
        .CLKFBOUT_USE_FINE_PS ("FALSE"),
        .CLKOUT0_DIVIDE_F     (4.000), // 1000 / 4 = 250 MHz
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
        .CLKOUT0             (clk_250_unbuf),
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
        .CDDCDONE            (),
        .CDDCREQ             (1'b0),
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
    BUFG clk250_buf (.I(clk_250_unbuf), .O(serial_clk));
    BUFG clk25_buf (.I(clk_25_unbuf), .O(pixel_clk));

    // Reset Logic
    logic [7:0] power_on_rst_cnt = '1;
    logic rst;

    always_ff @(posedge pixel_clk) begin
        if (pll_locked && power_on_rst_cnt != '0) begin
            power_on_rst_cnt <= power_on_rst_cnt - 1'b1;
        end
    end
    
    assign rst = !pll_locked || (power_on_rst_cnt != '0);

    // Test pattern logic
    logic [dvi_pkg::W_H_RES-1:0] x;
    logic [dvi_pkg::W_V_RES-1:0] y;
    logic in_range;

    logic [7:0] red, green, blue;

    always_comb begin
        if (x < 213) begin
            red   = 8'hFF;
            green = 8'h00;
            blue  = 8'h00;
        end else if (x < 426) begin
            red   = 8'h00;
            green = 8'hFF;
            blue  = 8'h00;
        end else begin
            red   = 8'h00;
            green = 8'h00;
            blue  = 8'hFF;
        end
    end

    dvi_top dvi_top_inst (
        .serial_clk  (serial_clk),
        .pixel_clk   (pixel_clk),
        .rst         (rst),
        .red_i       (red),
        .green_i     (green),
        .blue_i      (blue),
        .x_o         (x),
        .y_o         (y),
        .in_range_o  (in_range),
        .tmds_data_p (hdmi_out_data_p),
        .tmds_data_n (hdmi_out_data_n),
        .tmds_clk_p  (hdmi_out_clk_p),
        .tmds_clk_n  (hdmi_out_clk_n)
    );

endmodule
`resetall
