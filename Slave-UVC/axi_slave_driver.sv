import config_pkg::*;
import axi_parameters::*;
class axi_slave_driver extends uvm_driver;
    `uvm_component_utils(axi_slave_driver)
    
    // Components
    virtual axi4_if vif;

    // Variables
    axi_master_seq_item write_transaction, read_transaction;
    bit [7:0] mem [bit[ADDR_WIDTH-1:0]];
    bit [ADDR_WIDTH-1:0] write_addr, read_addr;
    bit write_done, read_done;
    test_config test_cfg;
    

    function new(string name, uvm_component parent);
        super.new(name, parent);
        write_done = 1;
        read_done = 1;
        // Retrieve configuration from ConfigDB
         
    endfunction //new()
    function void build_phase(uvm_phase phase);
        write_transaction = new("write_transaction");
        read_transaction = new("read_transaction");
        
        if (!uvm_config_db#(test_config)::get(null, "*", "test_cfg", test_cfg)) 
            `uvm_fatal(get_name(), "Test configuration not found in ConfigDB!");
        if (!uvm_config_db#(virtual axi4_if)::get(null,"*env*","vif",vif))
        begin
           `uvm_error(get_name(), "Interface is not available");
        end
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        vif.slave_driver_cb.AWREADY    <= 1;
        vif.slave_driver_cb.ARREADY    <= 1;
        vif.slave_driver_cb.WREADY     <= 1;
        // vif.slave_driver_cb.BVALID     <= 1;
        // vif.slave_driver_cb.RLAST      <= 1;
        vif.slave_driver_cb.RVALID     <= 1;
        vif.slave_driver_cb.RDATA      <= 'b0;
        forever begin
            @(vif.slave_driver_cb);
            drive();
        end
    endtask: run_phase

    

    task drive();
        if(!test_cfg.ARESET_n) begin
            vif.slave_driver_cb.RVALID <= 0;
            vif.slave_driver_cb.BVALID <= 0;
            return;
        end
        fork
            begin
                if(write_done) begin
                    write_done = 0;
                    read_write_address();
                    read_write_data();
                    write_done = 1;
                end
            end
            begin
                
                if(read_done) begin
                    read_done = 0;
                    read_read_address();
                    send_read_data();
                    read_done = 1;
                end
            end
        join_none
    endtask: drive

    task read_write_address();
        `uvm_info(get_type_name(), "Inside read_write_address", UVM_HIGH)
        wait(vif.slave_driver_cb.AWVALID);
        write_transaction.ID     = vif.slave_driver_cb.AWID;
        write_transaction.ADDR   = vif.slave_driver_cb.AWADDR;
        write_transaction.BURST_SIZE = vif.slave_driver_cb.AWSIZE;
        write_transaction.BURST_TYPE = B_TYPE'(vif.slave_driver_cb.AWBURST);
        write_transaction.BURST_LENGTH  = vif.slave_driver_cb.AWLEN;

        write_transaction.print();
    endtask: read_write_address
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
                if (current_addr + j - lower_byte_lane >= 2**ADDR_WIDTH)
                    error_flag = 1;
                if (error_flag || alignment_error)
                    continue;
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

    task read_read_address();
        `uvm_info(get_type_name(), "Inside read_write_address", UVM_HIGH)
        vif.slave_driver_cb.ARREADY <= 1;
        wait(vif.slave_driver_cb.ARVALID);
        read_transaction.ID     = vif.slave_driver_cb.ARID;
        read_transaction.ADDR   = vif.slave_driver_cb.ARADDR;
        read_transaction.BURST_SIZE = vif.slave_driver_cb.ARSIZE;
        read_transaction.BURST_TYPE = B_TYPE'(vif.slave_driver_cb.ARBURST);
        read_transaction.BURST_LENGTH  = vif.slave_driver_cb.ARLEN;

        read_transaction.print();
    endtask: read_read_address

    task send_read_data();
        int start_addr, current_addr, aligned_addr;
        int lower_byte_lane, upper_byte_lane, upper_wrap_boundary, lower_wrap_boundary;
        int bytes_per_beat, total_bytes;
        bit is_aligned;
        int byte_index;
        bit error_flag;
        `uvm_info("SLAVE", "Inside send_read_data", UVM_HIGH)
        
        start_addr = read_transaction.ADDR;
        bytes_per_beat = 2**read_transaction.BURST_SIZE;
        total_bytes = bytes_per_beat * (read_transaction.BURST_LENGTH + 1);

        // Calculate aligned address
        aligned_addr = int'(start_addr / bytes_per_beat) * bytes_per_beat;
        `uvm_info(get_type_name(), $sformatf("Calculated aligned address %0d", aligned_addr), UVM_HIGH)
        is_aligned = start_addr == aligned_addr;

        // If WRAP Burst, calculate wrap boundary
        if (read_transaction.BURST_TYPE == WRAP) begin
            lower_wrap_boundary = int'(start_addr / total_bytes) * total_bytes;
            upper_wrap_boundary = lower_wrap_boundary + total_bytes;
            `uvm_info(get_type_name(), $sformatf("Calculated Lower Wrap Boundary: %0d", lower_wrap_boundary), UVM_HIGH)
            `uvm_info(get_type_name(), $sformatf("Calculated Upper Wrap Boundary: %0d", upper_wrap_boundary), UVM_HIGH)
        end

        // Initializing signals
        vif.slave_driver_cb.RLAST <= 0;
        vif.slave_driver_cb.RVALID <= 0;
        vif.slave_driver_cb.RID <= read_transaction.ID;

        // Store data
        for (int i = 0; i < read_transaction.BURST_LENGTH + 1; i++) begin
            `uvm_info(get_type_name(), "Inside read_data_loop", UVM_HIGH)

            // Lane selection for the first transfer (handle unaligned address cases)
            if (i == 0 || read_transaction.BURST_TYPE == FIXED) begin
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
            //$display("WALID = %0d", vif.slave_driver_cb.WVALID);
            
            //wait(vif.slave_driver_cb.WVALID); // Wait for valid read data
            
            error_flag = 0;
            for (int j = lower_byte_lane; j <= upper_byte_lane; j++) begin
                if (current_addr + j - lower_byte_lane >= 2**ADDR_WIDTH)
                    error_flag = 1;
                if (error_flag)
                    continue;
                vif.slave_driver_cb.RDATA[8 * byte_index +: 8] <= mem[current_addr + j - lower_byte_lane];
                `uvm_info(get_type_name(), $sformatf("byte_index is %0d, addr is %0d, stored value is %h", byte_index, current_addr + j - lower_byte_lane, mem[current_addr + j - lower_byte_lane]), UVM_HIGH)
                byte_index++;
                byte_index = byte_index >= bytes_per_beat ? 0 : byte_index;
            end

            // Update address
            if (read_transaction.BURST_TYPE != FIXED) begin
                if (is_aligned) begin
                    current_addr = current_addr + bytes_per_beat;
                    if (read_transaction.BURST_TYPE == WRAP) begin
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
        vif.slave_driver_cb.RID <= read_transaction.ID;
        if (error_flag)
            vif.slave_driver_cb.RRESP <= 2'b01; // Error response
        else
            vif.slave_driver_cb.RRESP <= 2'b00; // OKAY response

        @(vif.slave_driver_cb);
        vif.slave_driver_cb.RVALID <= 1;
        
        @(vif.slave_driver_cb);
        wait(vif.slave_driver_cb.RREADY); // Wait for RREADY to deassert RVALID
        vif.slave_driver_cb.RLAST  <= 1;
        @(vif.slave_driver_cb);
        vif.slave_driver_cb.RVALID <= 0; // Deassert RVALID
    endtask: send_read_data
 
endclass 


