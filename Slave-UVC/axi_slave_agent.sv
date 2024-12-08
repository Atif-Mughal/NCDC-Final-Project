//==============================================================================
//
// CLASS: axi_slave_agent
// DESCRIPTION:
// - A UVM agent for the axi_slave protocol.
// - Responsible for driving, monitoring, and sequencing transactions.
//
//==============================================================================

class axi_slave_agent extends uvm_agent;

  //---------------------------------------------------------------------------
  // MEMBER VARIABLES
  //---------------------------------------------------------------------------
  // This field determines whether an agent is active or passive.
  protected uvm_active_passive_enum is_active = UVM_ACTIVE;

  // Instances of the axi_slave monitor, driver, and sequencer components.
  axi_slave_monitor          monitor;   // Monitors transactions on the interface
  axi_slave_driver           driver;    // Drives transactions to the DUT
  axi_slave_sequencer        sequencer; // Sequences transaction items
  
  // Macro to register the component with UVM Factory
  `uvm_component_utils(axi_slave_agent)

  //---------------------------------------------------------------------------
  // CONSTRUCTOR: new
  //---------------------------------------------------------------------------
  // Creates an instance of the agent with the specified name and parent.
  //---------------------------------------------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------------------------------------------
  // PHASE: build_phase
  //---------------------------------------------------------------------------
  // - Builds the agent components.
  // - Creates the monitor, driver, and sequencer instances.
  //---------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Create the monitor instance
    monitor = axi_slave_monitor::type_id::create("monitor", this);
    
    if (is_active == UVM_ACTIVE) begin
      // Create the driver and sequencer if the agent is active
      sequencer = axi_slave_sequencer::type_id::create("sequencer", this);
      driver    = axi_slave_driver::type_id::create("driver", this);
    end
  endfunction : build_phase

  //---------------------------------------------------------------------------
  // PHASE: connect_phase
  //---------------------------------------------------------------------------
  // - Connects the driver to the sequencer.
  // - Establishes the producer-consumer relationship.
  //---------------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    if (is_active == UVM_ACTIVE) begin
      // Connect driver sequencer port to sequencer export
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : axi_slave_agent