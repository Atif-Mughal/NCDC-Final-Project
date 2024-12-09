import axi_parameters::*;
interface axi4_if (input clock);

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

  // --------------------------------------------------------------
  // Assertions to ensure AXI4 protocol compliance
  // --------------------------------------------------------------

  // Write Address Validity
  assert property (@(posedge clock) (ARESETn == 1'b1 && AWVALID) |-> AWREADY)
    else $error("Write address phase: AWVALID asserted but AWREADY not received.");

  // Write Data Validity
  assert property (@(posedge clock) (ARESETn == 1'b1 && WVALID) |-> WREADY)
    else $error("Write data phase: WVALID asserted but WREADY not received.");

  // Write Response Validity
  assert property (@(posedge clock) (ARESETn == 1'b1 && BVALID) |-> BREADY)
    else $error("Write response phase: BVALID asserted but BREADY not received.");

  // Read Address Validity
  assert property (@(posedge clock) (ARESETn == 1'b1 && ARVALID) |-> ARREADY)
    else $error("Read address phase: ARVALID asserted but ARREADY not received.");

  // Read Data Validity
  assert property (@(posedge clock) (ARESETn == 1'b1 && RVALID) |-> RREADY)
    else $error("Read data phase: RVALID asserted but RREADY not received.");

  // Write Data Completeness
  assert property (@(posedge clock) (ARESETn == 1'b1 && WVALID && WLAST) |-> (WSTRB != 0))
    else $error("Write data phase: WLAST asserted but WSTRB is zero.");

  // Read Data Completeness
  assert property (@(posedge clock) (ARESETn == 1'b1 && RVALID && RLAST) |-> (RRESP == 2'b00))
    else $error("Read data phase: RLAST asserted but RRESP is not OKAY.");

  // Burst Length Validation
  assert property (@(posedge clock) (ARESETn == 1'b1 && AWVALID && AWLEN > 0) |-> (AWLEN <= 16))
    else $error("Write address phase: AWLEN exceeds maximum burst length.");

  assert property (@(posedge clock) (ARESETn == 1'b1 && ARVALID && ARLEN > 0) |-> (ARLEN <= 16))
    else $error("Read address phase: ARLEN exceeds maximum burst length.");

endinterface
