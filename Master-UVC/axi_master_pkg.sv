package axi_master_pkg;
 import uvm_pkg::*;
 `include "uvm_macros.svh"
 import axi_parameters::*;

  `include "axi_master_seq_item.sv"
  `include "axi_master_sequence.sv"
  `include "axi_master_monitor.sv"
  `include "axi_master_driver.sv"
  `include "axi_master_agent.sv"
  
  `include "axi_master_env.sv"

endpackage : axi_master_pkg
