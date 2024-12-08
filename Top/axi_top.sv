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

    //---------------------------------------------------------------------------
    // axi_master AND SLAVE PACKAGE IMPORTS
    //---------------------------------------------------------------------------
    // - Imports the axi_master and Slave interface packages for virtual interface
    //   declarations and other related components.
    //---------------------------------------------------------------------------
    import axi_master_pkg::*;           // axi_master interface and related components
    import slave_pkg::*;              // Slave interface and related components

    //---------------------------------------------------------------------------
    // TESTBENCH AND SCOREBOARD INCLUDES
    //---------------------------------------------------------------------------
    // - Includes testbench, scoreboard, and test library files for AXI verification.
    //---------------------------------------------------------------------------
  //  `include "../sv/AXI_scoreboard.sv" // Scoreboard for AXI functional coverage
    `include "AXI_tb.sv"              // AXI testbench definitions
    `include "AXI_test_lib.sv"        // AXI test library containing sequences and tests
    //`include "AXI_assertions.sv"      // Assertions for AXI verification
    

    //---------------------------------------------------------------------------
    // INITIAL BLOCK
    //---------------------------------------------------------------------------
    // - Configures virtual interfaces for axi_master and Slave environments.
    // - Starts the UVM testbench by calling `run_test()`.
    //---------------------------------------------------------------------------
    initial begin
        // Configure the virtual interface for the axi_master environment
        uvm_config_db#(virtual axi_master_if)::set(
            null,                     // Parent (null for global scope)
            "*wish*",                 // Match pattern for components
            "vif",                    // Field name
            hw_top.wish_vif           // Virtual interface instance
        );

        // Configure the virtual interface for the Slave environment
        uvm_config_db#(virtual slave_if)::set(
            null,                     // Parent (null for global scope)
            "*slave*",                // Match pattern for components
            "vif",                    // Field name
            hw_top.slave_vif          // Virtual interface instance
        );

        // Start the UVM testbench
        run_test();

        // Optional termination (commented out as UVM typically handles termination)
        // $finish;
    end

endmodule : AXI_top
