// ******************************************************************************************
//                              Importing Required Packages
// ******************************************************************************************
import axi_parameters::*;

// ==========================================================================================
//                            AXI4 Interface Declaration
// ==========================================================================================
interface axi4_if (input bit clk);

    logic ARESET_n;
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
        input  AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID, 
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



       //------------------------------------------ Assertions ------------------------------------------------
       
       /* when the circuit is reset master should de-assert AWVALID, WVALID and ARVALID 
       and slave should de-assert RVALID and BVALID all other signal can be drive to any value */
       property reset_check;
              @(posedge clk) !ARESET_n |=> !AWVALID && !WVALID && !ARVALID && !RVALID && !BVALID;     
       endproperty : reset_check

       //---------------------------------------- AR Channel ---------------------------------------------
       
       /* When the master assert ARVALID all other master output signal not changed if the ARREADY is low  */
       property ar_valid;
              @(posedge clk) 
              disable iff (!ARESET_n) 
                     ARVALID && !ARREADY |-> $stable(ARADDR) && $stable(ARLEN) && $stable(ARSIZE) && $stable(ARBURST); //$stable(ARID)   
       endproperty : ar_valid
       /* when ARVALID is asserted, then it remains asserted until ARREADY is HIGH */
       property arvalid_stable;
              @(posedge clk) 
              disable iff (!ARESET_n)
                     ARVALID  && !ARREADY |-> ARVALID;        
       endproperty : arvalid_stable
       /* when ARVALID is asserted, then there may be ARREADY asserted already or if not, should be asserted within maximum 16 cycle */
       property arready_wait;
              @(posedge clk)
              disable iff (!ARESET_n)
                     ARVALID |-> ##[0:16] ARREADY;   //v     
       endproperty : arready_wait
       /* when ARVALID is high value on ARBURST should not equal to 2'b11 */      
       property invalid_arburst;
              @(posedge clk)
              disable iff (!ARESET_n)
                     ARVALID |-> (ARBURST != 2'b11)
       endproperty : invalid_arburst    
       /* after handshake both ARVALID and ARREADY should de-asserted in next cycle */
       /* property ar_valid_ready_deassert;
              @(posedge clk)
              disable iff(!ARESET_n)
                     ARVALID && ARREADY |=> !ARVALID && !ARREADY; 			 
       endproperty : ar_valid_ready_deassert 
       */
       //-------------------------------- Read Data (D) Channel --------------------------------------------------
       
       /* When the slave assert RVALID all other slave output signal not changed if the RREADY is low  */
       property r_valid;
              @(posedge clk) 
              disable iff(!ARESET_n) 
                     RVALID && !RREADY |-> $stable(RDATA) && $stable(RRESP) && $stable(RLAST); //$stable(RID)   
       endproperty : r_valid
       /* when RVALID is asserted, then it remains asserted until RREADY is HIGH */
       property rvalid_stable;
              @(posedge clk) 
              disable iff(!ARESET_n)
                     RVALID  && !RREADY |-> RVALID;        
       endproperty : rvalid_stable
       /* when RVALID is asserted, then there may be RREADY asserted already or if not, should be asserted within maximum 16 cycle */
       property rready_wait;
              @(posedge clk)
              disable iff(!ARESET_n)
                     RVALID |-> ##[0:16] RREADY;   //v     
       endproperty : rready_wait
       
       /* after handshake both ARVALID and ARREADY should de-asserted in next cycle */
       /*
       property r_valid_ready_deassert;
              @(posedge clk)
              disable iff(!ARESET_n)
                     RVALID && RREADY |=> !RVALID && !RREADY; 			 
       endproperty : r_valid_ready_deassert 
       */
       //-------------------------------- Write address (AW) Channel --------------------------------------------------
       
       /* When the master assert AWVALID all other slave output signal not changed if the AWREADY is low  */
       property aw_valid;
              @(posedge clk) 
              disable iff(!ARESET_n) 
                     AWVALID && !AWREADY |-> $stable(AWADDR) && $stable(ARLEN) && $stable(ARSIZE) && $stable(ARBURST); //$stable(AWID)   
       endproperty : aw_valid
       /* when AWVALID is asserted, then it remains asserted until AWREADY is HIGH */
       property awvalid_stable;
              @(posedge clk) 
              disable iff(!ARESET_n)
                     AWVALID  && !AWREADY |-> AWVALID;        
       endproperty : awvalid_stable
       /* when AWVALID is asserted, then there may be AWREADY asserted already or if not, should be asserted within maximum 16 cycle */
       property awready_wait;
              @(posedge clk)
              disable iff(!ARESET_n)
                     AWVALID |-> ##[0:16] AWREADY;   //v     
       endproperty : awready_wait
       /* when AWVALID is high value on AWBURST should not equal to 2'b11 */      
       property invalid_awburst;
              @(posedge clk)
              disable iff (!ARESET_n)
                     AWVALID |-> (AWBURST != 2'b11)
       endproperty : invalid_awburst   
       
       /* after handshake both AWVALID and AWREADY should de-asserted in next cycle */
       /*
       property aw_valid_ready_deassert;
              @(posedge clk)
              disable iff(!ARESET_n)
                     AWVALID && AWREADY |=> !AWVALID && !AWREADY; 			 
       endproperty : aw_valid_ready_deassert 
       */
       //-------------------------------- Write data (W) Channel --------------------------------------------------
       
       /* When the master assert AWVALID all other slave output signal not changed if the AWREADY is low  */
       property w_valid;
              @(posedge clk) 
              disable iff(!ARESET_n) 
                     WVALID && !WREADY |-> $stable(WDATA) && $stable(WSTRB) && $stable(WLAST);   
       endproperty : w_valid
       /* when WVALID is asserted, then it remains asserted until WREADY is HIGH */
       property wvalid_stable;
              @(posedge clk) 
              disable iff(!ARESET_n)
                     WVALID  && !WREADY |-> WVALID;        
       endproperty : wvalid_stable
       /* when WVALID is asserted, then there may be WREADY asserted already or if not, should be asserted within maximum 16 cycle */
       property wready_wait;
              @(posedge clk)
              disable iff(!ARESET_n)
                     WVALID |-> ##[0:16] WREADY;   //v     
       endproperty : wready_wait
       
       /* after handshake both WVALID and WREADY should de-asserted in next cycle */
       /*
       property w_valid_ready_deassert;
              @(posedge clk)
              disable iff(!ARESET_n)
                     WVALID && WREADY |=> !WVALID && !WREADY; 			 
       endproperty : w_valid_ready_deassert 
       */
       //------------------------------ Write Response (B) channel ---------------------------------------------------------
       
       /* When the slave assert BVALID, BRESP should not changed if the BREADY is low  */
       property b_valid;
              @(posedge clk) 
              disable iff(!ARESET_n) 
                     BVALID && !BREADY |-> $stable(BRESP);  //$stable(BID)
       endproperty : b_valid 
       /* when BVALID is asserted, then there may be BREADY asserted already or if not, should be asserted within maximum 16 cycle */
       property bready_wait;
              @(posedge clk)
              disable iff(!ARESET_n)
                     BVALID |-> ##[0:16] BREADY;   //v     
       endproperty : bready_wait
       /* after handshake both BVALID and BREADY should be de-asserted in next cycle */
       /*
       property b_valid_ready_deassert;
              @(posedge clk)
              disable iff(!ARESET_n)
                     BVALID && BREADY |=> !BVALID && !BREADY; 			 
       endproperty : b_valid_ready_deassert 
       */
       assert property (reset_check);
       assert property (ar_valid);
       assert property (arvalid_stable);
       assert property (arready_wait);
       assert property (invalid_arburst);
       //assert property (ar_valid_ready_deassert);
       assert property (r_valid);
       assert property (rvalid_stable);
       assert property (rready_wait);
       //assert property (r_valid_ready_deassert);
       assert property (aw_valid);
       assert property (awvalid_stable);
       assert property (awready_wait);
       assert property (invalid_awburst);
       //assert property (aw_valid_ready_deassert);  
       assert property (w_valid);
       assert property (wvalid_stable);
       assert property (wready_wait);
       // assert property (w_valid_ready_deassert);
       assert property (b_valid);
       assert property (bready_wait);
       //assert property (b_valid_ready_deassert);
endinterface
