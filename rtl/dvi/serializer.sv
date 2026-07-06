`default_nettype none

module serializer #(
    parameter int unsigned W_DATA = 10
) (
    input  var logic              clk,        // High-speed serial clock (5x pixel clock)
    input  var logic              clk_div,    // Parallel pixel clock
    input  var logic              rst,        // Synchronous reset
    input  var logic [W_DATA-1:0] data_i,
    output var logic              data_o
);

    // In a 7-series FPGA, 10:1 serialization requires two OSERDESE2 primitives
    // configured in Master/Slave mode since a single OSERDESE2 in DDR mode
    // supports up to 8:1 (or 14:1 in cascaded mode, using DATA_WIDTH = 10).

    logic shift_out1;
    logic shift_out2;

    OSERDESE2 #(
        .DATA_RATE_OQ("DDR"),
        .DATA_RATE_TQ("SDR"),
        .DATA_WIDTH(10),
        .INIT_OQ(1'b0),
        .INIT_TQ(1'b0),
        .SRVAL_OQ(1'b0),
        .SRVAL_TQ(1'b0),
        .TRISTATE_WIDTH(1),
        .SERDES_MODE("MASTER")
    ) master (
        .OQ(data_o),
        .TQ(),
        .SHIFTOUT1(),
        .SHIFTOUT2(),
        .CLK(clk),
        .CLKDIV(clk_div),
        .D1(data_i[0]),
        .D2(data_i[1]),
        .D3(data_i[2]),
        .D4(data_i[3]),
        .D5(data_i[4]),
        .D6(1'b0),
        .OCE(1'b1),
        .RST(rst),
        .SHIFTIN1(shift_out1),
        .SHIFTIN2(shift_out2),
        .T1(1'b0),
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),
        .TCE(1'b0)
    );

    OSERDESE2 #(
        .DATA_RATE_OQ("DDR"),
        .DATA_RATE_TQ("SDR"),
        .DATA_WIDTH(10),
        .INIT_OQ(1'b0),
        .INIT_TQ(1'b0),
        .SRVAL_OQ(1'b0),
        .SRVAL_TQ(1'b0),
        .TRISTATE_WIDTH(1),
        .SERDES_MODE("SLAVE")
    ) slave (
        .OQ(),
        .TQ(),
        .SHIFTOUT1(shift_out1),
        .SHIFTOUT2(shift_out2),
        .CLK(clk),
        .CLKDIV(clk_div),
        .D1(data_i[5]),
        .D2(data_i[6]),
        .D3(data_i[7]),
        .D4(data_i[8]),
        .D5(data_i[9]),
        .D6(1'b0),
        .OCE(1'b1),
        .RST(rst),
        .SHIFTIN1(1'b0),
        .SHIFTIN2(1'b0),
        .T1(1'b0),
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),
        .TCE(1'b0)
    );

endmodule

`resetall
