
// ******************************************************************************************
//                                    AXI TEST CLASSES
// ******************************************************************************************
import config_pkg::*;
// ==========================================================================================
//                              AXI BASE TEST CLASS
// ==========================================================================================
class axi_base_test extends uvm_test;
    `uvm_component_utils(axi_base_test)

    //---------------------------------------------------------------------------
    // Components:
    // - Instantiates various sequences and configuration objects required for the test.
    //---------------------------------------------------------------------------
    AXI_tb env;                     // Testbench environment instance
    axi_write_sequence write_seq;   // Write sequence for the test
    axi_read_sequence read_seq;     // Read sequence for the test
    test_config test_cfg;           // Test configuration object

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_base_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);              // Call base class constructor
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings and instantiates sequences.
    // - Registers test configuration in the UVM database.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        uvm_config_db#(test_config)::set(null, "*", "test_cfg", test_cfg); // Set test configuration in UVM database
        write_seq = new("write_seq");                   // Instantiate write sequence
        read_seq = new("read_seq");                     // Instantiate read sequence
        env = AXI_tb::type_id::create("env", this);      // Create testbench environment instance
    endfunction: build_phase

    //---------------------------------------------------------------------------
    // End of Elaboration Phase:
    // - Completes the elaboration phase and prints the UVM topology.
    //---------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);       // Invoke base class end of elaboration phase
        uvm_top.print_topology();                    // Print the current UVM testbench topology
    endfunction: end_of_elaboration_phase

endclass: axi_base_test


// ==========================================================================================
//                                  RESET TEST CASE
// ==========================================================================================
class axi_reset_test extends axi_base_test;
    `uvm_component_utils(axi_reset_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_reset_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures the reset signal for the test.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);      // Invoke base class build phase
        test_cfg.ARESET_n = 0;         // Set the reset signal to low (inactive)
    endfunction: build_phase

    //---------------------------------------------------------------------------
    // End of Elaboration Phase:
    // - Completes the elaboration phase for the reset test case.
    //---------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);  // Invoke base class end of elaboration phase
    endfunction: end_of_elaboration_phase

    //---------------------------------------------------------------------------
    // Run Phase:
    // - Executes the write sequence for the reset test case.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);             // Raise objection to keep simulation running
        write_seq.start(env.master.my_agent.write_seqr); // Start the write sequence
        phase.drop_objection(this);              // Drop objection after sequence completes
    endtask: run_phase
endclass: axi_reset_test

// ==========================================================================================
//                              AXI SINGLE WRITE FIXED TEST CLASS
// ==========================================================================================
class axi_single_write_fixed_test extends axi_base_test;
    `uvm_component_utils(axi_single_write_fixed_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_single_write_fixed_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
        test_cfg = new("test_cfg");           // Create a new test configuration object
        test_cfg.number_of_write_cases = 1;  // Set number of write cases
        test_cfg.ARESET_n = 1;     // Set reset signal to active (low)
        test_cfg.burst_type = 0;
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for AXI write operation.
    // - Instantiates write sequence for the test.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  // Invoke base class build phase
        
    endfunction: build_phase

    //---------------------------------------------------------------------------
    // End of Elaboration Phase:
    // - Completes the elaboration phase for the test.
    //---------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);  // Complete the elaboration phase
    endfunction: end_of_elaboration_phase

    //---------------------------------------------------------------------------
    // Run Phase:
    // - Starts the write sequence and raises/drops objections during the phase.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);            // Raise objection to keep simulation running
        write_seq.start(env.master.my_agent.write_seqr); // Start write sequence
        phase.drop_objection(this);             // Drop objection after the sequence starts
    endtask: run_phase
endclass: axi_single_write_fixed_test

// ==========================================================================================
//                              AXI MULTIPLE WRITE FIXED TEST CLASS
// ==========================================================================================
class axi_multiple_write_fixed_test extends axi_base_test;
    `uvm_component_utils(axi_multiple_write_fixed_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_multiple_write_fixed_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
        test_cfg = new("test_cfg");           // Create a new test configuration object
        test_cfg.number_of_write_cases = 30;  // Set number of write cases
        test_cfg.ARESET_n = 1;     // Set reset signal to active (low)
        test_cfg.burst_type = 0;
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for AXI write operation.
    // - Instantiates write sequence for the test.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  // Invoke base class build phase
        
    endfunction: build_phase

    //---------------------------------------------------------------------------
    // End of Elaboration Phase:
    // - Completes the elaboration phase for the test.
    //---------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);  // Complete the elaboration phase
    endfunction: end_of_elaboration_phase

    //---------------------------------------------------------------------------
    // Run Phase:
    // - Starts the write sequence and raises/drops objections during the phase.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);            // Raise objection to keep simulation running
        write_seq.start(env.master.my_agent.write_seqr); // Start write sequence
        phase.drop_objection(this);             // Drop objection after the sequence starts
    endtask: run_phase
endclass: axi_multiple_write_fixed_test

// ==========================================================================================
//                              AXI SINGLE READ FIXED TEST CLASS
// ==========================================================================================
class axi_single_read_fixed_test extends axi_base_test;
    `uvm_component_utils(axi_single_read_fixed_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_single_read_fixed_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
        test_cfg = new("test_cfg");           // Create a new test configuration object
        test_cfg.number_of_read_cases = 1;  // Set number of write cases
        test_cfg.ARESET_n = 1;     // Set reset signal to active (low)
        test_cfg.burst_type = 0;
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for AXI write operation.
    // - Instantiates write sequence for the test.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  // Invoke base class build phase
        
    endfunction: build_phase

    //---------------------------------------------------------------------------
    // End of Elaboration Phase:
    // - Completes the elaboration phase for the test.
    //---------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);  // Complete the elaboration phase
    endfunction: end_of_elaboration_phase

    //---------------------------------------------------------------------------
    // Run Phase:
    // - Starts the write sequence and raises/drops objections during the phase.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);            // Raise objection to keep simulation running
        read_seq.start(env.master.my_agent.read_seqr); // Start write sequence
        phase.drop_objection(this);             // Drop objection after the sequence starts
    endtask: run_phase
endclass: axi_single_read_fixed_test

// ==========================================================================================
//                              AXI MULTIPLE READ FIXED TEST CLASS
// ==========================================================================================
class axi_multiple_read_fixed_test extends axi_base_test;
    `uvm_component_utils(axi_multiple_read_fixed_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_multiple_read_fixed_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
        test_cfg = new("test_cfg");           // Create a new test configuration object
        test_cfg.number_of_read_cases = 30;  // Set number of write cases
        test_cfg.ARESET_n = 1;     // Set reset signal to active (low)
        test_cfg.burst_type = 0;
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for AXI write operation.
    // - Instantiates write sequence for the test.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  // Invoke base class build phase
        
    endfunction: build_phase

    //---------------------------------------------------------------------------
    // End of Elaboration Phase:
    // - Completes the elaboration phase for the test.
    //---------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);  // Complete the elaboration phase
    endfunction: end_of_elaboration_phase

    //---------------------------------------------------------------------------
    // Run Phase:
    // - Starts the write sequence and raises/drops objections during the phase.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);            // Raise objection to keep simulation running
        read_seq.start(env.master.my_agent.read_seqr); // Start write sequence
        phase.drop_objection(this);             // Drop objection after the sequence starts
    endtask: run_phase
endclass: axi_multiple_read_fixed_test

// ==========================================================================================
//                              AXI SINGLE WRITE WRAP TEST CLASS
// ==========================================================================================
class axi_single_write_wrap_test extends axi_base_test;
    `uvm_component_utils(axi_single_write_wrap_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_single_write_wrap_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
        test_cfg = new("test_cfg");           // Create a new test configuration object
        test_cfg.number_of_write_cases = 1;  // Set number of write cases
        test_cfg.ARESET_n = 1;     // Set reset signal to active (low)
        test_cfg.burst_type = 2;
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for AXI write operation.
    // - Instantiates write sequence for the test.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  // Invoke base class build phase
        
    endfunction: build_phase

    //---------------------------------------------------------------------------
    // End of Elaboration Phase:
    // - Completes the elaboration phase for the test.
    //---------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);  // Complete the elaboration phase
    endfunction: end_of_elaboration_phase

    //---------------------------------------------------------------------------
    // Run Phase:
    // - Starts the write sequence and raises/drops objections during the phase.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);            // Raise objection to keep simulation running
        write_seq.start(env.master.my_agent.write_seqr); // Start write sequence
        phase.drop_objection(this);             // Drop objection after the sequence starts
    endtask: run_phase
endclass: axi_single_write_wrap_test

// ==========================================================================================
//                              AXI MULTIPLE WRITE WRAP TEST CLASS
// ==========================================================================================
class axi_multiple_write_wrap_test extends axi_base_test;
    `uvm_component_utils(axi_multiple_write_wrap_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_multiple_write_wrap_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
        test_cfg = new("test_cfg");           // Create a new test configuration object
        test_cfg.number_of_write_cases = 30;  // Set number of write cases
        test_cfg.ARESET_n = 1;     // Set reset signal to active (low)
        test_cfg.burst_type = 2;
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for AXI write operation.
    // - Instantiates write sequence for the test.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  // Invoke base class build phase
        
    endfunction: build_phase

    //---------------------------------------------------------------------------
    // End of Elaboration Phase:
    // - Completes the elaboration phase for the test.
    //---------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);  // Complete the elaboration phase
    endfunction: end_of_elaboration_phase

    //---------------------------------------------------------------------------
    // Run Phase:
    // - Starts the write sequence and raises/drops objections during the phase.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);            // Raise objection to keep simulation running
        write_seq.start(env.master.my_agent.write_seqr); // Start write sequence
        phase.drop_objection(this);             // Drop objection after the sequence starts
    endtask: run_phase
endclass: axi_multiple_write_wrap_test

// ==========================================================================================
//                              AXI SINGLE READ FIXED TEST CLASS
// ==========================================================================================
class axi_single_read_wrap_test extends axi_base_test;
    `uvm_component_utils(axi_single_read_wrap_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_single_read_wrap_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
        test_cfg = new("test_cfg");           // Create a new test configuration object
        test_cfg.number_of_read_cases = 1;  // Set number of write cases
        test_cfg.ARESET_n = 1;     // Set reset signal to active (low)
        test_cfg.burst_type = 2;
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for AXI write operation.
    // - Instantiates write sequence for the test.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  // Invoke base class build phase
        
    endfunction: build_phase

    //---------------------------------------------------------------------------
    // End of Elaboration Phase:
    // - Completes the elaboration phase for the test.
    //---------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);  // Complete the elaboration phase
    endfunction: end_of_elaboration_phase

    //---------------------------------------------------------------------------
    // Run Phase:
    // - Starts the write sequence and raises/drops objections during the phase.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);            // Raise objection to keep simulation running
        read_seq.start(env.master.my_agent.read_seqr); // Start write sequence
        phase.drop_objection(this);             // Drop objection after the sequence starts
    endtask: run_phase
endclass: axi_single_read_wrap_test

// ==========================================================================================
//                              AXI MULTIPLE READ WRAP TEST CLASS
// ==========================================================================================
class axi_multiple_read_wrap_test extends axi_base_test;
    `uvm_component_utils(axi_multiple_read_wrap_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_multiple_read_wrap_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
        test_cfg = new("test_cfg");           // Create a new test configuration object
        test_cfg.number_of_read_cases = 30;  // Set number of write cases
        test_cfg.ARESET_n = 1;     // Set reset signal to active (low)
        test_cfg.burst_type = 2;
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for AXI write operation.
    // - Instantiates write sequence for the test.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  // Invoke base class build phase
        
    endfunction: build_phase

    //---------------------------------------------------------------------------
    // End of Elaboration Phase:
    // - Completes the elaboration phase for the test.
    //---------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);  // Complete the elaboration phase
    endfunction: end_of_elaboration_phase

    //---------------------------------------------------------------------------
    // Run Phase:
    // - Starts the write sequence and raises/drops objections during the phase.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);            // Raise objection to keep simulation running
        read_seq.start(env.master.my_agent.read_seqr); // Start write sequence
        phase.drop_objection(this);             // Drop objection after the sequence starts
    endtask: run_phase
endclass: axi_multiple_read_wrap_test



// ==========================================================================================
//                              AXI SINGLE WRITE INCR TEST CLASS
// ==========================================================================================
class axi_single_write_incr_test extends axi_base_test;
    `uvm_component_utils(axi_single_write_incr_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_single_write_incr_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
        test_cfg = new("test_cfg");           // Create a new test configuration object
        test_cfg.number_of_write_cases = 1;  // Set number of write cases
        test_cfg.ARESET_n = 1;     // Set reset signal to active (low)
        test_cfg.burst_type = 1;
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for AXI write operation.
    // - Instantiates write sequence for the test.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  // Invoke base class build phase
        
    endfunction: build_phase

    //---------------------------------------------------------------------------
    // End of Elaboration Phase:
    // - Completes the elaboration phase for the test.
    //---------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);  // Complete the elaboration phase
    endfunction: end_of_elaboration_phase

    //---------------------------------------------------------------------------
    // Run Phase:
    // - Starts the write sequence and raises/drops objections during the phase.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);            // Raise objection to keep simulation running
        write_seq.start(env.master.my_agent.write_seqr); // Start write sequence
        phase.drop_objection(this);             // Drop objection after the sequence starts
    endtask: run_phase
endclass: axi_single_write_incr_test

// ==========================================================================================
//                              AXI MULTIPLE WRITE INCR TEST CLASS
// ==========================================================================================
class axi_multiple_write_incr_test extends axi_base_test;
    `uvm_component_utils(axi_multiple_write_incr_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_multiple_write_incr_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
        test_cfg = new("test_cfg");           // Create a new test configuration object
        test_cfg.number_of_write_cases = 30;  // Set number of write cases
        test_cfg.ARESET_n = 1;     // Set reset signal to active (low)
        test_cfg.burst_type = 1;
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for AXI write operation.
    // - Instantiates write sequence for the test.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  // Invoke base class build phase
        
    endfunction: build_phase

    //---------------------------------------------------------------------------
    // End of Elaboration Phase:
    // - Completes the elaboration phase for the test.
    //---------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);  // Complete the elaboration phase
    endfunction: end_of_elaboration_phase

    //---------------------------------------------------------------------------
    // Run Phase:
    // - Starts the write sequence and raises/drops objections during the phase.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);            // Raise objection to keep simulation running
        write_seq.start(env.master.my_agent.write_seqr); // Start write sequence
        phase.drop_objection(this);             // Drop objection after the sequence starts
    endtask: run_phase
endclass: axi_multiple_write_incr_test

// ==========================================================================================
//                              AXI SINGLE READ INCR TEST CLASS
// ==========================================================================================
class axi_single_read_incr_test extends axi_base_test;
    `uvm_component_utils(axi_single_read_incr_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_single_read_incr_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
        test_cfg = new("test_cfg");           // Create a new test configuration object
        test_cfg.number_of_read_cases = 1;  // Set number of write cases
        test_cfg.ARESET_n = 1;     // Set reset signal to active (low)
        test_cfg.burst_type = 1;
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for AXI write operation.
    // - Instantiates write sequence for the test.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  // Invoke base class build phase
        
    endfunction: build_phase

    //---------------------------------------------------------------------------
    // End of Elaboration Phase:
    // - Completes the elaboration phase for the test.
    //---------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);  // Complete the elaboration phase
    endfunction: end_of_elaboration_phase

    //---------------------------------------------------------------------------
    // Run Phase:
    // - Starts the write sequence and raises/drops objections during the phase.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);            // Raise objection to keep simulation running
        read_seq.start(env.master.my_agent.read_seqr); // Start write sequence
        phase.drop_objection(this);             // Drop objection after the sequence starts
    endtask: run_phase
endclass: axi_single_read_incr_test

// ==========================================================================================
//                              AXI MULTIPLE READ INCR TEST CLASS
// ==========================================================================================
class axi_multiple_read_incr_test extends axi_base_test;
    `uvm_component_utils(axi_multiple_read_incr_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_multiple_read_incr_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
        test_cfg = new("test_cfg");           // Create a new test configuration object
        test_cfg.number_of_read_cases = 30;  // Set number of write cases
        test_cfg.ARESET_n = 1;     // Set reset signal to active (low)
        test_cfg.burst_type = 1;
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for AXI write operation.
    // - Instantiates write sequence for the test.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  // Invoke base class build phase
        
    endfunction: build_phase

    //---------------------------------------------------------------------------
    // End of Elaboration Phase:
    // - Completes the elaboration phase for the test.
    //---------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);  // Complete the elaboration phase
    endfunction: end_of_elaboration_phase

    //---------------------------------------------------------------------------
    // Run Phase:
    // - Starts the write sequence and raises/drops objections during the phase.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);            // Raise objection to keep simulation running
        read_seq.start(env.master.my_agent.read_seqr); // Start write sequence
        phase.drop_objection(this);             // Drop objection after the sequence starts
    endtask: run_phase
endclass: axi_multiple_read_incr_test

