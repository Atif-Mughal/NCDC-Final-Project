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
class axi_master_write_addr extends axi_master_base_seq;
  
  //--------------------------------------------------------------------------
  // MACRO: `uvm_object_utils
  // DESCRIPTION:
  // - Registers the sequence with the UVM factory for dynamic creation.
  // - Enables the use of the sequence in a simulation environment.
  //--------------------------------------------------------------------------
  `uvm_object_utils(axi_master_write_addr)

  //---------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_master_write_addr` class.
  // - Initializes the sequence with a default or user-specified name.
  // PARAMETERS:
  // - name: Name of the sequence instance (default: "axi_master_write_addr").
  //---------------------------------------------------------------------
  function new(string name = "axi_master_write_addr");
    super.new(name); // Calls the parent class constructor.
  endfunction
  rand bit [31:0] wr_addr;
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
      AWADDR == wr_addr;    // Target address for write
      AWLEN  == 8'h0;         // Write burst length
      AWSIZE == 3'b010;    // Write size (4 bytes per beat)
      AWBURST == 2'b00;    // INCR burst
      AWVALID == 1'b1;
    })
  endtask

endclass : axi_master_write_addr

//---------------------------------------------------------------------
// CLASS: axi_master_read_seq
// DESCRIPTION:
// - A UVM sequence to perform an AXI4 read transaction.
// INHERITANCE:
// - Extends `axi_master_base_seq` to reuse common sequence functionality.
//---------------------------------------------------------------------
class axi_master_write_data extends axi_master_base_seq;
  
  //--------------------------------------------------------------------------
  // MACRO: `uvm_object_utils
  // DESCRIPTION:
  // - Registers the sequence with the UVM factory for dynamic creation.
// - Enables the use of the sequence in a simulation environment.
//---------------------------------------------------------------------------
  `uvm_object_utils(axi_master_write_data)

  //---------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_master_write_data` class.
  // - Initializes the sequence with a default or user-specified name.
  // PARAMETERS:
  // - name: Name of the sequence instance (default: "axi_master_write_data").
  //---------------------------------------------------------------------
  function new(string name = "axi_master_write_data");
    super.new(name); // Calls the parent class constructor.
  endfunction
  rand bit[31:0] wr_data;
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
      WVALID == 1'b1;
      WDATA  == wr_data; // Write data pattern
      WLAST  == 1'b1;      // Last beat of the transaction
      WSTRB == 4'b1111;
    })
  endtask

endclass : axi_master_write_data

class axi_master_write_response extends axi_master_base_seq;
  
  //--------------------------------------------------------------------------
  // MACRO: `uvm_object_utils
  // DESCRIPTION:
  // - Registers the sequence with the UVM factory for dynamic creation.
// - Enables the use of the sequence in a simulation environment.
//---------------------------------------------------------------------------
  `uvm_object_utils(axi_master_write_response)

  //---------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_master_write_response` class.
  // - Initializes the sequence with a default or user-specified name.
  // PARAMETERS:
  // - name: Name of the sequence instance (default: "axi_master_write_response").
  //---------------------------------------------------------------------
  function new(string name = "axi_master_write_response");
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
      WREADY == 1'b1;
    })
  endtask

endclass : axi_master_write_response

//---------------------------------------------------------------------
// CLASS: axi_master_read_seq
// DESCRIPTION:
// - A UVM sequence to perform an AXI4 read transaction.
// INHERITANCE:
// - Extends `axi_master_base_seq` to reuse common sequence functionality.
//---------------------------------------------------------------------
class axi_master_read_addr extends axi_master_base_seq;
  
  //--------------------------------------------------------------------------
  // MACRO: `uvm_object_utils
  // DESCRIPTION:
  // - Registers the sequence with the UVM factory for dynamic creation.
// - Enables the use of the sequence in a simulation environment.
//---------------------------------------------------------------------------
  `uvm_object_utils(axi_master_read_addr)

  //---------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_master_write_data` class.
  // - Initializes the sequence with a default or user-specified name.
  // PARAMETERS:
  // - name: Name of the sequence instance (default: "axi_master_write_data").
  //---------------------------------------------------------------------
  function new(string name = "axi_master_read_addr");
    super.new(name); // Calls the parent class constructor.
  endfunction
   rand bit [31:0] rd_addr;
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
      AWVALID == 1'b1;
      AWADDR  == rd_addr; // Write data pattern
      ARLEN == 0;                  // Burst length
      ARSIZE == 0;                 // Burst size
      ARBURST == 0; 
    })
  endtask

endclass : axi_master_read_addr

//---------------------------------------------------------------------
// CLASS: axi_master_read_seq
// DESCRIPTION:
// - A UVM sequence to perform an AXI4 read transaction.
// INHERITANCE:
// - Extends `axi_master_base_seq` to reuse common sequence functionality.
//---------------------------------------------------------------------
class axi_master_read_data extends axi_master_base_seq;
  
  //--------------------------------------------------------------------------
  // MACRO: `uvm_object_utils
  // DESCRIPTION:
  // - Registers the sequence with the UVM factory for dynamic creation.
// - Enables the use of the sequence in a simulation environment.
//---------------------------------------------------------------------------
  `uvm_object_utils(axi_master_read_data)

  //---------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_master_read_data` class.
  // - Initializes the sequence with a default or user-specified name.
  // PARAMETERS:
  // - name: Name of the sequence instance (default: "axi_master_read_data").
  //---------------------------------------------------------------------
  function new(string name = "axi_master_read_data");
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
      RREADY == 1'b1;
    })
  endtask

endclass : axi_master_read_data

class axi_master_write_operation extends axi_master_base_seq;
  
  //--------------------------------------------------------------------------
  // MACRO: `uvm_object_utils
  // DESCRIPTION:
  // - Registers the sequence with the UVM factory for dynamic creation.
// - Enables the use of the sequence in a simulation environment.
//---------------------------------------------------------------------------
  `uvm_object_utils(axi_master_write_operation)
  
   axi_master_write_addr  wr_addr_h;
   axi_master_write_data wr_data_h;
   axi_master_write_response wr_resp_h;
    
  //---------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `write_operation` class.
  // - Initializes the sequence with a default or user-specified name.
  // PARAMETERS:
  // - name: Name of the sequence instance (default: "write_operation").
  //---------------------------------------------------------------------
  function new(string name = "axi_master_write_operation");
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
    `uvm_info(get_type_name(), "Executing AXI Master write sequence", UVM_LOW)

    // Randomize and configure the read request
    `uvm_do_with(wr_addr_h, {
         wr_addr == 32'h200;
         })
   `uvm_do_with(wr_data_h, {
         wr_data == 32'hffffffff;
         })      
    `uvm_do(wr_resp_h)
  endtask

endclass : axi_master_write_operation
//---------------------------------------------------------------------
// CLASS: axi_master_read_operation
// DESCRIPTION:
// - A UVM sequence to perform both AXI4 read and write transactions.
// INHERITANCE:
// - Extends `axi_master_base_seq` to reuse common sequence functionality.
//---------------------------------------------------------------------
class axi_master_read_operation extends axi_master_base_seq;
  
  //--------------------------------------------------------------------------
  // MACRO: `uvm_object_utils
  // DESCRIPTION:
  // - Registers the sequence with the UVM factory for dynamic creation.
// - Enables the use of the sequence in a simulation environment.
//---------------------------------------------------------------------------
  `uvm_object_utils(axi_master_read_operation)
  
   axi_master_read_addr  rd_addr_h;
   axi_master_read_data rd_data_h;
    
  //---------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_master_read_operation` class.
  // - Initializes the sequence with a default or user-specified name.
  // PARAMETERS:
  // - name: Name of the sequence instance (default: "axi_master_read_operation").
  //---------------------------------------------------------------------
  function new(string name = "axi_master_read_operation");
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
    `uvm_info(get_type_name(), "Executing AXI Master write sequence", UVM_LOW)

    // Randomize and configure the read request
    `uvm_do_with(rd_addr_h, {
         rd_addr == 32'h200;
         })
    `uvm_do(rd_data_h)
  endtask

endclass : axi_master_read_operation

//---------------------------------------------------------------------
// CLASS: axi_master_read_after_write
// DESCRIPTION:
// - A UVM sequence to perform both AXI4 read and write transactions.
// INHERITANCE:
// - Extends `axi_master_read_after_write` to reuse common sequence functionality.
//---------------------------------------------------------------------
class axi_master_read_after_write extends axi_master_base_seq;
  
  //--------------------------------------------------------------------------
  // MACRO: `uvm_object_utils
  // DESCRIPTION:
  // - Registers the sequence with the UVM factory for dynamic creation.
// - Enables the use of the sequence in a simulation environment.
//---------------------------------------------------------------------------
  `uvm_object_utils(axi_master_read_after_write)
  
   axi_master_read_operation rd_op_h;
   axi_master_write_operation wr_op_h;
    
  //---------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_master_read_after_write` class.
  // - Initializes the sequence with a default or user-specified name.
  // PARAMETERS:
  // - name: Name of the sequence instance (default: "axi_master_read_after_write").
  //---------------------------------------------------------------------
  function new(string name = "axi_master_read_after_write");
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
    `uvm_info(get_type_name(), "Executing AXI Master write sequence", UVM_LOW)

    // Randomize and configure the read request
    `uvm_do(wr_op_h)
    `uvm_do(rd_op_h)
  endtask

endclass : axi_master_read_after_write

//---------------------------------------------------------------------
// CLASS: axi_master_read_after_write
// DESCRIPTION:
// - A UVM sequence to perform both AXI4 read and write transactions.
// INHERITANCE:
// - Extends `axi_master_read_after_write` to reuse common sequence functionality.
//---------------------------------------------------------------------
class axi_master_multiple_write extends axi_master_base_seq;
  
  //--------------------------------------------------------------------------
  // MACRO: `uvm_object_utils
  // DESCRIPTION:
  // - Registers the sequence with the UVM factory for dynamic creation.
// - Enables the use of the sequence in a simulation environment.
//---------------------------------------------------------------------------
  `uvm_object_utils(axi_master_multiple_write)
   axi_master_write_operation mul_wr_op_h;

    
  //---------------------------------------------------------------------
  // FUNCTION: new
  // DESCRIPTION:
  // - Constructor for the `axi_master_read_after_write` class.
  // - Initializes the sequence with a default or user-specified name.
  // PARAMETERS:
  // - name: Name of the sequence instance (default: "axi_master_read_after_write").
  //---------------------------------------------------------------------
  function new(string name = "axi_master_multiple_write");
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
    `uvm_info(get_type_name(), "Executing AXI Master write sequence", UVM_LOW)

    // Randomize and configure the read request
    repeat(5)
      `uvm_do(mul_wr_op_h)
    
  endtask

endclass : axi_master_multiple_write
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
