import axi_parameters::*;
interface axi4_if (input bit clk);
    // Write Address
    logic [8:0] AWID;
    logic [ADDR_WIDTH-1:0] AWADDR;
    logic [3:0] AWLEN;
    logic [2:0] AWSIZE;
    logic [1:0] AWBURST;
    logic AWVALID, AWREADY;

    // Write Data
    logic [8:0] WID;
    logic [DATA_WIDTH-1:0] WDATA;
    logic [(DATA_WIDTH/8)-1:0] WSTRB;
    logic WLAST, WVALID, WREADY;

    // Write Response
    logic [8:0] BID;
    logic [1:0] BRESP;
    logic BVALID, BREADY;

    // Read Address
    logic [8:0] ARID;
    logic [ADDR_WIDTH-1:0] ARADDR;
    logic [3:0] ARLEN;
    logic [2:0] ARSIZE;
    logic [1:0] ARBURST;
    logic ARVALID, ARREADY;

    // Read Data
    logic [8:0] RID;
    logic [DATA_WIDTH-1:0] RDATA;
    logic [1:0] RRESP;
    logic RLAST, RVALID, RREADY;

    clocking master_driver_cb @(posedge clk);
        output AWID, AWADDR, AWLEN, AWSIZE, AWBURST,AWVALID, WID, WDATA, WSTRB, WLAST, WVALID, BREADY, ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID, RREADY;
        input AWREADY, WREADY, BID, BRESP, BVALID, ARREADY, RID, RDATA, RRESP, RLAST, RVALID;
    endclocking

    clocking monitor_cb @(posedge clk);
        input AWID, AWADDR, AWLEN, AWSIZE, AWBURST,AWVALID, WID, WDATA, WSTRB, WLAST, WVALID, BREADY, ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID, RREADY;
        input AWREADY, WREADY, BID, BRESP, BVALID, ARREADY, RID, RDATA, RRESP, RLAST, RVALID;
    endclocking

    clocking slave_driver_cb @(posedge clk);
        input AWID, AWADDR, AWLEN, AWSIZE, AWBURST,AWVALID, WID, WDATA, WSTRB, WLAST, WVALID, BREADY, ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID, RREADY;
        output AWREADY, WREADY, BID, BRESP, BVALID, ARREADY, RID, RDATA, RRESP, RLAST, RVALID;
    endclocking

    modport Master_Driver_MP(clocking master_driver_cb);
    modport Master_Monitor_MP(clocking monitor_cb);
    modport Slave_Driver_MP(clocking slave_driver_cb);
    modport Slave_Monitor_MP(clocking monitor_cb);
    
    

    // *************************************************************************************************
    //                                      Assertions
    // *************************************************************************************************
    // Property to check whether all write address channel remains stable after AWVALID is asserted
    property aw_valid;
        @(posedge clk) $rose(AWVALID) |-> ( $stable(AWID)   
                                            &&$stable(AWADDR)
                                            &&$stable(AWLEN)
                                            &&$stable(AWSIZE) 
                                            &&$stable(AWBURST)) throughout AWREADY[->1];
    endproperty

    // Property to check whether all write address channel remains stable after AWVALID is asserted
    property w_valid;
        @(posedge clk) $rose(WVALID) |-> (  $stable(WID) 
                                            && $stable(WDATA)
                                            && $stable(WSTRB)
                                            && $stable(WLAST)) throughout WREADY[->1];
    endproperty

    // Property to check whether all write address channel remains stable after AWVALID is asserted
    property b_valid;
        @(posedge clk) $rose(BVALID) |-> (  $stable(BID) 
                                            && $stable(BRESP)) throughout BREADY[->1];
    endproperty

    // Property to check whether all write address channel remains stable after AWVALID is asserted
    property ar_valid;
        @(posedge clk) $rose(ARVALID) |-> ( $stable(ARID)   
                                            &&$stable(ARADDR)
                                            &&$stable(ARLEN)
                                            &&$stable(ARSIZE) 
                                            &&$stable(ARBURST)) throughout ARREADY[->1];
    endproperty

    // Property to check whether all write address channel remains stable after AWVALID is asserted
    property r_valid;
        @(posedge clk) $rose(RVALID) |-> (  $stable(RID) 
                                            && $stable(RDATA)
                                            && $stable(RRESP)
                                            && $stable(RLAST)) throughout RREADY[->1];
    endproperty

    assert property (aw_valid);
    assert property (w_valid);
    assert property (b_valid);
    assert property (ar_valid);
    assert property (r_valid);
endinterface //axi_intf
