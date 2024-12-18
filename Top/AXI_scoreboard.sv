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
        
        virtual axi4_if vif;
      
        // *******************************************************************
        // **                     COVERAGE GROUPS                          **
        // *******************************************************************
        covergroup coverage;    	  
    	  
    	  //Reset
        ARESET_n: coverpoint vif.ARESET_n;
        
        //Read Address Channel
        ARADDR: coverpoint vif.ARADDR {
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 2)) : (1 << (ADDR_WIDTH - 1)) - 1]};             
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
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 2)) : (1 << (DATA_WIDTH - 1)) - 1]};              
        }
        RREADY: coverpoint vif.RREADY;
        RVALID: coverpoint vif.RVALID;
        RLAST: coverpoint vif.RLAST;
        RRESP: coverpoint vif.RRESP;
        
        //Write Address Channel
        AWADDR: coverpoint vif.AWADDR {
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 2)) : (1 << (ADDR_WIDTH - 1)) - 1]}; 
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
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 2)) : (1 << (DATA_WIDTH - 1)) - 1]};              
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
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 2)) : (1 << (ADDR_WIDTH - 1)) - 1]}; 
        }
		  
		  DATA:  coverpoint vif.WDATA {
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 2)) : (1 << (DATA_WIDTH - 1)) - 1]};              
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
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 2)) : (1 << (ADDR_WIDTH - 1)) - 1]}; 
        }
		  
		  DATA:  coverpoint vif.WDATA {
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 2)) : (1 << (DATA_WIDTH - 1)) - 1]};             
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
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 2)) : (1 << (ADDR_WIDTH - 1)) - 1]}; 
        }
		  
		  DATA:  coverpoint vif.WDATA {
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 2)) : (1 << (DATA_WIDTH - 1)) - 1]};             
        }
        
        BURST_TYPE: coverpoint master_in.BURST_TYPE{
        		 bins b1[] =  {2};
        }
        BURST_SIZE: coverpoint master_in.BURST_SIZE{
        		bins b1[] =  {[0 : 2]};
        }
        BURST_LENGTH: coverpoint master_in.BURST_LENGTH{
        		bins b1[] =  {1, 3, 7, 15};
        }        
    endgroup
	 //////////////////////////////////////////////////////////////////
    covergroup fixed_read;
           
        ADDR: coverpoint master_in.ADDR {
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 2)) : (1 << (ADDR_WIDTH - 1)) - 1]};  
        }
		  
		  DATA:  coverpoint vif.RDATA {
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 2)) : (1 << (DATA_WIDTH - 1)) - 1]};             
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
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 2)) : (1 << (ADDR_WIDTH - 1)) - 1]}; 
        }
		  
		  DATA:  coverpoint vif.RDATA {
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 2)) : (1 << (DATA_WIDTH - 1)) - 1]};             
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
				bins lower_bins = {[0 : ((1 << (ADDR_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (ADDR_WIDTH - 2)) : (1 << (ADDR_WIDTH - 1)) - 1]};  
        }
		  
		  DATA:  coverpoint vif.RDATA {
				bins lower_bins = {[0 : ((1 << (DATA_WIDTH - 2)) - 1)]};
				bins upper_bins = {[(1 << (DATA_WIDTH - 2)) : (1 << (DATA_WIDTH - 1)) - 1]};           
        }
        
        BURST_TYPE: coverpoint master_in.BURST_TYPE{
        		 bins b1[] =  {2};
        }
        BURST_SIZE: coverpoint master_in.BURST_SIZE{
        		bins b1[] =  {[0 : 2]};
        }
        BURST_LENGTH: coverpoint master_in.BURST_LENGTH{
        		bins b1[] =  {1, 3, 7, 15};
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
              
              master_in = new("master_in"); 
              master_transaction = new("master_transaction");
         	  slave_in = new("slave_in"); 
         	  slave_transaction = new("slave_transaction"); 
              
              if(!uvm_config_db#(virtual axi4_if)::get(this, "*", "vif", vif))
              	  `uvm_error(get_name(), "AXI Interface is not available. Check your configuration.")

              wrap_write = new();

        endfunction : new

        //============================================================
        // Task: run_phase
        // Description: 
        //  - Executes the UVM run phase, continuously fetching transactions 
        //    from Master and Slave FIFOs using parallel processes (fork-join).
        //  - Compares Master and Slave transactions when both IDs are received.
        //============================================================
        task run_phase(uvm_phase phase);
            super.run_phase(phase); // Call the base class `run_phase`

            // Fork to execute two parallel forever loops
            fork
                //========================================
                //       MASTER TRANSACTION HANDLER
                //========================================
                forever begin
                    // Fetch the next Master transaction from the FIFO
                    master_in_fifo.get_peek_export.get(master_in);

                    // Log the fetched Master transaction for debugging
                    `uvm_info(get_type_name(), $sformatf("Packet is \n %s", master_in.sprint()), UVM_LOW)

                    // Update the received flag based on the MSB of the Master transaction ID
                    if (master_in.ID[7] == 0)
                        m_received[0] = 1'b1; // Set bit 0 if ID[7] == 0
                    if (master_in.ID[7] == 1)
                        m_received[1] = 1'b1; // Set bit 1 if ID[7] == 1

                    // Store the current Master transaction for comparison
                    master_transaction = master_in;

                    // Check if both ID[7] values (0 and 1) have been received
                    if (m_received === 2'b11)
                        check(); // Call check function for transaction comparison

                    // Optional: Uncomment to sample master coverage
                    wrap_write.sample();
                end

                //========================================
                //        SLAVE TRANSACTION HANDLER
                //========================================
                forever begin
                    // Fetch the next Slave transaction from the FIFO
                    slave_in_fifo.get_peek_export.get(slave_in);

                    // Log the fetched Slave transaction for debugging
                    `uvm_info(get_type_name(), $sformatf("Packet is \n %s", slave_in.sprint()), UVM_LOW)

                    // Update the received flag based on the MSB of the Slave transaction ID
                    if (slave_in.ID[7] == 0)
                        s_received[0] = 1'b1; // Set bit 0 if ID[7] == 0
                    if (slave_in.ID[7] == 1)
                        s_received[1] = 1'b1; // Set bit 1 if ID[7] == 1

                    // Store the current Slave transaction for comparison
                    slave_transaction = slave_in;

                    // Check if both ID[7] values (0 and 1) have been received
                    if (s_received === 2'b11)
                        check(); // Call check function for transaction comparison

                    // Optional: Uncomment to sample slave coverage
                    wrap_write.sample();
                end
            join // End of fork-join for parallel execution
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
