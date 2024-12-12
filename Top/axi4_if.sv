// ******************************************************************************************
//                              Importing Required Packages
// ******************************************************************************************
import axi_parameters::*;

// ==========================================================================================
//                            AXI4 Interface Declaration
// ==========================================================================================
interface axi4_if (input bit clk);

    //////////////////////////////////////////////////////////////////////////////////////////
    //                                WRITE ADDRESS CHANNEL
    //////////////////////////////////////////////////////////////////////////////////////////
    logic [8:0] AWID;                     // Write Address ID
    logic [ADDR_WIDTH-1:0] AWADDR;        // Write Address
    logic [3:0] AWLEN;                    // Burst Length
    logic [2:0] AWSIZE;                   // Burst Size
    logic [1:0] AWBURST;                  // Burst Type
    logic AWVALID;                        // Write Address Valid
    logic AWREADY;                        // Write Address Ready

    //////////////////////////////////////////////////////////////////////////////////////////
    //                                WRITE DATA CHANNEL
    //////////////////////////////////////////////////////////////////////////////////////////
    logic [8:0] WID;                      // Write Data ID
    logic [DATA_WIDTH-1:0] WDATA;         // Write Data
    logic [(DATA_WIDTH/8)-1:0] WSTRB;     // Write Strobe
    logic WLAST;                          // Write Last
    logic WVALID;                         // Write Valid
    logic WREADY;                         // Write Ready

    //////////////////////////////////////////////////////////////////////////////////////////
    //                                WRITE RESPONSE CHANNEL
    //////////////////////////////////////////////////////////////////////////////////////////
    logic [8:0] BID;                      // Write Response ID
    logic [1:0] BRESP;                    // Write Response
    logic BVALID;                         // Write Response Valid
    logic BREADY;                         // Write Response Ready

    //////////////////////////////////////////////////////////////////////////////////////////
    //                                READ ADDRESS CHANNEL
    //////////////////////////////////////////////////////////////////////////////////////////
    logic [8:0] ARID;                     // Read Address ID
    logic [ADDR_WIDTH-1:0] ARADDR;        // Read Address
    logic [3:0] ARLEN;                    // Burst Length
    logic [2:0] ARSIZE;                   // Burst Size
    logic [1:0] ARBURST;                  // Burst Type
    logic ARVALID;                        // Read Address Valid
    logic ARREADY;                        // Read Address Ready

    //////////////////////////////////////////////////////////////////////////////////////////
    //                                READ DATA CHANNEL
    //////////////////////////////////////////////////////////////////////////////////////////
    logic [8:0] RID;                      // Read Data ID
    logic [DATA_WIDTH-1:0] RDATA;         // Read Data
    logic [1:0] RRESP;                    // Read Response
    logic RLAST;                          // Read Last
    logic RVALID;                         // Read Valid
    logic RREADY;                         // Read Ready

    // ======================================================================================
    //                           Clocking Blocks for AXI4 Interface
    // ======================================================================================

    //////////////////////////////////////////////////////////////////////////////////////////
    //                              Master Driver Clocking Block
    //////////////////////////////////////////////////////////////////////////////////////////
    clocking master_driver_cb @(posedge clk);
        output AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID, 
               WID, WDATA, WSTRB, WLAST, WVALID, BREADY,
               ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID, RREADY;
        input  AWREADY, WREADY, BID, BRESP, BVALID,
               ARREADY, RID, RDATA, RRESP, RLAST, RVALID;
    endclocking

    //////////////////////////////////////////////////////////////////////////////////////////
    //                              Monitor Clocking Block
    //////////////////////////////////////////////////////////////////////////////////////////
    clocking monitor_cb @(posedge clk);
        output  AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID, 
               WID, WDATA, WSTRB, WLAST, WVALID, BREADY,
               ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID, RREADY;
        input  AWREADY, WREADY, BID, BRESP, BVALID,
               ARREADY, RID, RDATA, RRESP, RLAST, RVALID;
    endclocking

    //////////////////////////////////////////////////////////////////////////////////////////
    //                              Slave Driver Clocking Block
    //////////////////////////////////////////////////////////////////////////////////////////
    clocking slave_driver_cb @(posedge clk);
        input  AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID, 
               WID, WDATA, WSTRB, WLAST, WVALID, BREADY,
               ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID, RREADY;
        output AWREADY, WREADY, BID, BRESP, BVALID, 
               ARREADY, RID, RDATA, RRESP, RLAST, RVALID;
    endclocking

    // ======================================================================================
    //                           Modport Declarations
    // ======================================================================================
    modport Master_Driver_MP(clocking master_driver_cb);  // Master Driver
    modport Master_Monitor_MP(clocking monitor_cb);       // Master Monitor
    modport Slave_Driver_MP(clocking slave_driver_cb);    // Slave Driver
    modport Slave_Monitor_MP(clocking monitor_cb);        // Slave Monitor

endinterface
