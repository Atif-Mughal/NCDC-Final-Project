//-----------------------------------------------------------------------------
// MODULE: AXI_top
// DESCRIPTION:
// - The top-level module for simulating the AXI environment with axi_master and 
//   Slave interfaces.
// - Includes UVM library, axi_master package, Slave package, and relevant 
//   testbench and test library files.
// - Sets up UVM configuration for virtual interfaces and starts the testbench.
//-----------------------------------------------------------------------------
module AXI_top;

    //---------------------------------------------------------------------------
    // UVM LIBRARY AND PACKAGE IMPORTS
    //---------------------------------------------------------------------------
    // - Imports UVM components and utilities for verification.
    // - Includes macros (`uvm_macros.svh`) for simplifying UVM usage.
    //---------------------------------------------------------------------------
    import uvm_pkg::*;                // UVM base package
    `include "uvm_macros.svh"         // UVM macros for testbench automation
    import axi_parameters::*;
    //typedef uvm_config_db#(virtual axi4_if) axi4_if_config;

    //---------------------------------------------------------------------------
    // axi_master AND SLAVE PACKAGE IMPORTS
    //---------------------------------------------------------------------------
    // - Imports the axi_master and Slave interface packages for virtual interface
    //   declarations and other related components.
    //---------------------------------------------------------------------------
    import axi_master_pkg::*;           // axi_master interface and related components
    import axi_slave_pkg::*;              // Slave interface and related components

    //---------------------------------------------------------------------------
    // TESTBENCH AND SCOREBOARD INCLUDES
    //---------------------------------------------------------------------------
    // - Includes testbench, scoreboard, and test library files for AXI verification.
    //---------------------------------------------------------------------------
    `include "AXI_scoreboard.sv" // Scoreboard for AXI functional coverage
    `include "axi_tb.sv"              // AXI testbench definitions
    `include "axi_test_lib.sv"        // AXI test library containing sequences and tests

    //---------------------------------------------------------------------------
    // INITIAL BLOCK
    //---------------------------------------------------------------------------
    // - Configures virtual interfaces for axi_master and Slave environments.
    // - Starts the UVM testbench by calling `run_test()`.
    //---------------------------------------------------------------------------
    initial begin
        // Configure the virtual interface for the axi_master environment
        uvm_config_db#(virtual axi4_if)::set(
            null,                     // Parent (null for global scope)
            "*env*",                 // Match pattern for components
            "vif",                    // Field name
            hw_top.axi_vif           // Virtual interface instance
        );
      //  uvm_config_db#(test_config)::set(null, "*", "test_cfg", test_cfg);


        // Start the UVM testbench
        run_test();

        // Optional termination (commented out as UVM typically handles termination)
        // $finish;
    end

endmodule : AXI_top
