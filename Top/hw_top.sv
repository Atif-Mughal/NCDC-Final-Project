module hw_top;
    bit clock;

    axi4_if axi_vif(clock);

    always
        #5 clock = ~clock;

endmodule
