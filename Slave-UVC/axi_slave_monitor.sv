//************************************************************
//               AXI SLAVE MONITOR CLASS
//************************************************************
// Description: 
// - Monitors AXI transactions for the Slave interface.
// - Captures write and read transactions and sends them to
//   the scoreboard for verification through an analysis port.
//************************************************************

import config_pkg::*;           // Import configuration package
import axi_parameters::*;       // Import AXI parameter definitions

//************************************************************
// ENUMERATIONS
//************************************************************
// B_TYPE: Defines burst types for AXI transactions.
typedef enum bit [1:0] { FIXED, INCR, WRAP } B_TYPE;

//************************************************************
// CLASS: axi_slave_monitor
//************************************************************
class axi_slave_monitor extends uvm_monitor;

    // Factory registration for the UVM component
    `uvm_component_utils(axi_slave_monitor)

    //****************************************************
    //              INTERFACE AND PORTS
    //****************************************************
    virtual axi4_if vif; // Virtual interface to connect with the DUT

    // Analysis port to send transaction objects to the scoreboard
    uvm_analysis_port#(axi_master_seq_item) mon2scb_port;

    //****************************************************
    //              VARIABLES
    //****************************************************
    axi_master_seq_item write_transaction, read_transaction; // Transaction objects
    bit write_done, read_done;                               // Flags to indicate transaction completion

    //****************************************************
    //              CONSTRUCTOR
    //****************************************************
    // Initializes the monitor and fetches the interface
    function new(string name = "axi_slave_monitor", uvm_component parent);
        super.new(name, parent);
        write_done = 1;   // Mark write transaction as initially completed
        read_done = 1;    // Mark read transaction as initially completed

        // Fetch virtual interface from UVM config database
        if (!uvm_config_db#(virtual axi4_if)::get(null, "*env*", "vif", vif)) begin
            `uvm_error(get_name(), "AXI Interface is not available. Check your configuration.")
        end
    endfunction

    //****************************************************
    //              BUILD PHASE
    //****************************************************
    // Initializes ports and analysis components
    function void build_phase(uvm_phase phase);
        mon2scb_port = new("mon2scb_port", this); // Instantiate the analysis port
    endfunction

    //****************************************************
    //              RUN PHASE
    //****************************************************
    // Continuously monitor AXI transactions during simulation
    task run_phase(uvm_phase phase);
        forever begin
            run_mon(phase);     // Monitor AXI transactions
            @(vif.monitor_cb);  // Synchronize with the AXI clock
        end
    endtask

    //****************************************************
    //              MONITOR TASK
    //****************************************************
    // Handles concurrent monitoring of write and read transactions
    task run_mon(uvm_phase phase);
        fork
            // ------------------ WRITE TRANSACTION MONITOR ------------------
            if (write_done) begin
                phase.raise_objection(this); // Raise phase objection
                write_done = 0;              // Mark write transaction as ongoing
                write_monitor();             // Start write transaction monitoring
                write_done = 1;              // Mark write transaction as completed
                phase.drop_objection(this);  // Drop phase objection
            end

            // ------------------ READ TRANSACTION MONITOR ------------------
            if (read_done) begin
                phase.raise_objection(this); // Raise phase objection
                read_done = 0;               // Mark read transaction as ongoing
                read_monitor();              // Start read transaction monitoring
                read_done = 1;               // Mark read transaction as completed
                phase.drop_objection(this);  // Drop phase objection
            end
        join_none
    endtask

    //************************************************************
    //                WRITE TRANSACTION MONITORING
    //************************************************************
    // Monitors the AXI Write transaction:
    // - Captures Write Address, Write Data, and Write Response channels.
    // - Sends the collected transaction object to the analysis port.
    //************************************************************
    task write_monitor();

        // Check for the Write Address handshake (AWVALID & AWREADY)
        if (vif.monitor_cb.AWVALID && vif.monitor_cb.AWREADY) begin

            // Create a new write transaction object
            write_transaction = axi_master_seq_item::type_id::create("write_transaction");

            // ------------------ Collect Write Address Channel ------------------
            write_transaction.ARESET_n     = vif.ARESET_n;             // Capture reset signal
            write_transaction.ADDR         = vif.monitor_cb.AWADDR;    // Write address
            write_transaction.ID           = vif.monitor_cb.AWID;      // Transaction ID
            write_transaction.BURST_SIZE   = vif.monitor_cb.AWSIZE;    // Burst size
            write_transaction.BURST_LENGTH = vif.monitor_cb.AWLEN;     // Burst length
            write_transaction.BURST_TYPE   = B_TYPE'(vif.monitor_cb.AWBURST); // Burst type
            write_transaction.DATA         = new [write_transaction.BURST_LENGTH + 1]; // Initialize data array

            // ------------------ Collect Write Data Channel ------------------
            for (int i = 0; i < write_transaction.BURST_LENGTH + 1; i++) begin
                @(vif.monitor_cb);  // Synchronize with the AXI clock

                // Wait for Write Data handshake (WVALID & WREADY)
                wait(vif.monitor_cb.WVALID && vif.monitor_cb.WREADY);

                // Initialize memory to hold write data
                write_transaction.DATA[i] = new [DATA_WIDTH / 8];

                // Capture write data byte by byte
                for (int j = 0; j < DATA_WIDTH / 8; j++) begin
                    write_transaction.DATA[i][j] = vif.monitor_cb.WDATA[8 * j +: 8];
                end
            end

            // ------------------ Collect Write Response Channel ------------------
            wait(vif.monitor_cb.BVALID);  // Wait for Write Response (BVALID asserted)
            write_transaction.WRITE_RESP = vif.monitor_cb.BRESP; // Capture write response status

            // ------------------ Send Write Transaction to Analysis Port ------------------
            mon2scb_port.write(write_transaction);

            // Log the captured write transaction details
            `uvm_info(get_type_name(), $sformatf("Write Transaction: %s", write_transaction.sprint()), UVM_HIGH)
        end
    endtask

    //************************************************************
    //                READ TRANSACTION MONITORING
    //************************************************************
    // Monitors the AXI Read transaction:
    // - Captures Read Address and Read Data channels.
    // - Sends the collected transaction object to the analysis port.
    //************************************************************
    task read_monitor();

        // Check for the Read Address handshake (ARVALID & ARREADY)
        if (vif.monitor_cb.ARVALID && vif.monitor_cb.ARREADY) begin

            // Create a new read transaction object
            read_transaction = axi_master_seq_item::type_id::create("read_transaction");

            // ------------------ Collect Read Address Channel ------------------
            read_transaction.ARESET_n     = vif.ARESET_n;             // Capture reset signal
            read_transaction.ADDR         = vif.monitor_cb.ARADDR;    // Read address
            read_transaction.ID           = vif.monitor_cb.ARID;      // Transaction ID
            read_transaction.BURST_SIZE   = vif.monitor_cb.ARSIZE;    // Burst size
            read_transaction.BURST_LENGTH = vif.monitor_cb.ARLEN;     // Burst length
            read_transaction.BURST_TYPE   = B_TYPE'(vif.monitor_cb.ARBURST); // Burst type
            read_transaction.DATA         = new [read_transaction.BURST_LENGTH + 1];  // Initialize data array
            read_transaction.READ_RESP    = new [read_transaction.BURST_LENGTH + 1];  // Initialize response array

            // ------------------ Collect Read Data Channel ------------------
            for (int i = 0; i < read_transaction.BURST_LENGTH + 1; i++) begin
                @(vif.monitor_cb);  // Synchronize with the AXI clock

                // Wait for Read Data handshake (RVALID & RREADY)
                wait(vif.monitor_cb.RVALID && vif.monitor_cb.RREADY);

                // Initialize memory to hold read data
                read_transaction.DATA[i] = new [DATA_WIDTH / 8];

                // Capture read data byte by byte
                for (int j = 0; j < DATA_WIDTH / 8; j++) begin
                    read_transaction.DATA[i][j] = vif.monitor_cb.RDATA[8 * j +: 8];
                end

                // Capture read response status for each data beat
                read_transaction.READ_RESP[i] = vif.monitor_cb.RRESP;
            end

            // ------------------ Send Read Transaction to Analysis Port ------------------
            mon2scb_port.write(read_transaction);

            // Log the captured read transaction details
            `uvm_info(get_type_name(), $sformatf("Read Transaction: %s", read_transaction.sprint()), UVM_HIGH)
        end
    endtask

    //********************************************************************************
    //                               END OF MONITORING
    //********************************************************************************

endclass: axi_slave_monitor

//***********************************************************************************
//                                      END OF CLASS
//***********************************************************************************
