class axi_slave_seq_item extends uvm_sequence_item;

  // Parameters for AXI4 Full interface
  parameter ADDR_WIDTH = 32;   // Width of address bus in bits
  parameter DATA_WIDTH = 32;   // Width of data bus in bits
  parameter STRB_WIDTH = DATA_WIDTH / 8;  // Write strobe width
  parameter ID_WIDTH = 8;      // Width of the ID signal
  parameter BURST_TYPE = 2;    // Burst type (INCR, WRAP, FIXED)

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

  // Constructor
  function new(string name = "axi_slave_seq_item");
    super.new(name);
  endfunction

  // Randomize all necessary fields
  function void randomize_all();
    randomize(AWREADY, WREADY, BID, BRESP, BVALID, ARREADY, RID, RDATA, RRESP, RLAST, RVALID);
  endfunction

  // Print function (for debugging purposes)
  function void print();
    $display("AXI4 Slave Write: AWADDR=%h, AWLEN=%d, AWSIZE=%d, AWBURST=%d, AWLOCK=%b, AWCACHE=%b, AWPROT=%b, AWVALID=%b, AWREADY=%b, "
             "WDATA=%h, WSTRB=%b, WLAST=%b, WVALID=%b, WREADY=%b, BID=%h, BRESP=%b, BVALID=%b, BREADY=%b",
             AWADDR, AWLEN, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWPROT, AWVALID, AWREADY,
             WDATA, WSTRB, WLAST, WVALID, WREADY, BID, BRESP, BVALID, BREADY);
    $display("AXI4 Slave Read: ARADDR=%h, ARLEN=%d, ARSIZE=%d, ARBURST=%d, ARLOCK=%b, ARCACHE=%b, ARPROT=%b, ARVALID=%b, ARREADY=%b, "
             "RID=%h, RDATA=%h, RRESP=%b, RLAST=%b, RVALID=%b, RREADY=%b",
             ARADDR, ARLEN, ARSIZE, ARBURST, ARLOCK, ARCACHE, ARPROT, ARVALID, ARREADY,
             RID, RDATA, RRESP, RLAST, RVALID, RREADY);
  endfunction

endclass
