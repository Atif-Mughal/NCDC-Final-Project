package axi_slave_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
//`include "../Master-UVC/axi_master_seq_item.sv"
import axi_master_pkg::*;
`include "axi_slave_monitor.sv"
`include "axi_slave_driver.sv"
`include "axi_slave_agent.sv"
`include "axi_slave_env.sv"
endpackage : axi_slave_pkg
