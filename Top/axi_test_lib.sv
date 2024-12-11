import config_pkg::*;
class axi_base_test extends uvm_test;
    `uvm_component_utils(axi_base_test)
    
    // Components
    //axi_master_sequencer seqr;
    AXI_tb env;
    axi_write_sequence  write_seq;
    axi_read_sequence  read_seq;

    test_config test_cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        test_cfg = new("test_cfg");
        test_cfg.number_of_write_cases = 30;
        test_cfg.number_of_read_cases = 30;
    endfunction //new()

    //  Function: build_phase
    function void build_phase(uvm_phase phase);
        test_cfg.burst_type = -1;
        uvm_config_db#(test_config)::set(null, "*", "test_cfg", test_cfg);
        
        write_seq = new("write_seq");
        read_seq = new("read_seq");
        env = AXI_tb::type_id::create("env", this);
    endfunction: build_phase
    
    //  Function: end_of_elaboration_phase
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction: end_of_elaboration_phase
    
    //  Function: run_phase
    task run_phase(uvm_phase phase);
    phase.raise_objection(this);
        fork
            write_seq.start(env.master.my_agent.sequencer);
            begin
                #300;
                read_seq.start(env.master.my_agent.sequencer);
            end
        join
        phase.drop_objection(this);
    endtask: run_phase
    
endclass //axi_base_test extends uvm_test


// ****************************************************************************************
//                                  Reset Test Cases
// ****************************************************************************************
class axi_reset_test extends axi_base_test;
    `uvm_component_utils(axi_reset_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);  
        test_cfg.ARESET_n = 0;
    endfunction: build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
    endfunction: end_of_elaboration_phase
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        write_seq.start(env.master.my_agent.sequencer);
        phase.drop_objection(this);
    endtask: run_phase
endclass //write_test extends axi_base_test


// ****************************************************************************************
//                                  Directed Test Cases
// ****************************************************************************************
class axi_write_test extends axi_base_test;
    `uvm_component_utils(axi_write_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase); 
        test_cfg.ARESET_n = 1; 
    endfunction: build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
    endfunction: end_of_elaboration_phase
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        write_seq.start(env.master.my_agent.sequencer);
        phase.drop_objection(this);
    endtask: run_phase
endclass //write_test extends axi_base_test

class axi_read_test extends axi_base_test;
    `uvm_component_utils(axi_read_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase); 
        uvm_config_db#(test_config)::set(null, "*", "test_cfg", test_cfg); 
        test_cfg.ARESET_n = 1; 
    endfunction: build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
    endfunction: end_of_elaboration_phase
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        write_seq.start(env.master.my_agent.sequencer);
        read_seq.start(env.master.my_agent.sequencer);
        phase.drop_objection(this);
    endtask: run_phase
endclass //write_test extends axi_base_test

class axi_fixed_test extends axi_base_test;
    `uvm_component_utils(axi_fixed_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        test_cfg.burst_type = 0;
        uvm_config_db#(test_config)::set(null, "*", "test_cfg", test_cfg);
        test_cfg.ARESET_n = 1; 
        
        write_seq = new("write_seq");
        read_seq = new("read_seq");
        env = AXI_tb::type_id::create("env", this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase
endclass //axi_fixed_test extends axi_base_test

class axi_incr_test extends axi_base_test;
    `uvm_component_utils(axi_incr_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        test_cfg.burst_type = 1;
        uvm_config_db#(test_config)::set(null, "*", "test_cfg", test_cfg);
        test_cfg.ARESET_n = 1; 
        
        write_seq = new("write_seq");
        read_seq = new("read_seq");
        env = AXI_tb::type_id::create("env", this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase
endclass //axi_fixed_test extends axi_base_test

class axi_wrap_test extends axi_base_test;
    `uvm_component_utils(axi_wrap_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        test_cfg.burst_type = 2;
        uvm_config_db#(test_config)::set(null, "*", "test_cfg", test_cfg);
        test_cfg.ARESET_n = 1; 
        
        write_seq = new("write_seq");
        read_seq = new("read_seq");
        env = AXI_tb::type_id::create("env", this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase
endclass //axi_fixed_test extends axi_base_test
