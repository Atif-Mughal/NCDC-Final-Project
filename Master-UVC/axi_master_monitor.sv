//------------------------------------------------------------------------------
//
// CLASS: axi_master_monitor
//
//------------------------------------------------------------------------------

class axi_master_monitor extends uvm_monitor;

  // This property is the virtual interfaced needed for this component to drive 
  // and view HDL signals. 
  virtual axi_master_if vif;
  int packet_count = 1;

  // This port is used to connect the monitor to the scoreboard
  uvm_analysis_port #(axi_master_seq_item) item_collected_port;

  //  Current monitored transaction  
  axi_master_seq_item item;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils(axi_master_monitor)

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    if (!AXI_if_config::get(this, get_full_name(),"vif", vif))
      `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: build_phase

  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase (uvm_phase phase);
    // phase.raise_objection(this, get_type_name());
    super.run_phase(phase);
    `uvm_info("MONITOR_CLASS", "Inside Run Phase!", UVM_LOW)
    @(negedge vif.clock);

    forever 
    begin
      item = axi_master_monitor::type_id::create("item");
    
      
    //   wait(!vif.reset);
      
      //sample inputs
    // Wait for a positive edge of the clock before sampling signals
    @(posedge vif.CLK);
    
    // Sample input signals from the virtual interface (AXI4 Write signals)
    item.AWADDR   = vif.AWADDR;
    item.AWLEN    = vif.AWLEN;
    item.AWSIZE   = vif.AWSIZE;
    item.AWBURST  = vif.AWBURST;
    item.AWLOCK   = vif.AWLOCK;
    item.AWCACHE  = vif.AWCACHE;
    item.AWPROT   = vif.AWPROT;
    item.AWVALID  = vif.AWVALID;
    
    item.WDATA    = vif.WDATA;
    item.WSTRB    = vif.WSTRB;
    item.WLAST    = vif.WLAST;
    item.WVALID   = vif.WVALID;
    
    // For write response (BREADY signal)
    item.BREADY   = vif.BREADY;

    // Wait for a negative edge of the clock to sample output signals
    @(negedge vif.CLK);
    
    // Sample output signals from the virtual interface (AXI4 Read signals)
    item.BID      = vif.BID;
    item.BRESP    = vif.BRESP;
    item.BVALID   = vif.BVALID;

    item.ARADDR   = vif.ARADDR;
    item.ARLEN    = vif.ARLEN;
    item.ARSIZE   = vif.ARSIZE;
    item.ARBURST  = vif.ARBURST;
    item.ARLOCK   = vif.ARLOCK;
    item.ARCACHE  = vif.ARCACHE;
    item.ARPROT   = vif.ARPROT;
    item.ARVALID  = vif.ARVALID;

    // For read data
    item.RID      = vif.RID;
    item.RDATA    = vif.RDATA;
    item.RRESP    = vif.RRESP;
    item.RLAST    = vif.RLAST;
    item.RVALID   = vif.RVALID;
    item.RREADY   = vif.RREADY;
      
      // send item to scoreboard
      item_collected_port.write(item);
      `uvm_info(get_type_name(), $sformatf("Sending Packet :\n%s \n packet no: %d \n", item.sprint(),packet_count), UVM_LOW)
      packet_count++;
    //   phase.drop_objection(this, get_type_name());
    end
        
  endtask: run_phase


endclass : axi_master_monitor