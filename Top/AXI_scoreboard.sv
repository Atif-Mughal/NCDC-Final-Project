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
	        // *******************************************************************
        // **                     COVERAGE GROUPS                          **
        // *******************************************************************
        covergroup coverage;    	  
    	  
    	  //Reset
        ARESET_n: coverpoint vif.ARESET_n;
        
        //Read Address Channel
        ARADDR: coverpoint vif.ARADDR {
				bins b1[] = {[0: ADDR_WIDTH >> 2]};
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 1)) : (1 << (ADDR_WIDTH)) - 1]};            
				bins b2 = {((1 << ADDR_WIDTH) - 1)};
        }
        ARREADY: coverpoint vif.ARREADY;
        ARVALID: coverpoint vif.ARVALID;
        ARLEN: coverpoint vif.ARLEN;
        ARBURST: coverpoint vif.ARBURST{
				 bins b1[] =  {[0 : 2]};
				 illegal_bins b2 = {3};
        }
        ARSIZE: coverpoint vif.ARSIZE{
        		bins b1[] =  {[0 : 7]};
        }
        ARBURSTxARLEN:  cross ARBURST, ARLEN{
						bins b1 = binsof(ARBURST) intersect {0} && binsof(ARLEN) intersect {[0:7]};
						bins b2 = binsof(ARBURST) intersect {0} && binsof(ARLEN) intersect {[8:15]};
						bins b3 = binsof(ARBURST) intersect {1} && binsof(ARLEN) intersect {[0:127]};        		
						bins b4 = binsof(ARBURST) intersect {1} && binsof(ARLEN) intersect {[128:255]};
						bins b5 = binsof(ARBURST) intersect {2} && binsof(ARLEN) intersect {1, 3, 7, 15};
						illegal_bins b6 = binsof(ARBURST) intersect {2} && !binsof(ARLEN) intersect {1, 3, 7, 15};     		
        }
        
        //Read Data Channel
        RDATA:  coverpoint vif.RDATA {
				bins b1 = {0};
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 1)) : (1 << (DATA_WIDTH)) - 1]};
				bins b2 = {((1 << DATA_WIDTH) - 1)};            
        }
        RREADY: coverpoint vif.RREADY;
        RVALID: coverpoint vif.RVALID;
        RLAST: coverpoint vif.RLAST;
        RRESP: coverpoint vif.RRESP;
        
        //Write Address Channel
        AWADDR: coverpoint vif.AWADDR {
				bins b1[] = {[0: ADDR_WIDTH >> 2]};
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 1)) : (1 << (ADDR_WIDTH)) - 1]};            
				bins b2 = {((1 << ADDR_WIDTH) - 1)};
        }
        AWREADY: coverpoint vif.AWREADY;
        AWVALID: coverpoint vif.AWVALID;
        AWLEN: coverpoint vif.AWLEN;
        AWBURST: coverpoint vif.AWBURST{
        		 bins b1[] =  {[0 : 2]};
        		 illegal_bins b2 = {3};
        }
        AWSIZE: coverpoint vif.AWSIZE{
        		bins b1[] =  {[0 : 7]};
        }
        
        AWBURSTxAWLEN:  cross AWBURST, AWLEN{
						bins b1 = binsof(AWBURST) intersect {0} && binsof(AWLEN) intersect {[0:7]};
						bins b2 = binsof(AWBURST) intersect {0} && binsof(AWLEN) intersect {[8:15]};
						bins b3 = binsof(AWBURST) intersect {1} && binsof(AWLEN) intersect {[0:127]};        		
						bins b4 = binsof(AWBURST) intersect {1} && binsof(AWLEN) intersect {[128:255]};
						bins b5 = binsof(AWBURST) intersect {2} && binsof(AWLEN) intersect {1, 3, 7, 15};
						illegal_bins b6 = binsof(AWBURST) intersect {2} && !binsof(AWLEN) intersect {1, 3, 7, 15}; 
        }
        
        //Write Data Channel
        WDATA:  coverpoint vif.WDATA {
				bins b1 = {0};
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 1)) : (1 << (DATA_WIDTH)) - 1]};
				bins b2 = {((1 << DATA_WIDTH) - 1)};             
        }
        WSTRB:  coverpoint vif.WSTRB{
        		bins b1[] =  {0, 1, 2, 4, 8};
        		illegal_bins b2 = default;
        }

        WLAST: coverpoint vif.WLAST;
        WREADY: coverpoint vif.WREADY;
        WVALID: coverpoint vif.WVALID;
        
        //Write Response Channel
        BRESP: coverpoint vif.BRESP;
        BREADY: coverpoint vif.BREADY;
        BVALID: coverpoint vif.BVALID;                 
               
    endgroup
    //////////////////////////////////////////////////////////////////
    covergroup fixed_write;
           
        ADDR: coverpoint master_in.ADDR {
				bins b1 = {0};
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 1)) : (1 << (ADDR_WIDTH)) - 1]};            
				bins b2 = {((1 << ADDR_WIDTH) - 1)};
        }
		  
		  DATA:  coverpoint vif.WDATA {
				bins b1 = {0};
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 1)) : (1 << (DATA_WIDTH)) - 1]};
				bins b2 = {((1 << DATA_WIDTH) - 1)};            
        }
        
        BURST_TYPE: coverpoint master_in.BURST_TYPE{
        		 bins b1[] =  {0};
        }
        BURST_SIZE: coverpoint master_in.BURST_SIZE{
        		bins b1[] =  {[0 : 2]};
        }
        BURST_LENGTH: coverpoint master_in.BURST_LENGTH{
        		bins b1[] =  {[0 : 15]};
        }        
    endgroup  
    //////////////////////////////////////////////////////////////////
    covergroup incr_write;
           
        ADDR: coverpoint master_in.ADDR {
				bins b1 = {0};
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 1)) : (1 << (ADDR_WIDTH)) - 1]};            
				bins b2 = {((1 << ADDR_WIDTH) - 1)};
        }
		  
		  DATA:  coverpoint vif.WDATA {
				bins b1 = {0};
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 1)) : (1 << (DATA_WIDTH)) - 1]};
				bins b2 = {((1 << DATA_WIDTH) - 1)};            
        }
        
        BURST_TYPE: coverpoint master_in.BURST_TYPE{
        		 bins b1[] =  {1};
        }
        BURST_SIZE: coverpoint master_in.BURST_SIZE{
        		bins b1[] =  {[0 : 2]};
        }
        BURST_LENGTH: coverpoint master_in.BURST_LENGTH{
        		bins b1[] =  {[0 : 15]};
        }        
    endgroup
    //////////////////////////////////////////////////////////////////
    covergroup wrap_write;
           
        ADDR: coverpoint master_in.ADDR {
				bins b1 = {0};
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 1)) : (1 << (ADDR_WIDTH)) - 1]};            
				bins b2 = {((1 << ADDR_WIDTH) - 1)};
        }
		  
		  DATA:  coverpoint vif.WDATA {
				bins b1 = {0};
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 1)) : (1 << (DATA_WIDTH)) - 1]};
				bins b2 = {((1 << DATA_WIDTH) - 1)};            
        }
        
        BURST_TYPE: coverpoint master_in.BURST_TYPE{
        		 bins b1[] =  {2};
        }
        BURST_SIZE: coverpoint master_in.BURST_SIZE{
        		bins b1[] =  {[0 : 2]};
        }
        BURST_LENGTH: coverpoint master_in.BURST_LENGTH{
        		bins b1[] =  {[0 : 15]};
        }        
    endgroup
	 //////////////////////////////////////////////////////////////////
    covergroup fixed_read;
           
        ADDR: coverpoint master_in.ADDR {
				bins b1 = {0};
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 1)) : (1 << (ADDR_WIDTH)) - 1]};            
				bins b2 = {((1 << ADDR_WIDTH) - 1)};
        }
		  
		  DATA:  coverpoint vif.RDATA {
				bins b1 = {0};
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 1)) : (1 << (DATA_WIDTH)) - 1]};
				bins b2 = {((1 << DATA_WIDTH) - 1)};            
        }
        
        BURST_TYPE: coverpoint master_in.BURST_TYPE{
        		 bins b1[] =  {0};
        }
        BURST_SIZE: coverpoint master_in.BURST_SIZE{
        		bins b1[] =  {[0 : 2]};
        }
        BURST_LENGTH: coverpoint master_in.BURST_LENGTH{
        		bins b1[] =  {[0 : 15]};
        }        
    endgroup  
    //////////////////////////////////////////////////////////////////
    covergroup incr_read;
           
        ADDR: coverpoint master_in.ADDR {
				bins b1 = {0};
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 1)) : (1 << (ADDR_WIDTH)) - 1]};            
				bins b2 = {((1 << ADDR_WIDTH) - 1)};
        }
		  
		  DATA:  coverpoint vif.RDATA {
				bins b1 = {0};
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 1)) : (1 << (DATA_WIDTH)) - 1]};
				bins b2 = {((1 << DATA_WIDTH) - 1)};            
        }
        
        BURST_TYPE: coverpoint master_in.BURST_TYPE{
        		 bins b1[] =  {1};
        }
        BURST_SIZE: coverpoint master_in.BURST_SIZE{
        		bins b1[] =  {[0 : 2]};
        }
        BURST_LENGTH: coverpoint master_in.BURST_LENGTH{
        		bins b1[] =  {[0 : 15]};
        }        
    endgroup
    //////////////////////////////////////////////////////////////////
    covergroup wrap_read;
           
        ADDR: coverpoint master_in.ADDR {
				bins b1 = {0};
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 1)) : (1 << (ADDR_WIDTH)) - 1]};            
				bins b2 = {((1 << ADDR_WIDTH) - 1)};
        }
		  
		  DATA:  coverpoint vif.RDATA {
				bins b1 = {0};
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 1)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 1)) : (1 << (DATA_WIDTH)) - 1]};
				bins b2 = {((1 << DATA_WIDTH) - 1)};            
        }
        
        BURST_TYPE: coverpoint master_in.BURST_TYPE{
        		 bins b1[] =  {2};
        }
        BURST_SIZE: coverpoint master_in.BURST_SIZE{
        		bins b1[] =  {[0 : 2]};
        }
        BURST_LENGTH: coverpoint master_in.BURST_LENGTH{
        		bins b1[] =  {[0 : 15]};
        }        
    endgroup

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
	    coverage = new();
	    fixed_write = new();
	    wrap_write = new();
	    incr_write = new();
	    fixed_read = new();
	    wrap_read = new();
	    incr_read = new();

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
			coverage.sample();
                  fixed_write.sample();
			fixed_read.sample();
			incr_write.sample();
			incr_read.sample();
			wrap_write.sample();
			wrap_read.sample();

                
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
			coverage.sample();
			fixed_write.sample();
			fixed_read.sample();
			incr_write.sample();
			incr_read.sample();
			wrap_write.sample();
			wrap_read.sample();

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
