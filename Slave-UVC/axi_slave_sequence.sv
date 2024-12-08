class axi_slave_base_seq extends uvm_sequence #(axi_slave_seq_item);

  // Required macro for sequences automation
  `uvm_object_utils(axi_slave_base_seq)

  // Constructor
  function new(string name="axi_slave_base_seq");
    super.new(name);
  endfunction
  task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body
  task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body
endclass : axi_slave_base_seq

//---------------------------------------------------------------------
// CLASS: axi_master_reset
// DESCRIPTION:
// - A UVM sequence to reset the AXI interface by asserting the 
//   `rst_i` signal.
// INHERITANCE:
// - Extends `axi_slave_base_seq` to reuse common sequence functionality.
//---------------------------------------------------------------------
class axi_slave_reset extends axi_master_base_seq;
  
  //--------------------------------------------------------------------------
  // MACRO: `uvm_object_utils
  // DESCRIPTION:
  // - Registers the sequence with the UVM factory for dynamic creation.
  // - Enables the use of the sequence in a simulation environment.
  //--------------------------------------------------------------------------
  `uvm_object_utils(axi_slave_reset)

  //---------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_slave_reset` class.
  // - Initializes the sequence with a default or user-specified name.
  // PARAMETERS:
  // - name: Name of the sequence instance (default: "axi_slave_reset").
  //---------------------------------------------------------------------
  function new(string name = "axi_slave_reset");
    super.new(name); // Calls the parent class constructor.
  endfunction

  //---------------------------------------------------------------------
  // TASK: body
  // DESCRIPTION:
  // - Implements the main execution logic of the sequence.
  // - Resets the Wishbone interface by asserting the `rst_i` signal.
  // LOGGING:
  // - Prints an informational message when the sequence is executed.
  //---------------------------------------------------------------------
  virtual task body();
    // Log a message indicating the start of the sequence execution.
    `uvm_info(get_type_name(), "Executing axi_slave_reset sequence", UVM_LOW)

    // Send a transaction request to assert the reset signal (`rst_i`).
    `uvm_do_with(req, {
                   ARESETn == 1'b1; // Set `rst_i` to high to perform reset.
                 })
  endtask

endclass : axi_slave_reset