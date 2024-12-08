module hw_top;
    bit clock;

    axi4_if wish_vif(clock);



    always
        #5 clock = ~clock;

endmodule
