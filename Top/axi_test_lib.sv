
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
        test_cfg = new("test_cfg");           // Create a new test configuration object
        test_cfg.number_of_write_cases = 30;  // Set number of write cases
        test_cfg.number_of_read_cases = 30;   // Set number of read cases
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings and instantiates sequences.
    // - Registers test configuration in the UVM database.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        test_cfg.burst_type = -1;                       // Set burst type to undefined
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

    //---------------------------------------------------------------------------
    // Run Phase:
    // - Executes the write and read sequences concurrently.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);                  // Raise objection to keep simulation running
        fork
            write_seq.start(env.master.my_agent.write_seqr);  // Start write sequence
            begin
                #300;                                   // Wait for 300 time units
                read_seq.start(env.master.my_agent.read_seqr); // Start read sequence
            end
        join
        phase.drop_objection(this);                   // Drop objection after sequences complete
        $finish;
    endtask: run_phase

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
//                              AXI WRITE TEST CLASS
// ==========================================================================================
class axi_write_test extends axi_base_test;
    `uvm_component_utils(axi_write_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_write_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for AXI write operation.
    // - Instantiates write sequence for the test.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  // Invoke base class build phase
        test_cfg.ARESET_n = 1;     // Set reset signal to active (low)
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
endclass: axi_write_test

// ==========================================================================================
//                              AXI READ TEST CLASS
// ==========================================================================================
class axi_read_test extends axi_base_test;
    `uvm_component_utils(axi_read_test)

    //---------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_read_test class.
    //---------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);  // Call base class constructor
    endfunction: new

    //---------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for AXI read operation.
    // - Instantiates write and read sequences for the test.
    // - Sets the test configuration in the UVM database.
    //---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  // Invoke base class build phase
        uvm_config_db#(test_config)::set(null, "*", "test_cfg", test_cfg); // Set global test configuration
        test_cfg.ARESET_n = 1;     // Set reset signal to active (low)
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
    // - Starts both write and read sequences and raises/drops objections during the phase.
    //---------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);              // Raise objection to keep simulation running
        write_seq.start(env.master.my_agent.write_seqr); // Start write sequence
        read_seq.start(env.master.my_agent.read_seqr);  // Start read sequence
        phase.drop_objection(this);               // Drop objection after both sequences start
    endtask: run_phase
endclass: axi_read_test



// ==========================================================================================
//                              AXI FIXED BURST TEST CLASS
// ==========================================================================================
class axi_fixed_test extends axi_base_test;
    `uvm_component_utils(axi_fixed_test)

    //--------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_fixed_test class.
    //--------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    //--------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for fixed burst type.
    // - Instantiates write and read sequences.
    // - Creates the testbench environment.
    //--------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        test_cfg.burst_type = 0;                  // Fixed burst type
        test_cfg.ARESET_n = 1;                   // Active low reset signal
        uvm_config_db#(test_config)::set(null, "*", "test_cfg", test_cfg); // Set test configuration
        write_seq = new("write_seq");            // Instantiate write sequence
        read_seq = new("read_seq");              // Instantiate read sequence
        env = AXI_tb::type_id::create("env", this); // Create testbench environment
    endfunction: build_phase

    //--------------------------------------------------------------------------
    // Run Phase:
    // - Executes the run phase for axi_fixed_test.
    //--------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase
endclass: axi_fixed_test

// ==========================================================================================
//                              AXI INCREMENTAL BURST TEST CLASS
// ==========================================================================================
class axi_incr_test extends axi_base_test;
    `uvm_component_utils(axi_incr_test)

    //--------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_incr_test class.
    //--------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    //--------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for incremental burst type.
    // - Instantiates write and read sequences.
    // - Sets the test configuration in the UVM database.
    //--------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        test_cfg.burst_type = 1;                  // Incremental burst type
        uvm_config_db#(test_config)::set(null, "*", "test_cfg", test_cfg); // Set test configuration
        test_cfg.ARESET_n = 1;                   // Active low reset signal

        write_seq = new("write_seq");            // Instantiate write sequence
        read_seq = new("read_seq");              // Instantiate read sequence
        env = AXI_tb::type_id::create("env", this); // Create testbench environment
    endfunction: build_phase

    //--------------------------------------------------------------------------
    // Run Phase:
    // - Executes the run phase for axi_incr_test.
    //--------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase
endclass: axi_incr_test

// ==========================================================================================
//                              AXI WRAPPING BURST TEST CLASS
// ==========================================================================================
class axi_wrap_test extends axi_base_test;
    `uvm_component_utils(axi_wrap_test)

    //--------------------------------------------------------------------------
    // Constructor:
    // - Creates an instance of axi_wrap_test class.
    //--------------------------------------------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    //--------------------------------------------------------------------------
    // Build Phase:
    // - Configures test settings for wrapping burst type.
    // - Instantiates write and read sequences.
    // - Sets the test configuration in the UVM database.
    //--------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        test_cfg.burst_type = 2;                  // Wrapping burst type
        uvm_config_db#(test_config)::set(null, "*", "test_cfg", test_cfg); // Set test configuration
        test_cfg.ARESET_n = 1;                   // Active low reset signal

        write_seq = new("write_seq");            // Instantiate write sequence
        read_seq = new("read_seq");              // Instantiate read sequence
        env = AXI_tb::type_id::create("env", this); // Create testbench environment
    endfunction: build_phase

    //--------------------------------------------------------------------------
    // Run Phase:
    // - Executes the run phase for axi_wrap_test.
    //--------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase
endclass: axi_wrap_test

