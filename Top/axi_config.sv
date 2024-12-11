

// ----------------------------------------------------------------------------
// CLASS: test_config
// DESCRIPTION:
// - Test configuration object for controlling sequence item generation.
// - Configurable fields include the number of write/read cases, address alignment,
//   and burst type preferences.
// ----------------------------------------------------------------------------
package config_pkg;
import uvm_pkg::*;                // UVM base package
`include "uvm_macros.svh"         // UVM macros for testbench automation
class test_config extends uvm_object;

    // Register with the factory
    `uvm_object_utils(test_config)
    
    // Number of write and read test cases to generate
    int number_of_write_cases = 50;
    int number_of_read_cases = 50;

    // Address alignment settings:
    // -1: Produce both aligned and unaligned addresses randomly
    //  0: Generate unaligned addresses for all bursts
    //  1: Generate aligned addresses for all bursts
    byte address_alignment = -1;

    bit ARESET_n;

    // Burst type settings:
    // -1: Randomly generate all burst types
    //  0: Fixed bursts
    //  1: Increment bursts
    //  2: Wrap bursts
    byte burst_type = -1;

    // Enable or disable randomization of burst lengths
    bit randomize_burst_length = 1;

    // AXI protocol-specific settings
    int max_burst_length = 16;  // Maximum burst length allowed by AXI
    int timeout_cycles = 1000; // Timeout for transactions

    // Constructor
    function new(string name = "test_config");
        super.new(name);
    endfunction: new

endclass: test_config
endpackage
