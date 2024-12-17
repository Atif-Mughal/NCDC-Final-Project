//*****************************************************************************
//                      AXI SLAVE DRIVER CLASS
//*****************************************************************************
// Description: 
// This class implements the AXI Slave Driver in the UVM environment.
// It handles AXI transactions (write and read) by interacting with the virtual 
// interface and coordinating data transfers. The driver responds to AXI 
// handshakes and drives data to/from the DUT.
//*****************************************************************************

import config_pkg::*;             // Importing configuration package
import axi_parameters::*;         // Importing AXI parameters

class axi_slave_driver extends uvm_driver;
    `uvm_component_utils(axi_slave_driver)

    //=========================================================================
    //                              COMPONENTS
    //=========================================================================
    virtual axi4_if vif;          // Virtual interface for AXI communication

    //=========================================================================
    //                              VARIABLES
    //=========================================================================
    axi_master_seq_item write_transaction, read_transaction;   // Write and Read transaction objects
    bit [7:0] mem [bit[ADDR_WIDTH-1:0]];                       // Memory model for the slave
    bit [ADDR_WIDTH-1:0] write_addr, read_addr;                // Address variables for transactions
    bit write_done, read_done;                                 // Flags for write and read completion
    test_config test_cfg;                                      // Configuration object for the test

    //=========================================================================
    //                              CONSTRUCTOR
    //=========================================================================
    // Description: Initializes the AXI Slave Driver instance.
    // Sets default flags and prepares for configuration retrieval.
    //=========================================================================
    function new(string name, uvm_component parent);
        super.new(name, parent);
        write_done = 1;  // Set write_done flag to 'true' initially
        read_done = 1;   // Set read_done flag to 'true' initially
    endfunction: new

    //=========================================================================
    //                              BUILD PHASE
    //=========================================================================
    // Description: 
    // Retrieves required configurations (test configuration and virtual 
    // interface) from the UVM Configuration Database.
    //=========================================================================
    function void build_phase(uvm_phase phase);

        // Create transaction objects
        write_transaction = new("write_transaction");
        read_transaction = new("read_transaction");

        // Retrieve test configuration from ConfigDB
        if (!uvm_config_db#(test_config)::get(null, "*", "test_cfg", test_cfg))
            `uvm_fatal(get_name(), "Test configuration not found in ConfigDB!");

        // Retrieve virtual interface from ConfigDB
        if (!uvm_config_db#(virtual axi4_if)::get(null, "*env*", "vif", vif)) begin
            `uvm_error(get_name(), "Interface is not available in ConfigDB!");
        end
    endfunction: build_phase

    //=========================================================================
    //                              RUN PHASE
    //=========================================================================
    // Description: 
    // Drives AXI signals to DUT and ensures proper handshaking.
    // AXI control signals are set to their default values initially, and
    // transactions are driven forever using the 'drive()' task.
    //=========================================================================
    task run_phase(uvm_phase phase);

        // ------------------ Initialize AXI Control Signals ------------------
        vif.slave_driver_cb.AWREADY <= 1;   // Write address channel ready
        vif.slave_driver_cb.ARREADY <= 1;   // Read address channel ready
        vif.slave_driver_cb.WREADY  <= 1;   // Write data channel ready
        vif.slave_driver_cb.RVALID  <= 1;   // Read data valid signal
        vif.slave_driver_cb.RDATA   <= 'b0; // Default read data value

        // ------------------ Forever Drive Transactions ------------------
        forever begin
            @(vif.slave_driver_cb); // Wait for a clock cycle
            drive();                // Invoke the drive task to process transactions
        end
    endtask: run_phase
    
    //*****************************************************************************
    // Task: drive
    //-----------------------------------------------------------------------------
    // Description:
    // - Concurrently manages write and read operations using fork-join_none.
    // - Ensures seamless operation handling by monitoring write_done and read_done flags.
    //*****************************************************************************
    task drive();

        fork
            //-----------------------------------------------------------------------------
            // Write Operation Handling
            //-----------------------------------------------------------------------------
            begin
                if (write_done) begin
                    write_done = 0;
                    read_write_address();
                    read_write_data();
                    write_done = 1;
                end
            end

            //-----------------------------------------------------------------------------
            // Read Operation Handling
            //-----------------------------------------------------------------------------
            begin
                if (read_done) begin
                    read_done = 0;
                    read_read_address();
                    send_read_data();
                    read_done = 1;
                end
            end
        join_none

    endtask: drive


    //*****************************************************************************
    // Task: read_write_address
    //-----------------------------------------------------------------------------
    // Description:
    // - Captures address phase details during a write operation.
    // - Stores relevant information in the write_transaction object.
    //*****************************************************************************
    task read_write_address();

        // Log task entry
        `uvm_info(get_type_name(), "Inside read_write_address", UVM_HIGH)

        // Capture write address details
        write_transaction.ADDR = vif.slave_driver_cb.AWADDR;
        write_transaction.ID   = vif.slave_driver_cb.AWID;

        `uvm_info(get_type_name(), $sformatf("Captured Write Address: %0h", write_transaction.ADDR), UVM_HIGH)

    endtask: read_write_address


    //*****************************************************************************
    // Task: read_write_data
    //-----------------------------------------------------------------------------
    // Description:
    // - Captures data phase details during a write operation.
    // - Updates memory with the received data.
    //*****************************************************************************
    task read_write_data();
        int start_addr, current_addr, aligned_addr;
        int lower_byte_lane, upper_byte_lane, upper_wrap_boundary, lower_wrap_boundary;
        int bytes_per_beat, total_bytes;
        bit is_aligned;
        int byte_index;
        bit error_flag, alignment_error;
        `uvm_info(get_type_name(), "Inside read_write_data", UVM_HIGH)
        
        vif.slave_driver_cb.BVALID <= 0;  // Start by deasserting BVALID signal
        
        // Initial values and calculations
        start_addr = write_transaction.ADDR;
        bytes_per_beat = 2**write_transaction.BURST_SIZE;
        total_bytes = bytes_per_beat * (write_transaction.BURST_LENGTH + 1);
        aligned_addr = int'(start_addr / bytes_per_beat) * bytes_per_beat;
        `uvm_info(get_type_name(), $sformatf("Calculated aligned address %0d", aligned_addr), UVM_HIGH)
        is_aligned = start_addr == aligned_addr;

        // Calculate boundaries for WRAP Burst
        if (write_transaction.BURST_TYPE == WRAP) begin
            lower_wrap_boundary = int'(start_addr / total_bytes) * total_bytes;
            upper_wrap_boundary = lower_wrap_boundary + total_bytes;
            `uvm_info(get_type_name(), $sformatf("Calculated Lower Wrap Boundary: %0d", lower_wrap_boundary), UVM_HIGH)
            `uvm_info(get_type_name(), $sformatf("Calculated Upper Wrap Boundary: %0d", upper_wrap_boundary), UVM_HIGH)
        end

        // Check if the wrap burst is aligned or not
        if (write_transaction.BURST_TYPE == WRAP && !is_aligned)
            alignment_error = 1;

        // Store data into memory
        error_flag = 0;
        for (int i = 0; i < write_transaction.BURST_LENGTH + 1; i++) begin
            `uvm_info(get_type_name(), "Inside read_data_loop", UVM_HIGH)
            if (i == 0 || write_transaction.BURST_TYPE == FIXED) begin
                lower_byte_lane = start_addr - int'(start_addr / (DATA_WIDTH / 8)) * (DATA_WIDTH / 8);
                upper_byte_lane = aligned_addr + bytes_per_beat - 1 - int'(start_addr / (DATA_WIDTH / 8)) * (DATA_WIDTH / 8);
                current_addr = start_addr;
                byte_index = is_aligned ? 0 : lower_byte_lane;
                while (byte_index >= bytes_per_beat) begin
                    byte_index -= bytes_per_beat;
                end
            end else begin
                lower_byte_lane = current_addr - int'(current_addr / (DATA_WIDTH / 8)) * (DATA_WIDTH / 8);
                upper_byte_lane = lower_byte_lane + bytes_per_beat - 1;
                byte_index = 0;
            end

            `uvm_info(get_type_name(), $sformatf("lower_byte_lane is %0d", lower_byte_lane), UVM_HIGH)
            `uvm_info(get_type_name(), $sformatf("upper_byte_lane is %0d", upper_byte_lane), UVM_HIGH)
            `uvm_info(get_type_name(), $sformatf("current_addr is %0d", current_addr), UVM_HIGH)
            
            wait(vif.slave_driver_cb.WVALID); // Wait for valid write data
            
            error_flag = 0;
            for (int j = lower_byte_lane; j <= upper_byte_lane; j++) begin
                mem[current_addr + j - lower_byte_lane] = vif.slave_driver_cb.WDATA[8 * byte_index +: 8];
                `uvm_info(get_type_name(), $sformatf("byte_index is %0d, addr is %0d, stored value is %h", byte_index, current_addr + j - lower_byte_lane, mem[current_addr + j - lower_byte_lane]), UVM_HIGH)
                byte_index++;
                byte_index = byte_index >= bytes_per_beat ? 0 : byte_index;
            end

            // Update address
            if (write_transaction.BURST_TYPE != FIXED) begin
                if (is_aligned) begin
                    current_addr = current_addr + bytes_per_beat;
                    if (write_transaction.BURST_TYPE == WRAP) begin
                        `uvm_info(get_type_name(), $sformatf("Updated current_addr before boundary check: %0d", current_addr), UVM_HIGH)
                        current_addr = current_addr >= upper_wrap_boundary ? lower_wrap_boundary : current_addr;
                        `uvm_info(get_type_name(), $sformatf("Updated current_addr after boundary check: %0d", current_addr), UVM_HIGH)
                    end
                end else begin
                    current_addr = aligned_addr + bytes_per_beat;
                    is_aligned = 1;
                end
            end
            @(vif.slave_driver_cb);
        end

        // Write back the response
        vif.slave_driver_cb.BID <= write_transaction.ID;
        if (error_flag || alignment_error)
            vif.slave_driver_cb.BRESP <= 2'b01; // Error response
        else
            vif.slave_driver_cb.BRESP <= 2'b00; // OKAY response

        @(vif.slave_driver_cb);
        vif.slave_driver_cb.BVALID <= 1;
        @(vif.slave_driver_cb);
        wait(vif.slave_driver_cb.BREADY); // Wait for BREADY to deassert BVALID
        vif.slave_driver_cb.BVALID <= 0; // Deassert BVALID
    endtask: read_write_data

    //*****************************************************************************
    // Task: read_read_address
    //-----------------------------------------------------------------------------
    // Description:
    // - Waits for the ARVALID signal from the master, indicating a read request.
    // - Captures the read address channel signals and populates the read_transaction 
    //   object with relevant information.
    // - Prints the read transaction details for debugging.
    //*****************************************************************************
    task read_read_address();

        // Log task entry
        `uvm_info(get_type_name(), "Inside read_read_address", UVM_HIGH)

        // Assert ARREADY to indicate the Slave is ready to accept the read request
        vif.slave_driver_cb.ARREADY <= 1;

        // Wait for the master to assert ARVALID (valid read address request)
        wait(vif.slave_driver_cb.ARVALID);

        // Capture the read address channel information
        read_transaction.ARESET_n     = vif.ARESET_n;                     // Reset signal status
        read_transaction.ID           = vif.slave_driver_cb.ARID;         // Transaction ID
        read_transaction.ADDR         = vif.slave_driver_cb.ARADDR;       // Read address
        read_transaction.BURST_SIZE   = vif.slave_driver_cb.ARSIZE;       // Burst size
        read_transaction.BURST_TYPE   = B_TYPE'(vif.slave_driver_cb.ARBURST); // Burst type
        read_transaction.BURST_LENGTH = vif.slave_driver_cb.ARLEN;        // Burst length

        // Print the captured transaction for debugging
        read_transaction.print();

    endtask: read_read_address

    //*****************************************************************************
    // Task: send_read_data
    //-----------------------------------------------------------------------------
    // Description:
    // - Sends the read data response back to the master based on the captured 
    //   read_transaction details.
    // - Handles address alignment, burst types (FIXED, WRAP), and calculates
    //   the correct byte lanes for data transfer.
    // - Updates signals: RVALID, RLAST, and RRESP to complete the read transaction.
    //*****************************************************************************
    task send_read_data();
        // Local Variables
        int start_addr, current_addr, aligned_addr;    // Address variables
        int lower_byte_lane, upper_byte_lane;          // Byte lane boundaries
        int upper_wrap_boundary, lower_wrap_boundary;  // Wrap burst boundaries
        int bytes_per_beat, total_bytes;               // Burst and data calculations
        bit is_aligned;                                // Address alignment flag
        int byte_index;                                // Index for byte-level operations
        bit error_flag;                                // Error indication flag

        // Log task entry
        `uvm_info("SLAVE", "Inside send_read_data", UVM_HIGH)

        // ------------------ Initial Calculations ------------------
        start_addr     = read_transaction.ADDR;
        bytes_per_beat = 2 ** read_transaction.BURST_SIZE;  // Calculate bytes per transfer
        total_bytes    = bytes_per_beat * (read_transaction.BURST_LENGTH + 1);

        // Calculate aligned address for bursts
        aligned_addr = int'(start_addr / bytes_per_beat) * bytes_per_beat;
        is_aligned   = (start_addr == aligned_addr);
        `uvm_info(get_type_name(), $sformatf("Calculated aligned address %0d", aligned_addr), UVM_HIGH)

        // Calculate wrap boundaries for WRAP bursts
        if (read_transaction.BURST_TYPE == WRAP) begin
            lower_wrap_boundary = int'(start_addr / total_bytes) * total_bytes;
            upper_wrap_boundary = lower_wrap_boundary + total_bytes;
            `uvm_info(get_type_name(), $sformatf("Lower Wrap Boundary: %0d", lower_wrap_boundary), UVM_HIGH)
            `uvm_info(get_type_name(), $sformatf("Upper Wrap Boundary: %0d", upper_wrap_boundary), UVM_HIGH)
        end

        // ------------------ Signal Initialization ------------------
        vif.slave_driver_cb.RLAST  <= 0;   // Clear RLAST
        vif.slave_driver_cb.RVALID <= 0;   // Clear RVALID
        vif.slave_driver_cb.RID    <= read_transaction.ID;

        // ------------------ Data Transfer Loop ------------------
        for (int i = 0; i < read_transaction.BURST_LENGTH + 1; i++) begin
            `uvm_info(get_type_name(), "Inside read_data_loop", UVM_HIGH)

            // Lane selection: Adjust byte lanes for unaligned addresses or fixed bursts
            if (i == 0 || read_transaction.BURST_TYPE == FIXED) begin
                lower_byte_lane = start_addr % (DATA_WIDTH / 8);
                upper_byte_lane = lower_byte_lane + bytes_per_beat - 1;
                current_addr    = start_addr;
                byte_index      = is_aligned ? 0 : lower_byte_lane;
            end else begin
                lower_byte_lane = current_addr % (DATA_WIDTH / 8);
                upper_byte_lane = lower_byte_lane + bytes_per_beat - 1;
                byte_index      = 0;
            end

            // Debug lane and address information
            `uvm_info(get_type_name(), $sformatf("Lower Byte Lane: %0d", lower_byte_lane), UVM_HIGH)
            `uvm_info(get_type_name(), $sformatf("Upper Byte Lane: %0d", upper_byte_lane), UVM_HIGH)
            `uvm_info(get_type_name(), $sformatf("Current Address: %0d", current_addr), UVM_HIGH)

            // ------------------ Data Transfer ------------------
            error_flag = 0;
            for (int j = lower_byte_lane; j <= upper_byte_lane; j++) begin
                vif.slave_driver_cb.RDATA[8 * byte_index +: 8] <= mem[current_addr + j - lower_byte_lane];
                `uvm_info(get_type_name(), $sformatf("Byte Index: %0d, Addr: %0d, Data: %h", 
                        byte_index, current_addr + j - lower_byte_lane, mem[current_addr + j - lower_byte_lane]), UVM_HIGH)
                byte_index++;
                byte_index = (byte_index >= bytes_per_beat) ? 0 : byte_index;
            end

            // Update address for next transfer
            if (read_transaction.BURST_TYPE != FIXED) begin
                if (is_aligned) begin
                    current_addr += bytes_per_beat;
                    if (read_transaction.BURST_TYPE == WRAP) begin
                        current_addr = (current_addr >= upper_wrap_boundary) ? lower_wrap_boundary : current_addr;
                    end
                end else begin
                    current_addr = aligned_addr + bytes_per_beat;
                    is_aligned   = 1;
                end
            end

            // ------------------ Drive Read Response ------------------
            vif.slave_driver_cb.RID    <= read_transaction.ID;
            vif.slave_driver_cb.RRESP  <= (error_flag) ? 2'b01 : 2'b00; // Error or OKAY
            vif.slave_driver_cb.RVALID <= 1;

            wait(vif.slave_driver_cb.RREADY); // Wait for RREADY handshake
            @(vif.slave_driver_cb);
            vif.slave_driver_cb.RVALID <= 0;  // Clear RVALID after data transfer
        end

        // Assert RLAST to indicate the final beat of the burst
        vif.slave_driver_cb.RLAST <= 1;
        @(vif.slave_driver_cb);

    endtask: send_read_data

    //*****************************************************************************
    //                                END OF CLASS
    //*****************************************************************************
endclass



