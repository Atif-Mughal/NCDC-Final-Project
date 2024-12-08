//------------------------------------------------------------------------------
//
// CLASS: axi_slave_env
//
//------------------------------------------------------------------------------

class axi_slave_env extends uvm_env;

  // Components of the environment
  axi_slave_agent my_agent;
  `uvm_component_utils(axi_slave_env)
   
  // Constructor - required syntax for UVM automation and utilities
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  // extern virtual function void connect_phase(uvm_phase phase);

endclass : axi_slave_env

  // UVM build_phase
  function void axi_slave_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"Building axi_slave ENV",UVM_HIGH)
     my_agent = axi_slave_agent::type_id::create("my_agent",this);
  endfunction : build_phase