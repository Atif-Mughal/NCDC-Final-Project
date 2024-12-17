/*********************************************
 *                                           *
 *            TOP MODULE: HW_TOP             *
 *                                           *
 *  Description:                             *
 *  - This module generates a clock signal   *
 *    for simulation purposes.               *
 *  - AXI4 interface is instantiated.        *
 *                                           *
 *********************************************/

module hw_top;

    //========================================
    //              SIGNALS
    //========================================
    bit clock; // Clock signal for the module

    //========================================
    //             INTERFACES
    //========================================
    // AXI4 Interface
    axi4_if axi_vif(clock);

    //========================================
    //             CLOCK GENERATION
    //========================================
    // Generates a clock with a period of 10 units
    always
        #5 clock = ~clock; // Toggle clock every 5 time units

endmodule

/*********************************************
 *          END OF HW TOP MODULE                *
 *********************************************/
