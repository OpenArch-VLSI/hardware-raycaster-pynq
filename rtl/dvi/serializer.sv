`default_nettype none

module serializer #(
    parameter int unsigned W_DATA = 10
) (
    input  var logic              clk,    // 250 MHz serial clock
    input  var logic              pixel_clk, // 25 MHz pixel clock
    input  var logic              rst,
    input  var logic [W_DATA-1:0] data_i,
    output var logic              data_o
);

    logic ocascade1, ocascade2;
    logic [13:0] pDataOut_q;

    // TMDS transmits LSB first, OSERDESE2 transmits D1 first
    // We want data_i[0] to be sent first, so it should be mapped to the first bit sent.
    // However, the OSERDES cascade slice order is specific.
    // We map data_i[0] to pDataOut_q[14], data_i[1] to pDataOut_q[13] etc?
    // Let's use the mapping from Digilent rgb2dvi exactly:
    genvar i;
    generate
        for (i = 0; i < W_DATA; i = i + 1) begin : SliceOSERDES_q
            assign pDataOut_q[14 - i - 1] = data_i[i];
        end
    endgenerate

    // Serializer, 10:1 (5:1 DDR), master-slave cascaded
    OSERDESE2 #(
        .DATA_RATE_OQ("DDR"),
        .DATA_RATE_TQ("SDR"),
        .DATA_WIDTH(W_DATA),
        .TRISTATE_WIDTH(1),
        .TBYTE_CTL("FALSE"),
        .TBYTE_SRC("FALSE"),
        .SERDES_MODE("MASTER")
    ) SerializerMaster (
        .OQ(data_o),
        .CLK(clk),
        .CLKDIV(pixel_clk),
        .D1(pDataOut_q[13]),
        .D2(pDataOut_q[12]),
        .D3(pDataOut_q[11]),
        .D4(pDataOut_q[10]),
        .D5(pDataOut_q[9]),
        .D6(pDataOut_q[8]),
        .D7(pDataOut_q[7]),
        .D8(pDataOut_q[6]),
        .OCE(1'b1),
        .RST(rst),
        .SHIFTIN1(ocascade1),
        .SHIFTIN2(ocascade2),
        .T1(1'b0),
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),
        .TBYTEIN(1'b0),
        .TCE(1'b0)
    );

    OSERDESE2 #(
        .DATA_RATE_OQ("DDR"),
        .DATA_RATE_TQ("SDR"),
        .DATA_WIDTH(W_DATA),
        .TRISTATE_WIDTH(1),
        .TBYTE_CTL("FALSE"),
        .TBYTE_SRC("FALSE"),
        .SERDES_MODE("SLAVE")
    ) SerializerSlave (
        .SHIFTOUT1(ocascade1),
        .SHIFTOUT2(ocascade2),
        .CLK(clk),
        .CLKDIV(pixel_clk),
        .D1(1'b0),
        .D2(1'b0),
        .D3(pDataOut_q[5]),
        .D4(pDataOut_q[4]),
        .D5(pDataOut_q[3]),
        .D6(pDataOut_q[2]),
        .D7(pDataOut_q[1]),
        .D8(pDataOut_q[0]),
        .OCE(1'b1),
        .RST(rst),
        .SHIFTIN1(1'b0),
        .SHIFTIN2(1'b0),
        .T1(1'b0),
        .T2(1'b0),
        .T3(1'b0),
        .T4(1'b0),
        .TBYTEIN(1'b0),
        .TCE(1'b0)
    );

endmodule

`resetall
