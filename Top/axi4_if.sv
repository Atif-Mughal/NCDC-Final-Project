interface axi4_if (input clock);
	        // Parameters for AXI4 Full interface
  parameter ADDR_WIDTH = 32;   // Width of address bus in bits
  parameter DATA_WIDTH = 32;   // Width of data bus in bits
  parameter STRB_WIDTH = DATA_WIDTH / 8;  // Write strobe width
  parameter ID_WIDTH = 8;      // Width of the ID signal
  parameter BURST_TYPE = 2;    // Burst type (INCR, WRAP, FIXED)

  // Global clock and reset
  logic ARESETn;   // Global reset signal (active low)

  // Write Address Channel (AW)
  logic [ID_WIDTH-1:0]       AWID;     // Write ID
  logic [ADDR_WIDTH-1:0]     AWADDR;   // Write address
  logic [7:0]                AWLEN;    // Burst length
  logic [2:0]                AWSIZE;   // Burst size
  logic [1:0]                AWBURST;  // Burst type
  logic                      AWLOCK;   // Lock signal
  logic [3:0]                AWCACHE;  // Cache type
  logic [2:0]                AWPROT;   // Protection type
  logic [3:0]                AWQOS;    // Quality of Service
  logic                      AWVALID;  // Write address valid
  logic                      AWREADY;  // Write address ready

  // Write Data Channel (W)
  logic [DATA_WIDTH-1:0]     WDATA;    // Write data
  logic [(DATA_WIDTH/8)-1:0] WSTRB;    // Write strobes
  logic                      WLAST;    // Write last
  logic                      WVALID;   // Write valid
  logic                      WREADY;   // Write ready

  // Write Response Channel (B)
  logic [ID_WIDTH-1:0]       BID;      // Write response ID
  logic [1:0]                BRESP;    // Write response
  logic                      BVALID;   // Write response valid
  logic                      BREADY;   // Write response ready

  // Read Address Channel (AR)
  logic [ID_WIDTH-1:0]       ARID;     // Read ID
  logic [ADDR_WIDTH-1:0]     ARADDR;   // Read address
  logic [7:0]                ARLEN;    // Burst length
  logic [2:0]                ARSIZE;   // Burst size
  logic [1:0]                ARBURST;  // Burst type
  logic                      ARLOCK;   // Lock signal
  logic [3:0]                ARCACHE;  // Cache type
  logic [2:0]                ARPROT;   // Protection type
  logic [3:0]                ARQOS;    // Quality of Service
  logic                      ARVALID;  // Read address valid
  logic                      ARREADY;  // Read address ready

  // Read Data Channel (R)
  logic [ID_WIDTH-1:0]       RID;      // Read response ID
  logic [DATA_WIDTH-1:0]     RDATA;    // Read data
  logic [1:0]                RRESP;    // Read response
  logic                      RLAST;    // Read last
  logic                      RVALID;   // Read valid
  logic                      RREADY;   // Read ready

endinterface
