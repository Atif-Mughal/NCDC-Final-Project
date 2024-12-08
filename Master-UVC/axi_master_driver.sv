//==============================================================================
//
// CLASS: axi_master_driver
// DESCRIPTION:
// - Implements the AXI driver functionality in UVM.
// - Responsible for driving transactions to the DUT and communicating
//   with the sequencer.
//
//==============================================================================

class axi_master_driver extends uvm_driver#(axi_master_seq_item);

  //---------------------------------------------------------------------------
  // MEMBER VARIABLES
  //---------------------------------------------------------------------------
  // Virtual interface for driving signals to the DUT
  virtual axi4_if vif;

  // Instance of the analysis port for CPOL and CPHA
  uvm_analysis_port #(axi_master_seq_item) item_port_scb;

  // Transaction item to be driven to the DUT
  axi_master_seq_item item;

  //---------------------------------------------------------------------------
  // REGISTER COMPONENT WITH UVM FACTORY
  //---------------------------------------------------------------------------
  `uvm_component_utils(axi_master_driver)

  //---------------------------------------------------------------------------
  // CONSTRUCTOR: new
  //---------------------------------------------------------------------------
  // Creates an instance of the driver with the specified name and parent.
  //---------------------------------------------------------------------------
  function new (string name = "axi_master_driver", uvm_component parent);
    super.new(name, parent);

    // Informational message indicating the driver construction
    `uvm_info(get_type_name(), "Inside axi_master_driver constructor", UVM_HIGH)

    // Create the analysis port for monitoring transactions
    item_port_scb = new("item_port_scb", this);
  endfunction : new

  //---------------------------------------------------------------------------
  // PHASE: build_phase
  //---------------------------------------------------------------------------
  // - Retrieves the virtual interface configuration.
  // - Reports an error if the interface is not set.
  //---------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Check and retrieve the virtual interface from the configuration
    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "vif", vif)) begin
      `uvm_error("NOVIF", "vif not set")
    end
  endfunction : build_phase

  //---------------------------------------------------------------------------
  // PHASE: run_phase
  //---------------------------------------------------------------------------
  // - Runs continuously, fetching transactions from the sequencer and driving
  //   them to the DUT.
  //---------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    forever begin
      // Create a new transaction item
      item = axi_master_seq_item::type_id::create("item");

      // Fetch the next transaction from the sequencer
      seq_item_port.get_next_item(item);

      // Drive the transaction to the DUT
      send_to_dut(item);

      // Mark the transaction as done
      seq_item_port.item_done();
    end
  endtask : run_phase

  //---------------------------------------------------------------------------
  // TASK: send_to_dut
  //---------------------------------------------------------------------------
  // - Drives the AXI transaction signals to the DUT.
  // - Logs the transaction details for debugging purposes.
  //---------------------------------------------------------------------------
task send_to_dut(axi_master_seq_item item);
    // Log the information about the sequence item for debugging purposes
    `uvm_info(get_type_name(), $sformatf("Packet is \n %s", item.sprint()), UVM_LOW)
    // Wait for a negative edge of the clock before driving signals
    @(negedge vif.clock);
    vif.ARESETn <= item.ARESETn;

    // Drive signals to the virtual interface based on the transaction item
    // Write Address Channel (AW)
    vif.AWADDR <= item.AWADDR;
    vif.AWLEN <= item.AWLEN;
    vif.AWSIZE <= item.AWSIZE;
    vif.AWBURST <= item.AWBURST;
    vif.AWLOCK <= item.AWLOCK;
    vif.AWCACHE <= item.AWCACHE;
    vif.AWPROT <= item.AWPROT;
    vif.AWVALID <= item.AWVALID;

    // Write Data Channel (W)
    vif.WDATA <= item.WDATA;
    vif.WSTRB <= item.WSTRB;
    vif.WLAST <= item.WLAST;
    vif.WVALID <= item.WVALID;

    // Write Response Channel (B) - only set once the response is received
    vif.BREADY <= item.BREADY;

    // Read Address Channel (AR)
    vif.ARADDR <= item.ARADDR;
    vif.ARLEN <= item.ARLEN;
    vif.ARSIZE <= item.ARSIZE;
    vif.ARBURST <= item.ARBURST;
    vif.ARLOCK <= item.ARLOCK;
    vif.ARCACHE <= item.ARCACHE;
    vif.ARPROT <= item.ARPROT;
    vif.ARVALID <= item.ARVALID;

    // Read Data Channel (R) - only set once the response is received
    vif.RREADY <= item.RREADY;

endtask : send_to_dut

  //---------------------------------------------------------------------------
  // PHASE: start_of_simulation_phase
  //---------------------------------------------------------------------------
  // - Logs an informational message at the start of the simulation.
  //---------------------------------------------------------------------------
  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "I am here", UVM_HIGH)
  endfunction : start_of_simulation_phase

endclass : axi_master_driver
