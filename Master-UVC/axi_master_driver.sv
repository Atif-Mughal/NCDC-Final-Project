// ****************************************************************************
// ** CLASS: axi_master_driver
// ** DESCRIPTION:
// ** - The `axi_master_driver` handles the driving of AXI transactions from
// **   the master side. It sends both write and read transactions, including
// **   address and data, to the AXI interface.
// ** - This driver interacts with the UVM sequence items and controls the 
// **   flow of the transactions based on the AXI protocol for the master.
// ****************************************************************************

import config_pkg::*;
import axi_parameters::*;

class axi_master_driver extends uvm_driver#(axi_master_seq_item);
    `uvm_component_utils(axi_master_driver)  // Register with UVM factory
    
    // ******************* Component Interface *******************
    // Virtual Interface for the AXI Master interface (connected to the DUT)
    virtual axi4_if vif;
    

    // ******************* UVM Ports *******************
    uvm_seq_item_pull_port #(REQ, RSP) seq_item_port2;
    semaphore write_semaphore, read_semaphore;

    // ******************* Variables *******************
    axi_master_seq_item write_transaction, read_transaction;   // Write and Read transaction objects
    bit write_done, read_done;                     // Flags to indicate completion
    bit [DATA_WIDTH-1:0] temp [];             // Temporary buffer for packed data
    logic AWVALID;                          // Control signal for Write Address valid
    test_config test_cfg;

    // ******************* Constructor *******************
    // Initializes driver and sets up the sequence item pull port.
    function new(string name = "axi_master_driver", uvm_component parent);
        super.new(name, parent);
        write_done = 1;   // Initially set write transaction as done
        read_done = 1;   // Initially set read transaction as done
        seq_item_port2 = new("seq_item_port2", this);  // Create the port for sequence items
        write_semaphore = new(1);
        read_semaphore = new(1);
        
    endfunction
    
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
    	if (!uvm_config_db#(test_config)::get(null, "*", "test_cfg", test_cfg)) 
            `uvm_fatal(get_name(), "Test configuration not found in ConfigDB!");
        if (!uvm_config_db#(virtual axi4_if)::get(null,"*env*","vif",vif))
        begin
           `uvm_fatal(get_name(), "Interface is not available");
        end
    endfunction
    
    
    // ****************************************************************************
    // ** run_phase Implementation
    // ****************************************************************************
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Started AXI Master Driver", UVM_HIGH)
        `uvm_info(get_type_name(), "Started AXI Master Driver", UVM_HIGH)
        
        // Drive initial values for read/write control signals
        vif.master_driver_cb.BREADY <= 1;
        vif.master_driver_cb.RREADY <= 1;
       

        // Forever loop to continuously drive transactions
        forever begin
            drive();  // Main driving task
            #1;       // Small delay between transactions
        end
    endtask: run_phase
    // ****************************************************************************
    // ** drive Implementation
    // ****************************************************************************
    task drive();
        fork
            // Handle Write Transaction
            begin
                `uvm_info(get_type_name(), $sformatf("Sending write address: write_done = %0d", write_done), UVM_DEBUG)
                if (write_done) begin
                    write_done = 0;  // Set write transaction flag to false
                    seq_item_port.get_next_item(write_transaction);  // Get next write transaction
                    `uvm_info(get_name(), "Write packet received in master driver", UVM_LOW)
                    write_transaction.print();  // Print transaction details for debugging
                    
                    // Send write address and data
                    fork
                        send_write_address();  // Send the write address
                        send_write_data();     // Send the write data
                    join

                    seq_item_port.item_done();  // Indicate completion of the transaction
                    write_done = 1;  // Set write transaction flag to true
                end
            end
            // Handle Read Transaction
            begin
                `uvm_info(get_type_name(), $sformatf("Sending read address: read_done = %0d", read_done), UVM_DEBUG)
                if (read_done) begin
                    read_done = 0;  // Set read transaction flag to false
                    seq_item_port2.get_next_item(read_transaction);  // Get next read transaction
                    `uvm_info(get_name(), "Read packet received in master driver", UVM_LOW)
                    read_transaction.print();  // Print transaction details for debugging
                    
                    send_read_address();  // Send the read address
                    seq_item_port2.item_done();  // Indicate completion of the transaction
                    read_done = 1;  // Set read transaction flag to true
                end
            end
        join_none
    endtask: drive

    // ****************************************************************************
    // ** send_write_address Implementation
    // ****************************************************************************
    task send_write_address();
        `uvm_info(get_type_name(), "Inside send_write_address()", UVM_HIGH)
        
        // Drive Write Address Channel signals
        @(vif.master_driver_cb);  // Synchronize with the AXI interface
        vif.ARESET_n   <= write_transaction.ARESET_n;
        vif.master_driver_cb.AWID   <= write_transaction.ID;
        vif.master_driver_cb.AWADDR <= write_transaction.ADDR;
        vif.master_driver_cb.AWLEN  <= write_transaction.BURST_LENGTH;
        vif.master_driver_cb.AWSIZE <= write_transaction.BURST_SIZE;
        vif.master_driver_cb.AWBURST<= write_transaction.BURST_TYPE;

        // Assert AWVALID after one clock cycle
        @(vif.master_driver_cb);
        AWVALID = 1;
        vif.master_driver_cb.AWVALID <= AWVALID;
        `uvm_info(get_type_name(), "Asserted AWVALID", UVM_HIGH)

        // Wait for AWREADY and deassert AWVALID
        @(vif.master_driver_cb);
        wait(vif.master_driver_cb.AWREADY);
        AWVALID = 0;
        vif.master_driver_cb.AWVALID <= AWVALID;
        `uvm_info(get_type_name(), "Deasserted AWVALID", UVM_HIGH)

        // Wait for write response (BVALID) to complete the transaction
        wait(vif.master_driver_cb.BVALID);
    endtask: send_write_address

    // ****************************************************************************
    // ** send_write_data Implementation
    // ****************************************************************************
    task send_write_data();
        int len = write_transaction.BURST_LENGTH + 1;
        temp = new[len];  // Create buffer for data transfer
        `uvm_info(get_type_name(), "Inside send_write_data()", UVM_HIGH)
        
        // Pack data for transfer
        foreach (write_transaction.DATA[i, j]) begin
            temp[i][8*j+:8] = write_transaction.DATA[i][j];
        end
        //$display("AWALID = %0d  and  AWREADY = %0d", vif.slave_driver_cb.WVALID);
        // Wait for write address channel to be ready
        wait(AWVALID && vif.master_driver_cb.AWREADY);
        `uvm_info(get_type_name(), "Packed write data", UVM_HIGH)

        // Send data beats one by one
        for (int i = 0; i < len; i++) begin
            `uvm_info(get_type_name(), $sformatf("Sending data beat %0d", i), UVM_HIGH)
            //@(vif.master_driver_cb);
            vif.master_driver_cb.WID    <= write_transaction.ID;
            vif.master_driver_cb.WDATA  <= temp[i];
            vif.master_driver_cb.WLAST  <= (i == len - 1) ? 1 : 0;

            // Assert WVALID
            @(vif.master_driver_cb);
            vif.master_driver_cb.WVALID <= 1;

            // Wait for WREADY and deassert WVALID
            #1;
            wait(vif.master_driver_cb.WREADY);
            vif.master_driver_cb.WVALID <= 0;
            vif.master_driver_cb.WLAST  <= 0;
        end

        // Wait for write response (BVALID) to complete the transaction
        wait(vif.master_driver_cb.BVALID);
    endtask: send_write_data

    // ****************************************************************************
    // ** send_read_address Implementation
    // ****************************************************************************
    task send_read_address();
    	vif.master_driver_cb.ARVALID <= 0;
        // Send the read address signals to AXI interface
        @(vif.master_driver_cb);
        vif.ARESET_n   <= read_transaction.ARESET_n;
        vif.master_driver_cb.ARID       <= read_transaction.ID;
        vif.master_driver_cb.ARADDR     <= read_transaction.ADDR;
        vif.master_driver_cb.ARLEN      <= read_transaction.BURST_LENGTH;
        vif.master_driver_cb.ARSIZE     <= read_transaction.BURST_SIZE;
        vif.master_driver_cb.ARBURST    <= read_transaction.BURST_TYPE;

        // Assert ARVALID after one clock cycle
        @(vif.master_driver_cb);
        vif.master_driver_cb.ARVALID <= 1;

        // Wait for ARREADY and deassert ARVALID
        @(vif.master_driver_cb);
        wait(vif.master_driver_cb.ARREADY);
        @(vif.master_driver_cb);
        

        // Wait for RLAST signal before sending next address
        wait(vif.master_driver_cb.RLAST && vif.master_driver_cb.RVALID);
        //vif.master_driver_cb.ARVALID <= 0;
    endtask: send_read_address

endclass: axi_master_driver

