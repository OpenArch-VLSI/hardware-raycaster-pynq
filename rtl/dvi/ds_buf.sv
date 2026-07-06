`default_nettype none

module ds_buf (
    input  var logic in,
    output var logic out,
    output var logic out_n
);

    OBUFDS #(
        .IOSTANDARD("TMDS_33")
    ) tmds_buf (
        .I  (in   ),
        .O  (out  ),
        .OB (out_n)
    );

endmodule

`resetall
