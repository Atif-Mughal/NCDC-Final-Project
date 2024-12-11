import config_pkg::*;
import axi_parameters::*;
class axi_slave_monitor extends uvm_monitor;
    `uvm_component_utils(axi_slave_monitor)

    // ******************* Component Interface *******************
    // Virtual Interface for the AXI Slave interface (connected to the DUT)
    virtual axi4_if vif;

    // ******************* UVM Ports *******************
    uvm_analysis_port#(axi_master_seq_item) mon2scb_port; // Analysis port for write/read transactions

    // ******************* Variables *******************
    axi_master_seq_item write_transaction, read_transaction;  // Write and Read transaction objects
    bit write_done, read_done;                               // Flags to indicate transaction completion

    // ******************* Constructor *******************
    function new(string name = "axi_slave_monitor", uvm_component parent);
        super.new(name, parent);
        write_done = 1;   // Initially set write transaction as done
        read_done = 1;    // Initially set read transaction as done
    endfunction

    // ******************* Build Phase *******************
    function void build_phase(uvm_phase phase);
        mon2scb_port = new("mon2scb_port", this); // Create the analysis port for transaction items
    endfunction

    // ******************* Run Phase *******************
    task run_phase(uvm_phase phase);
        forever begin
            run_mon(phase);  // Monitor the AXI signals in each phase iteration
            @(vif.mon_cb);    // Synchronize with the AXI interface clock
        end
    endtask

    // ******************* Monitor Task *******************
    task run_mon(uvm_phase phase);
        fork
            // Monitor Write Transaction
            if (write_done) begin
                phase.raise_objection(this);  // Raise objection for the phase
                write_done = 0;
                write_monitor();  // Monitor the write transaction
                write_done = 1;
                phase.drop_objection(this);  // Drop objection after transaction is completed
            end

            // Monitor Read Transaction
            if (read_done) begin
                phase.raise_objection(this);  // Raise objection for the phase
                read_done = 0;
                read_monitor();  // Monitor the read transaction
                read_done = 1;
                phase.drop_objection(this);  // Drop objection after transaction is completed
            end
        join_none
    endtask

    // ******************* Write Transaction Monitoring *******************
    task write_monitor();
        if (vif.mon_cb.AWVALID && vif.mon_cb.AWREADY) begin
            write_transaction = axi_master_seq_item::type_id::create("write_transaction");

            // Collect Write Address channel information
            write_transaction.ADDR = vif.mon_cb.AWADDR;
            write_transaction.ID = vif.mon_cb.AWID;
            write_transaction.BURST_SIZE = vif.mon_cb.AWSIZE;
            write_transaction.BURST_LENGTH = vif.mon_cb.AWLEN;
            write_transaction.BURST_TYPE = B_TYPE'(vif.mon_cb.AWBURST);
            write_transaction.DATA = new [write_transaction.BURST_LENGTH + 1];

            // Collect Write Data channel information
            for (int i = 0; i < write_transaction.BURST_LENGTH + 1; i++) begin
                @(vif.mon_cb);  // Wait for the AXI interface
                wait(vif.mon_cb.WVALID && vif.mon_cb.WREADY);  // Ensure WVALID and WREADY are asserted
                write_transaction.DATA[i] = new [DATA_WIDTH / 8];  // Initialize the data
                for (int j = 0; j < DATA_WIDTH / 8; j++) begin
                    write_transaction.DATA[i][j] = vif.mon_cb.WDATA[8 * j +: 8];  // Capture the write data
                end
            end

            // Wait for Write Response
            wait(vif.mon_cb.BVALID);

            // Collect Write Response
            write_transaction.WRITE_RESP = vif.mon_cb.BRESP;

            // Send the captured transaction to the analysis port for reporting or coverage
            mon2scb_port.write(write_transaction);
            `uvm_info(get_type_name(), $sformatf("Write Transaction: %s", write_transaction.sprint()), UVM_HIGH)
        end
    endtask

    // ******************* Read Transaction Monitoring *******************
    task read_monitor();
        if (vif.mon_cb.ARVALID && vif.mon_cb.ARREADY) begin
            read_transaction = axi_master_seq_item::type_id::create("read_transaction");

            // Collect Read Address channel information
            read_transaction.ADDR = vif.mon_cb.ARADDR;
            read_transaction.ID = vif.mon_cb.ARID;
            read_transaction.BURST_SIZE = vif.mon_cb.ARSIZE;
            read_transaction.BURST_LENGTH = vif.mon_cb.ARLEN;
            read_transaction.BURST_TYPE = B_TYPE'(vif.mon_cb.ARBURST);
            read_transaction.DATA = new [read_transaction.BURST_LENGTH + 1];
            read_transaction.READ_RESP = new [read_transaction.BURST_LENGTH + 1];

            // Collect Read Data channel information
            for (int i = 0; i < read_transaction.BURST_LENGTH + 1; i++) begin
                @(vif.mon_cb);  // Wait for the AXI interface
                wait(vif.mon_cb.RVALID && vif.mon_cb.RREADY);  // Ensure RVALID and RREADY are asserted
                read_transaction.DATA[i] = new [DATA_WIDTH / 8];  // Initialize the data
                for (int j = 0; j < DATA_WIDTH / 8; j++) begin
                    read_transaction.DATA[i][j] = vif.mon_cb.RDATA[8 * j +: 8];  // Capture the read data
                end
                read_transaction.READ_RESP[i] = vif.mon_cb.RRESP;  // Capture the read response
            end

            // Send the captured read transaction to the analysis port
            mon2scb_port.write(read_transaction);
            `uvm_info(get_type_name(), $sformatf("Read Transaction: %s", read_transaction.sprint()), UVM_HIGH)
        end
    endtask

endclass: axi_slave_monitor
