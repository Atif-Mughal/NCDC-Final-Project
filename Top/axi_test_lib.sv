//-----------------------------------------------------------------------------
// CLASS: base_test
// DESCRIPTION:
// - Base test class for the AXI environment, extending the UVM `uvm_test` class.
// - Sets up the testbench, configures default sequences for the axi_master and Slave
//   agents, and provides hooks for UVM phases.
//-----------------------------------------------------------------------------
class base_test extends uvm_test;

  //---------------------------------------------------------------------------
  // UVM COMPONENT UTILS
  //---------------------------------------------------------------------------
  // - Registers this test class with the UVM factory for dynamic instantiation.
  //---------------------------------------------------------------------------
  `uvm_component_utils(base_test)

  //---------------------------------------------------------------------------
  // CLASS PROPERTIES
  //---------------------------------------------------------------------------
  AXI_tb tb;                      // Handle to the testbench (top-level environment)
  uvm_objection obj;              // UVM objection mechanism for phase control

  //---------------------------------------------------------------------------
  // CONSTRUCTOR
  //---------------------------------------------------------------------------
  // - Instantiates the `base_test` object with the given name and parent.
  //---------------------------------------------------------------------------
  function new(string name, uvm_component parent=null);
    super.new(name, parent);      // Call the base class constructor
  endfunction : new

  //---------------------------------------------------------------------------
  // BUILD PHASE
  //---------------------------------------------------------------------------
  // - Part of the UVM build process, where components and configurations are created.
  // - Configures recording settings and default sequences for agents.
  //---------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);     // Call the base class build_phase

    // Set the recording detail level to UVM_FULL (full transaction recording)
    uvm_config_int::set(this, "*", "recording_detail", UVM_FULL);

    // Set the default sequence for the axi_master sequencer
    uvm_config_wrapper::set(
        this, 
        "*master*sequencer.run_phase", 
        "default_sequence", 
        axi_master_interrupt_zero_seq::get_type()
    );

    // Set the default sequence for the Slave sequencer
    uvm_config_wrapper::set(
        this, 
        "*slave*sequencer.run_phase", 
        "default_sequence", 
        AXI_read_sequence_seq::get_type()
    );

    // Create the testbench instance
    tb = AXI_tb::type_id::create("tb", this);
  endfunction : build_phase

  //---------------------------------------------------------------------------
  // RUN PHASE
  //---------------------------------------------------------------------------
  // - Controls the main simulation loop and test execution.
  // - Uses UVM objections to manage phase transitions.
  //---------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    super.run_phase(phase);       // Call the base class run_phase

    // Get the objection handle for this phase
    obj = phase.get_objection();

    // Set a drain time of 10ns to allow processes to complete before phase ends
    obj.set_drain_time(this, 10ns);
  endtask : run_phase

  //---------------------------------------------------------------------------
  // END OF ELABORATION PHASE
  //---------------------------------------------------------------------------
  // - Prints the UVM topology for verification and debugging.
  //---------------------------------------------------------------------------
  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();     // Print the UVM component hierarchy
  endfunction : end_of_elaboration_phase

endclass : base_test
