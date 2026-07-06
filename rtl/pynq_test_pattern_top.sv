`default_nettype none

module pynq_test_pattern_top (
    input  var logic       clk,      // 125 MHz board clock
    input  var logic [3:0] btns_4bits_tri_i, // 4 buttons
    input  var logic [1:0] sws_2bits_tri_i,  // 2 switches

    output var logic [2:0] tmds_data_p,
    output var logic [2:0] tmds_data_n,
    output var logic       tmds_clk_p,
    output var logic       tmds_clk_n,

    input  var logic       hdmi_out_hpd_i  // monitor asserts this; we only read it, never drive it
);

    // Map buttons to the expected generic keys interface.
    // The original Gowin used active-low, but PYNQ uses active-high buttons.
    // We map them directly (1:1).
    logic [5:0] keys;
    assign keys = {sws_2bits_tri_i, btns_4bits_tri_i};

    // HDMI Hot Plug Detect (Active low/level shifter OE)
    // We only read this, never drive it.

    // Clocking
    logic clk_fb;
    logic serial_clk_unbuf;
    logic pixel_clk_unbuf;
    logic serial_clk;
    logic pixel_clk;
    logic pll_locked;

    // We generate 125 MHz and 25 MHz. 25 MHz is within 1% of 25.2 MHz.
    MMCME2_BASE #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKFBOUT_MULT_F(8.000),      // VCO = 125 MHz * 8 = 1000 MHz
        .DIVCLK_DIVIDE(1),
        .CLKIN1_PERIOD(8.000),        // 125 MHz input
        .CLKOUT0_DIVIDE_F(8.000),     // 1000 MHz / 8 = 125 MHz (serial)
        .CLKOUT1_DIVIDE(40)           // 1000 MHz / 40 = 25 MHz (pixel)
    ) mmcm_inst (
        .CLKFBOUT(clk_fb),
        .CLKOUT0(serial_clk_unbuf),
        .CLKOUT1(pixel_clk_unbuf),
        .CLKOUT2(), .CLKOUT3(), .CLKOUT4(), .CLKOUT5(), .CLKOUT6(),
        .LOCKED(pll_locked),
        .CLKIN1(clk),
        .PWRDWN(1'b0),
        .RST(1'b0),
        .CLKFBIN(clk_fb)
    );

    BUFG bufg_serial (.I(serial_clk_unbuf), .O(serial_clk));
    BUFG bufg_pixel (.I(pixel_clk_unbuf), .O(pixel_clk));

    // Reset generator
    logic [7:0] rst_cnt = '1;
    logic rst;

    always_ff @(posedge pixel_clk) begin
        if (!pll_locked) begin
            rst_cnt <= '1;
        end else if (rst_cnt != 0) begin
            rst_cnt <= rst_cnt - 1'b1;
        end
    end
    assign rst = (rst_cnt != 0);

    // Test pattern generator (Color Bars)
    logic [9:0] pixel_x;
    logic [8:0] pixel_y;
    logic       in_range;

    logic [7:0] red_test;
    logic [7:0] green_test;
    logic [7:0] blue_test;

    always_comb begin
        if (in_range) begin
            if (pixel_x < 213) begin
                red_test   = 8'hFF;
                green_test = 8'h00;
                blue_test  = 8'h00;
            end else if (pixel_x < 426) begin
                red_test   = 8'h00;
                green_test = 8'hFF;
                blue_test  = 8'h00;
            end else begin
                red_test   = 8'h00;
                green_test = 8'h00;
                blue_test  = 8'hFF;
            end
        end else begin
            red_test   = 8'h00;
            green_test = 8'h00;
            blue_test  = 8'h00;
        end
    end

    // DVI Output
    dvi_top dvi_inst (
        .serial_clk  (serial_clk),
        .pixel_clk   (pixel_clk),
        .rst         (rst),
        .red_i       (red_test),
        .green_i     (green_test),
        .blue_i      (blue_test),
        .x_o         (pixel_x),
        .y_o         (pixel_y),
        .in_range_o  (in_range),
        .tmds_data_p (tmds_data_p),
        .tmds_data_n (tmds_data_n),
        .tmds_clk_p  (tmds_clk_p),
        .tmds_clk_n  (tmds_clk_n)
    );

endmodule

`resetall
