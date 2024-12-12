// ******************************************************************************************
//                              Importing Required Packages
// ******************************************************************************************
import uvm_pkg::*;                // UVM base package
`include "uvm_macros.svh"         // UVM macros for testbench automation
import axi_parameters::*;

// ******************************************************************************************
//                              Type Definitions
// ******************************************************************************************
typedef enum bit [1:0] { FIXED, INCR, WRAP } B_TYPE;  // Burst types: FIXED, INCR, WRAP

// ******************************************************************************************
//                              Class Declaration
// ******************************************************************************************
class axi_master_seq_item extends uvm_sequence_item;

      // ========================================================================================
      //                            AXI Attributes
      // ========================================================================================
      bit [7:0] ID;                               // Transaction ID
      rand bit [ADDR_WIDTH-1:0] ADDR;             // Address for transaction
      rand bit [7:0] DATA [][];                   // Burst data
      rand bit [2:0] BURST_SIZE;                  // Burst size (number of bytes per beat)
      rand bit [3:0] BURST_LENGTH;                // Burst length (number of beats)
      rand B_TYPE BURST_TYPE;                     // Burst type (FIXED, INCR, WRAP)
      bit LAST;                                   // Last beat indicator
      bit [1:0] WRITE_RESP;                       // Write response
      bit [1:0] READ_RESP [];                     // Read responses for burst

      // ========================================================================================
      //                           UVM Object Utilities Macros
      // ========================================================================================
      `uvm_object_utils_begin(axi_master_seq_item)

          // ----------------------------------------------------------------------------------------
          //                        AXI Attributes with Packing/Unpacking Macros
          // ----------------------------------------------------------------------------------------
          `uvm_field_int(ID, UVM_DEFAULT)                               // Transaction ID
          `uvm_field_int(ADDR, UVM_DEFAULT + UVM_BIN)                   // Address for transaction
          // `uvm_field_sarray_int(DATA, UVM_DEFAULT)                   // Burst data (pack/unpack as needed)
          `uvm_field_int(BURST_SIZE, UVM_DEFAULT)                        // Burst size (number of bytes per beat)
          `uvm_field_int(BURST_LENGTH, UVM_DEFAULT)                      // Burst length (number of beats)
          `uvm_field_enum(B_TYPE, BURST_TYPE, UVM_DEFAULT)              // Burst type (FIXED, INCR, WRAP)
          `uvm_field_int(LAST, UVM_DEFAULT)                              // Last beat indicator
          `uvm_field_int(WRITE_RESP, UVM_DEFAULT)                       // Write response
          // `uvm_field_int(READ_RESP, UVM_DEFAULT + UVM_BIN)            // Read responses for burst

      `uvm_object_utils_end


      // ========================================================================================
      //                           Constraints for AXI Protocol Compliance
      // ========================================================================================
      constraint burst_size_constraint {
        8 * (2**BURST_SIZE) <= DATA_WIDTH;        // Data width must accommodate burst size
      }

      constraint data_size_constraint {
        solve BURST_LENGTH before DATA;
        solve BURST_SIZE before DATA;

        DATA.size() == BURST_LENGTH + 1;          // Data array size matches burst length
        foreach (DATA[i]) 
          DATA[i].size() == 2**BURST_SIZE;        // Each data beat size matches burst size
      }

      constraint burst_length_constraint {
        solve BURST_TYPE before BURST_LENGTH;

        if (BURST_TYPE == FIXED)
          BURST_LENGTH inside { 0, 1 };           // FIXED burst length limited to 1 or 2 beats
        else if (BURST_TYPE == WRAP)
          BURST_LENGTH inside { 1, 3, 7, 15 };    // WRAP bursts are power-of-two sizes
      }

      constraint addr_constraint {
        solve BURST_TYPE before ADDR;
        solve BURST_SIZE before ADDR;

        if (BURST_TYPE == WRAP)
          ADDR == int'(ADDR / 2**BURST_SIZE) * 2**BURST_SIZE;  // WRAP bursts must be aligned
      }

      constraint addr_alignment_constraint {
        solve BURST_SIZE before ADDR;

        ADDR == int'(ADDR / 2**BURST_SIZE) * 2**BURST_SIZE;    // Address alignment constraint
      }

      constraint addr_unalignment_constraint {
        solve BURST_SIZE before ADDR;

        ADDR != int'(ADDR / 2**BURST_SIZE) * 2**BURST_SIZE;    // Address unalignment constraint
      }

      // ========================================================================================
      //                           Constructor
      // ========================================================================================
      function new(string name = "axi_master_seq_item");
        super.new(name);
      endfunction: new

endclass: axi_master_seq_item
