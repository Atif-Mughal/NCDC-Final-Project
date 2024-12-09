//import axi_parameters::*;
class axi_master_seq_item extends uvm_sequence_item;
  rand bit ARESETn;

  // AXI4 Write Address Channel (AW)
  rand bit [ADDR_WIDTH-1:0] AWADDR;     // Write address
  rand bit [7:0] AWLEN;                  // Burst length
  rand bit [2:0] AWSIZE;                 // Burst size
  rand bit [1:0] AWBURST;                // Burst type (INCR, WRAP, FIXED)
  rand bit AWLOCK;                       // Lock signal (indicates atomic access)
  rand bit [3:0] AWCACHE;                // Cache attributes
  rand bit [2:0] AWPROT;                 // Protection attributes
  rand bit AWVALID;                      // Write address valid
  bit AWREADY;                           // Write address ready

  // AXI4 Write Data Channel (W)
  rand bit [DATA_WIDTH-1:0] WDATA;       // Write data
  rand bit [STRB_WIDTH-1:0] WSTRB;       // Write strobe (byte enable)
  rand bit WLAST;                        // Write last
  rand bit WVALID;                       // Write valid
  bit WREADY;                            // Write ready

  // AXI4 Write Response Channel (B)
  bit [ID_WIDTH-1:0] BID;                // Write ID
  bit [1:0] BRESP;                       // Write response (OKAY, EXOKAY, SLVERR, DECERR)
  bit BVALID;                            // Write response valid
  rand bit BREADY;                       // Write response ready

  // AXI4 Read Address Channel (AR)
  rand bit [ADDR_WIDTH-1:0] ARADDR;      // Read address
  rand bit [7:0] ARLEN;                  // Burst length
  rand bit [2:0] ARSIZE;                 // Burst size
  rand bit [1:0] ARBURST;                // Burst type (INCR, WRAP, FIXED)
  rand bit ARLOCK;                       // Lock signal (indicates atomic access)
  rand bit [3:0] ARCACHE;                // Cache attributes
  rand bit [2:0] ARPROT;                 // Protection attributes
  rand bit ARVALID;                      // Read address valid
  bit ARREADY;                           // Read address ready

  // AXI4 Read Data Channel (R)
  bit [ID_WIDTH-1:0] RID;                // Read ID
  bit [DATA_WIDTH-1:0] RDATA;            // Read data
  bit [1:0] RRESP;                       // Read response (OKAY, EXOKAY, SLVERR, DECERR)
  bit RLAST;                             // Read last
  bit RVALID;                            // Read valid
  rand bit RREADY;                       // Read data ready
  
  `uvm_object_utils_begin(axi_master_seq_item)
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
  function new(string name = "axi_master_seq_item");
    super.new(name);
  endfunction


endclass
