package axi_parameters;
        // Parameters for AXI4 Full interface
  parameter ADDR_WIDTH = 32;   // Width of address bus in bits
  parameter DATA_WIDTH = 32;   // Width of data bus in bits
  parameter STRB_WIDTH = DATA_WIDTH / 8;  // Write strobe width
  parameter ID_WIDTH = 8;      // Width of the ID signal
  parameter BURST_TYPE = 2;    // Burst type (INCR, WRAP, FIXED)

endpackage
