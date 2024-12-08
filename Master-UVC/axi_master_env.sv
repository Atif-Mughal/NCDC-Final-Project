//------------------------------------------------------------------------------
//
// CLASS: axi_master_env
//
//------------------------------------------------------------------------------

class axi_master_env extends uvm_env;

  // Components of the environment
  axi_master_agent my_agent;
  `uvm_component_utils(axi_master_env)
   
  // Constructor - required syntax for UVM automation and utilities
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  // extern virtual function void connect_phase(uvm_phase phase);

endclass : axi_master_env

  // UVM build_phase
  function void axi_master_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(),"Building axi_master ENV",UVM_HIGH)
     my_agent = axi_master_agent::type_id::create("my_agent",this);
  endfunction : build_phase