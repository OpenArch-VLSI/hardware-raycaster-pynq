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
