class axi_master_base_seq extends uvm_sequence #(axi_master_seq_item);

  // Required macro for sequences automation
  `uvm_object_utils(axi_master_base_seq)

  // Constructor
  function new(string name="axi_master_base_seq");
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
endclass : axi_master_base_seq

//---------------------------------------------------------------------
// CLASS: axi_master_reset
// DESCRIPTION:
// - A UVM sequence to reset the AXI interface by asserting the 
//   `rst_i` signal.
// INHERITANCE:
// - Extends `axi_master_base_seq` to reuse common sequence functionality.
//---------------------------------------------------------------------
class axi_master_reset extends axi_master_base_seq;
  
  //--------------------------------------------------------------------------
  // MACRO: `uvm_object_utils
  // DESCRIPTION:
  // - Registers the sequence with the UVM factory for dynamic creation.
  // - Enables the use of the sequence in a simulation environment.
  //--------------------------------------------------------------------------
  `uvm_object_utils(axi_master_reset)

  //---------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_master_reset` class.
  // - Initializes the sequence with a default or user-specified name.
  // PARAMETERS:
  // - name: Name of the sequence instance (default: "axi_master_reset").
  //---------------------------------------------------------------------
  function new(string name = "axi_master_reset");
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
    `uvm_info(get_type_name(), "Executing wishbone_reset sequence", UVM_LOW)

    // Send a transaction request to assert the reset signal (`rst_i`).
    `uvm_do_with(req, {
                   ARESETn == 1'b0; // Set `rst_i` to high to perform reset.
                 })
  endtask

endclass : axi_master_reset

//---------------------------------------------------------------------
// CLASS: axi_master_write_seq
// DESCRIPTION:
// - A UVM sequence to perform an AXI4 write transaction.
// INHERITANCE:
// - Extends `axi_master_base_seq` to reuse common sequence functionality.
//---------------------------------------------------------------------
class axi_master_write_seq extends axi_master_base_seq;
  
  //--------------------------------------------------------------------------
  // MACRO: `uvm_object_utils
  // DESCRIPTION:
  // - Registers the sequence with the UVM factory for dynamic creation.
  // - Enables the use of the sequence in a simulation environment.
  //--------------------------------------------------------------------------
  `uvm_object_utils(axi_master_write_seq)

  //---------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_master_write_seq` class.
  // - Initializes the sequence with a default or user-specified name.
  // PARAMETERS:
  // - name: Name of the sequence instance (default: "axi_master_write_seq").
  //---------------------------------------------------------------------
  function new(string name = "axi_master_write_seq");
    super.new(name); // Calls the parent class constructor.
  endfunction

  //---------------------------------------------------------------------
  // TASK: body
  // DESCRIPTION:
  // - Implements the main execution logic of the sequence.
  // - Performs an AXI4 write transaction with valid address and data.
  // LOGGING:
  // - Prints an informational message when the sequence is executed.
  //---------------------------------------------------------------------
  virtual task body();
    `uvm_info(get_type_name(), "Executing AXI Master Write sequence", UVM_LOW)

    // Randomize and configure the write request
    `uvm_do_with(req, {
      AWADDR == 32'h1000;    // Target address for write
      AWLEN  == 8'h4;         // Write burst length
      AWSIZE == 3'b010;    // Write size (4 bytes per beat)
      AWBURST == 2'b01;    // INCR burst
      WDATA  == 32'hA5A5A5A5; // Write data pattern
      WLAST  == 1'b1;      // Last beat of the transaction
    })
  endtask

endclass : axi_master_write_seq

//---------------------------------------------------------------------
// CLASS: axi_master_read_seq
// DESCRIPTION:
// - A UVM sequence to perform an AXI4 read transaction.
// INHERITANCE:
// - Extends `axi_master_base_seq` to reuse common sequence functionality.
//---------------------------------------------------------------------
class axi_master_read_seq extends axi_master_base_seq;
  
  //--------------------------------------------------------------------------
  // MACRO: `uvm_object_utils
  // DESCRIPTION:
  // - Registers the sequence with the UVM factory for dynamic creation.
// - Enables the use of the sequence in a simulation environment.
//---------------------------------------------------------------------------
  `uvm_object_utils(axi_master_read_seq)

  //---------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_master_read_seq` class.
  // - Initializes the sequence with a default or user-specified name.
  // PARAMETERS:
  // - name: Name of the sequence instance (default: "axi_master_read_seq").
  //---------------------------------------------------------------------
  function new(string name = "axi_master_read_seq");
    super.new(name); // Calls the parent class constructor.
  endfunction

  //---------------------------------------------------------------------
  // TASK: body
  // DESCRIPTION:
  // - Implements the main execution logic of the sequence.
  // - Performs an AXI4 read transaction with valid address and length.
  // LOGGING:
  // - Prints an informational message when the sequence is executed.
  //---------------------------------------------------------------------
  virtual task body();
    `uvm_info(get_type_name(), "Executing AXI Master Read sequence", UVM_LOW)

    // Randomize and configure the read request
    `uvm_do_with(req, {
      ARADDR == 32'h1000;    // Target address for read
      ARLEN  == 8'h8;         // Read burst length
      ARSIZE == 3'b010;    // Read size (4 bytes per beat)
      ARBURST == 2'b01;    // INCR burst
    })
  endtask

endclass : axi_master_read_seq


//---------------------------------------------------------------------
// CLASS: axi_master_mixed_seq
// DESCRIPTION:
// - A UVM sequence to perform both AXI4 read and write transactions.
// INHERITANCE:
// - Extends `axi_master_base_seq` to reuse common sequence functionality.
//---------------------------------------------------------------------
class axi_master_mixed_seq extends axi_master_base_seq;
  
  //--------------------------------------------------------------------------
  // MACRO: `uvm_object_utils
  // DESCRIPTION:
  // - Registers the sequence with the UVM factory for dynamic creation.
// - Enables the use of the sequence in a simulation environment.
//---------------------------------------------------------------------------
  `uvm_object_utils(axi_master_mixed_seq)

  //---------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_master_mixed_seq` class.
  // - Initializes the sequence with a default or user-specified name.
  // PARAMETERS:
  // - name: Name of the sequence instance (default: "axi_master_mixed_seq").
  //---------------------------------------------------------------------
  function new(string name = "axi_master_mixed_seq");
    super.new(name); // Calls the parent class constructor.
  endfunction

  //---------------------------------------------------------------------
  // TASK: body
  // DESCRIPTION:
  // - Implements the main execution logic of the sequence.
  // - Performs a write followed by a read to verify data integrity.
  // LOGGING:
  // - Prints an informational message when the sequence is executed.
  //---------------------------------------------------------------------
  virtual task body();
    `uvm_info(get_type_name(), "Executing AXI Master Mixed sequence", UVM_LOW)

    // Perform a write transaction
    `uvm_do_with(req, {
      ARESETn == 1'b0;
      AWADDR == 32'h2000;    // Write target address
      AWLEN  == 8'h4;         // Write burst length
      AWSIZE == 3'b010;    // Write size
      WDATA  == 32'hDEADBEEF; // Write data
      WLAST  == 1'b1;      // End of burst
    })

    // Perform a read transaction
    `uvm_do_with(req, {
      ARESETn == 1'b0;
      ARADDR == 32'h2000;    // Read target address (same as write)
      ARLEN  == 8'h4;         // Read burst length
      ARSIZE == 3'b010;    // Read size
    })
  endtask

endclass : axi_master_mixed_seq


