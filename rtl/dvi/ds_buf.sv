`default_nettype none

module ds_buf (
    input  var logic in,
    output var logic out,
    output var logic out_n
);

    OBUFDS #(
        .IOSTANDARD("TMDS_33"), // TMDS differential standard
        .SLEW("FAST")
    ) obufds_inst (
        .O(out),
        .OB(out_n),
        .I(in)
    );

endmodule

`resetall
