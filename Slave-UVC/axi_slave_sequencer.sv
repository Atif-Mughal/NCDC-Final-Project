//------------------------------------------------------------------------------
// CLASS: axi_slave_sequencer
// DESCRIPTION:
// - This class represents the UVM sequencer for the axi_slave interface.
// - It is responsible for arbitrating and controlling the execution of
//   sequences that generate transactions for the axi_slave driver.
// INHERITANCE:
// - Extends `uvm_sequencer` with the transaction type `axi_slave_seq_item`.
//------------------------------------------------------------------------------ 

class axi_slave_sequencer extends uvm_sequencer #(axi_slave_seq_item);

  //--------------------------------------------------------------------------
  // MACRO: `uvm_component_utils
  // DESCRIPTION:
  // - Registers the sequencer class with the UVM factory.
  // - Enables dynamic creation and type identification during the testbench
  //   execution.
  //--------------------------------------------------------------------------
  `uvm_component_utils(axi_slave_sequencer)

  //--------------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_slave_sequencer` class.
  // - Initializes the sequencer instance with a specified name and parent
  //   component in the UVM hierarchy.
  // PARAMETERS:
  // - name: The name of the sequencer instance (default provided by UVM).
  // - parent: The parent UVM component to which this sequencer belongs.
  //--------------------------------------------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent); // Calls the parent class constructor.
  endfunction : new

endclass : axi_slave_sequencer
