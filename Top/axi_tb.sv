//-----------------------------------------------------------------------------
// CLASS: AXI_tb
// DESCRIPTION:
// - Testbench environment for the AXI design, extending `uvm_env`.
// - Contains all major components, including the axi_master and Slave environments,
//   as well as the scoreboard for result checking.
//-----------------------------------------------------------------------------
class AXI_tb extends uvm_env;

  //---------------------------------------------------------------------------
  // UVM COMPONENT UTILS
  //---------------------------------------------------------------------------
  // - Registers the `AXI_tb` class with the UVM factory for dynamic instantiation.
  //---------------------------------------------------------------------------
  `uvm_component_utils(AXI_tb)

  //---------------------------------------------------------------------------
  // CLASS PROPERTIES
  //---------------------------------------------------------------------------
  axi_slave_env slave;               // Instance of the Slave environment
  axi_master_env master;         // Instance of the axi_master environment
  //AXI_scorboard scoreboard;      // Instance of the scoreboard for data verification

  //---------------------------------------------------------------------------
  // CONSTRUCTOR
  //---------------------------------------------------------------------------
  // - Instantiates the `AXI_tb` object with the given name and parent.
  //---------------------------------------------------------------------------
  function new(string name, uvm_component parent=null);
    super.new(name, parent);      // Call the base class constructor
  endfunction : new

  //---------------------------------------------------------------------------
  // BUILD PHASE
  //---------------------------------------------------------------------------
  // - Responsible for creating the major components of the testbench.
  //---------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);     // Call the base class build_phase

    // Create the Slave environment instance
    slave = axi_slave_env::type_id::create("slave", this);

    // Create the axi_master environment instance
    master = axi_master_env::type_id::create("master", this);

    // Create the Scoreboard instance
   // scoreboard = AXI_scorboard::type_id::create("scoreboard", this);
  endfunction : build_phase
/*
  //---------------------------------------------------------------------------
  // CONNECT PHASE
  //---------------------------------------------------------------------------
  // - Establishes connections between the components, specifically analysis ports
  //   and exports for data flow.
  //---------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    // Connect the axi_master monitor's item_collected_port to the Scoreboard's input FIFO
    master.my_agent.monitor.item_collected_port.connect(
        scoreboard.axi_master_in_fifo.analysis_export
    );

    // Connect the Slave monitor's analysis port to the Scoreboard's output FIFO
    slave.agent.monitor.mon2scoreboard_port.connect(
        scoreboard.slave_out_fifo.analysis_export
    );
  endfunction : connect_phase
*/
endclass : AXI_tb

