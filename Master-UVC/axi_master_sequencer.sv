//------------------------------------------------------------------------------
// CLASS: axi_master_sequencer
// DESCRIPTION:
// - This class represents the UVM sequencer for the axi_master interface.
// - It is responsible for arbitrating and controlling the execution of
//   sequences that generate transactions for the axi_master driver.
// INHERITANCE:
// - Extends `uvm_sequencer` with the transaction type `axi_master_seq_item`.
//------------------------------------------------------------------------------ 

class axi_master_sequencer extends uvm_sequencer #(axi_master_seq_item);

  //--------------------------------------------------------------------------
  // MACRO: `uvm_component_utils
  // DESCRIPTION:
  // - Registers the sequencer class with the UVM factory.
  // - Enables dynamic creation and type identification during the testbench
  //   execution.
  //--------------------------------------------------------------------------
  `uvm_component_utils(axi_master_sequencer)

  //--------------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_master_sequencer` class.
  // - Initializes the sequencer instance with a specified name and parent
  //   component in the UVM hierarchy.
  // PARAMETERS:
  // - name: The name of the sequencer instance (default provided by UVM).
  // - parent: The parent UVM component to which this sequencer belongs.
  //--------------------------------------------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent); // Calls the parent class constructor.
  endfunction : new

endclass : axi_master_sequencer
