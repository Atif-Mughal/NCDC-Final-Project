import uvm_pkg::*;                // UVM base package
`include "uvm_macros.svh"         // UVM macros for testbench automation
import axi_parameters::*;
// CLASS: AXI_scorboard
// DESCRIPTION:
// - Implements a UVM scoreboard for comparing and verifying the data flow 
//   between the Wishbone interface and the Slave interface in the AXI system.
// - Monitors transactions and validates correctness, tracking errors and 
//   transaction counts for reporting.
//-----------------------------------------------------------------------------
class AXI_scorboard extends uvm_scoreboard;

	  //---------------------------------------------------------------------------
	  // UVM COMPONENT UTILS
	  //---------------------------------------------------------------------------
	  // - Registers the `AXI_scorboard` class with the UVM factory for dynamic instantiation.
	  //---------------------------------------------------------------------------
	  `uvm_component_utils(AXI_scorboard)

	  //---------------------------------------------------------------------------
	  // CLASS PROPERTIES
	  //---------------------------------------------------------------------------
	  uvm_tlm_analysis_fifo #(axi_master_seq_item) master_in_fifo;  // FIFO for Master transactions
	  uvm_tlm_analysis_fifo #(axi_master_seq_item) slave_in_fifo;      // FIFO for Slave interface packets
	  
	  bit [1:0] m_received, s_received;


	  axi_master_seq_item master_in, master_transaction; // Stores Master transaction data
	  axi_master_seq_item slave_in, slave_transaction;     // Stores Slave interface packet data
	/*
	    // *******************************************************************
	    // **                     COVERAGE GROUPS                          **
	    // *******************************************************************
	    covergroup master_coverage;
		c1: coverpoint master_in.ADDR {
		    bins b1[] = {[0: ADDR_WIDTH>>2]};
		    bins b2 = {((1<<ADDR_WIDTH) - 1)};
		}
		c3: coverpoint master_in.BURST_SIZE; 
		c4: coverpoint master_in.BURST_LENGTH; 
	    endgroup

	    covergroup slave_coverage;
		c1: coverpoint slave_in.ADDR {
		    bins b1[] = {[0: ADDR_WIDTH>>2]};
		    bins b2 = {((1<<ADDR_WIDTH) - 1)};
		}
		c3: coverpoint slave_in.BURST_SIZE; 
		c4: coverpoint slave_in.BURST_LENGTH; 
	    endgroup
	    */

	  //---------------------------------------------------------------------------
	  // CONSTRUCTOR
	  //---------------------------------------------------------------------------
	  // - Creates an instance of the `SPI_scorboard` class and initializes properties.
	  // - Initializes the analysis FIFOs for incoming Wishbone and Slave transactions.
	  //---------------------------------------------------------------------------
	  function new(string name, uvm_component parent);
	    super.new(name, parent);                          // Call the base class constructor

	    // Create FIFOs for capturing transactions
	    master_in_fifo = new("master_in_fifo", this); // FIFO for Master interface
	    slave_in_fifo = new("slave_in_fifo", this);     // FIFO for Slave interface

	    //master_coverage = new();
	    //slave_coverage = new();

	  endfunction : new

    	//-----------------------------------------------------------------------------
        // TASK: run_phase
        // DESCRIPTION:
        // - Executes the main functionality of the scoreboard during the `run_phase`.
        //-----------------------------------------------------------------------------
        task run_phase(uvm_phase phase);
        	super.run_phase(phase); // Call the base class `run_phase`

        fork
            forever begin
                  // Fetch the next Master transaction from the FIFO
                  master_in_fifo.get_peek_export.get(master_in);
                  // Log the information about the sequence item for debugging purposes
                  `uvm_info(get_type_name(), $sformatf("Packet is \n %s", master_in.sprint()), UVM_LOW)
                  if (master_in.ID[7] == 0)
                  	m_received[0] = 1'b1;
                  if (master_in.ID[7] == 1)
                  	m_received[1] = 1'b1;
                  master_transaction = master_in;
                  if (m_received === 2'b11)
                  	check();
                 // master_coverage.sample();

                
            end
            forever begin
                  // Fetch the next Slave transaction from the FIFO
                  slave_in_fifo.get_peek_export.get(slave_in);
                  // Log the information about the sequence item for debugging purposes
                   `uvm_info(get_type_name(), $sformatf("Packet is \n %s", slave_in.sprint()), UVM_LOW)
                   
                   if (slave_in.ID[7] == 0)
                  	s_received[0] = 1'b1;
                  if (slave_in.ID[7] == 1)
                  	s_received[1] = 1'b1;
                  slave_transaction = slave_in;
                  if (s_received == 2'b11)
                  	check();
                 // slave_coverage.sample();
            end

      join
    endtask : run_phase
        //============================================================
        // Function: check
        // Description: 
        //  - Compares the latest Master and Slave transactions.
        //  - Logs a Test Passed or Test FAILED message based on comparison.
        //============================================================
        function void check();
            // Compare the Master and Slave transactions
            if (master_transaction.compare(slave_transaction)) begin
                `uvm_info(get_type_name, $sformatf("Test Passed"), UVM_LOW)
            end
            else begin
                `uvm_info(get_type_name, $sformatf("Test FAILED"), UVM_LOW)
            end
        endfunction

endclass
