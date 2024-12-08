class axi_slave_seq_item extends uvm_sequence_item;

  // Parameters for AXI4 Full interface
  parameter ADDR_WIDTH = 32;   // Width of address bus in bits
  parameter DATA_WIDTH = 32;   // Width of data bus in bits
  parameter STRB_WIDTH = DATA_WIDTH / 8;  // Write strobe width
  parameter ID_WIDTH = 8;      // Width of the ID signal
  parameter BURST_TYPE = 2;    // Burst type (INCR, WRAP, FIXED)

  rand bit ARESETn;

  // AXI4 Write Address Channel (AW)
  bit [ADDR_WIDTH-1:0] AWADDR;     // Write address
  bit [7:0] AWLEN;                // Burst length
  bit [2:0] AWSIZE;               // Burst size
  bit [1:0] AWBURST;              // Burst type (INCR, WRAP, FIXED)
  bit AWLOCK;                     // Lock signal (indicates atomic access)
  bit [3:0] AWCACHE;              // Cache attributes
  bit [2:0] AWPROT;               // Protection attributes
  bit AWVALID;                    // Write address valid
  rand bit AWREADY;               // Write address ready

  // AXI4 Write Data Channel (W)
  bit [DATA_WIDTH-1:0] WDATA;     // Write data
  bit [STRB_WIDTH-1:0] WSTRB;     // Write strobe (byte enable)
  bit WLAST;                      // Write last
  bit WVALID;                     // Write valid
  rand bit WREADY;                // Write ready

  // AXI4 Write Response Channel (B)
  rand bit [ID_WIDTH-1:0] BID;    // Write ID
  rand bit [1:0] BRESP;           // Write response (OKAY, EXOKAY, SLVERR, DECERR)
  rand bit BVALID;                // Write response valid
  bit BREADY;                     // Write response ready

  // AXI4 Read Address Channel (AR)
  bit [ADDR_WIDTH-1:0] ARADDR;    // Read address
  bit [7:0] ARLEN;                // Burst length
  bit [2:0] ARSIZE;               // Burst size
  bit [1:0] ARBURST;              // Burst type (INCR, WRAP, FIXED)
  bit ARLOCK;                     // Lock signal (indicates atomic access)
  bit [3:0] ARCACHE;              // Cache attributes
  bit [2:0] ARPROT;               // Protection attributes
  bit ARVALID;                    // Read address valid
  rand bit ARREADY;               // Read address ready

  // AXI4 Read Data Channel (R)
  rand bit [ID_WIDTH-1:0] RID;    // Read ID
  rand bit [DATA_WIDTH-1:0] RDATA; // Read data
  rand bit [1:0] RRESP;           // Read response (OKAY, EXOKAY, SLVERR, DECERR)
  rand bit RLAST;                 // Read last
  rand bit RVALID;                // Read valid
  bit RREADY;                     // Read data ready
  
    `uvm_object_utils_begin(axi_slave_seq_item)
  	`uvm_field_int(ARESETn, UVM_DEFAULT)
  	`uvm_field_int(AWADDR, UVM_DEFAULT)
  	`uvm_field_int(AWLEN, UVM_DEFAULT)
  	`uvm_field_int(AWSIZE, UVM_DEFAULT)
  	`uvm_field_int(AWBURST, UVM_DEFAULT)
  	`uvm_field_int(AWLOCK, UVM_DEFAULT)
  	`uvm_field_int(AWCACHE, UVM_DEFAULT)
  	`uvm_field_int(AWPROT, UVM_DEFAULT)
  	`uvm_field_int(AWVALID, UVM_DEFAULT)
  	`uvm_field_int(AWREADY, UVM_DEFAULT)
  	`uvm_field_int(WDATA, UVM_DEFAULT)
  	`uvm_field_int(WSTRB, UVM_DEFAULT)
  	`uvm_field_int(WLAST, UVM_DEFAULT)
  	`uvm_field_int(WVALID, UVM_DEFAULT)
  	`uvm_field_int(WREADY, UVM_DEFAULT)
  	`uvm_field_int(BID, UVM_DEFAULT)
  	`uvm_field_int(BRESP, UVM_DEFAULT)
  	`uvm_field_int(BVALID, UVM_DEFAULT)
  	`uvm_field_int(BREADY, UVM_DEFAULT)
  	`uvm_field_int(ARADDR, UVM_DEFAULT)
  	`uvm_field_int(ARLEN, UVM_DEFAULT)
  	`uvm_field_int(ARSIZE, UVM_DEFAULT)
  	`uvm_field_int(ARBURST, UVM_DEFAULT)
  	`uvm_field_int(ARLOCK, UVM_DEFAULT)
  	`uvm_field_int(ARCACHE, UVM_DEFAULT)
  	`uvm_field_int(ARPROT, UVM_DEFAULT)
  	`uvm_field_int(ARVALID, UVM_DEFAULT)
  	`uvm_field_int(ARREADY, UVM_DEFAULT)
  	`uvm_field_int(RID, UVM_DEFAULT)
  	`uvm_field_int(RDATA, UVM_DEFAULT)
  	`uvm_field_int(RRESP, UVM_DEFAULT)
  	`uvm_field_int(RLAST, UVM_DEFAULT)
  	`uvm_field_int(RVALID, UVM_DEFAULT)
  	`uvm_field_int(RREADY, UVM_DEFAULT)
  	
  `uvm_object_utils_end

  // Constructor
  function new(string name = "axi_slave_seq_item");
    super.new(name);
  endfunction


endclass
