class axi_master_seq_item extends uvm_sequence_item;

  // Parameters for AXI4 Full interface
  parameter ADDR_WIDTH = 32;   // Width of address bus in bits
  parameter DATA_WIDTH = 32;   // Width of data bus in bits
  parameter STRB_WIDTH = DATA_WIDTH / 8;  // Write strobe width
  parameter ID_WIDTH = 8;      // Width of the ID signal
  parameter BURST_TYPE = 2;    // Burst type (INCR, WRAP, FIXED)

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

  // Constructor
  function new(string name = "axi_full_seq_item");
    super.new(name);
  endfunction

  // Randomize all necessary fields
  function void randomize_all();
    randomize(AWADDR, AWLEN, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWPROT, AWVALID, 
              WDATA, WSTRB, WLAST, WVALID, ARADDR, ARLEN, ARSIZE, ARBURST, 
              ARLOCK, ARCACHE, ARPROT, ARVALID);
  endfunction

  // Print function (for debugging purposes)
  function void print();
    $display("AXI4 Write: AWADDR=%h, AWLEN=%d, AWSIZE=%d, AWBURST=%d, AWLOCK=%b, AWCACHE=%b, AWPROT=%b, WDATA=%h, WSTRB=%b, WLAST=%b", 
             AWADDR, AWLEN, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWPROT, WDATA, WSTRB, WLAST);
    $display("AXI4 Read: ARADDR=%h, ARLEN=%d, ARSIZE=%d, ARBURST=%d, ARLOCK=%b, ARCACHE=%b, ARPROT=%b", 
             ARADDR, ARLEN, ARSIZE, ARBURST, ARLOCK, ARCACHE, ARPROT);
  endfunction

endclass
