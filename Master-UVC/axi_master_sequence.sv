// *****************************************************************************
// ** CLASS: axi_write_seq
// *****************************************************************************
/**
 * The `body` task handles the logic of generating multiple write transactions 
 * with configurable burst types, address alignment, and randomization features.
 */

// Class Declaration
import config_pkg::*;
import axi_parameters::*;
class axi_write_sequence extends uvm_sequence;

    // UVM factory registration macro to enable object creation via factory
    `uvm_object_param_utils(axi_write_sequence)

    // ***************** Class Variables *****************

    // Number of write transactions to generate (retrieved from config)
    const int number_of_transactions;

    // Transaction ID (incremented for each transaction)
    bit [7:0] id;

    // AXI transaction object
    axi_master_seq_item item;
    // Reference to the test configuration object
    test_config test_cfg;

    

    // ***************** Constructor *****************

    /**
     * @brief Constructor
     * Initializes the sequence and fetches the test configuration from UVM's config database.
     * 
     * @param name Name of the sequence (default "axi_write_seq")
     */
    function new(string name = "axi_write_seq");
        super.new(name);
        test_cfg = new("test_cfg");
        
        if (!uvm_config_db#(test_config)::get(null, "*", "test_cfg", test_cfg)) 
            `uvm_fatal(get_name(), "Test configuration not found in ConfigDB!");

        // Retrieve the number of write transactions to generate
        number_of_transactions = test_cfg.number_of_write_cases;

    endfunction: new

    // ***************** Body Task *****************

    /**
     * @brief Main task that generates AXI write transactions
     * This task creates and sends multiple write transactions based on the configuration.
     * It handles burst type, address alignment, and randomization of transaction parameters.
     */
    virtual task body();
    	// Fetch configuration from the UVM ConfigDB
    	
        
        // Repeat the transaction generation process based on `no_of_trans`
        repeat (number_of_transactions) begin
            id++;  // Increment the transaction ID

            // Create a new AXI transaction object
            item = axi_master_seq_item::type_id::create("item");

            // Apply address alignment constraints based on the configuration
            if (test_cfg.address_alignment == 1) begin
                // Enforce aligned addresses
                item.addr_alignment_constraint.constraint_mode(1); 
                item.addr_unalignment_constraint.constraint_mode(0); 
                item.addr_constraint.constraint_mode(0);
            end
            else if (test_cfg.address_alignment == 0) begin
                // Enforce unaligned addresses
                item.addr_alignment_constraint.constraint_mode(0); 
                item.addr_unalignment_constraint.constraint_mode(1); 
                item.addr_constraint.constraint_mode(0);
            end
            else begin
                // Allow random address alignment (both aligned and unaligned)
                item.addr_alignment_constraint.constraint_mode(0); 
                item.addr_unalignment_constraint.constraint_mode(0);
                item.addr_constraint.constraint_mode(1);
            end

            // Start the transaction item (prepare it for the sequencer)
            start_item(item);

            // Randomize the burst type based on test configuration
            if (test_cfg.burst_type == 0)
                assert(item.randomize() with { BURST_TYPE == FIXED; });
            else if (test_cfg.burst_type == 1)
                assert(item.randomize() with { BURST_TYPE == INCR; });
            else if (test_cfg.burst_type == 2)
                assert(item.randomize() with { BURST_TYPE == WRAP; });
            else
                assert(item.randomize()); // Default random burst type

            // Assign a unique ID to the transaction
            item.ID = {1'b0, id};

            // Complete the transaction item (send it to the sequencer)
            finish_item(item);

            // Print the transaction details for debugging
            item.print();

            // Introduce a small delay between transactions for simulation purposes
            #10;
        end
    endtask: body

endclass: axi_write_sequence

// *****************************************************************************
// ** CLASS: axi_read_seq
// *****************************************************************************
/**
 * @brief AXI Master Read Sequence Class
 * 
 * This class generates AXI read transactions for the UVM testbench. The sequence 
 * is fully configurable via `test_config` and allows flexibility in transaction 
 * parameters like burst type, address alignment, and number of read operations.
 * 
 * The `body` task is responsible for generating and sending read transactions 
 * to the AXI Master, with constraints applied dynamically.

 */

// Class Declaration
class axi_read_sequence extends uvm_sequence;
    
    // UVM factory registration macro
    `uvm_object_utils(axi_read_sequence)

    // ***************** Class Variables *****************

    // Number of read transactions to generate (fetched from config)
    const int number_of_transactions;

    // Transaction ID (incremented for each transaction)
    bit [7:0] id;

    // AXI transaction object to store transaction details
    axi_master_seq_item trans;

    // Reference to the test configuration object
    test_config test_cfg;

    // ***************** Constructor *****************

    /**
     * @brief Constructor
     * Initializes the sequence and retrieves the test configuration from UVM's ConfigDB.
     * 
     * @param name Name of the sequence (default "axi_read_seq")
     */
    function new(string name = "axi_read_sequence");
        super.new(name);

        // Retrieve configuration from ConfigDB
        if (!uvm_config_db#(test_config)::get(null, "*tb*", "test_cfg", test_cfg)) 
            `uvm_fatal(get_name(), "Test configuration not found in ConfigDB!");

        // Retrieve the number of read transactions to generate
        number_of_transactions = test_cfg.number_of_read_cases;
    endfunction: new

    // ***************** Body Task *****************

    /**
     * @brief Main task that generates AXI read transactions
     * This task handles the creation and randomization of read transactions. 
     * The transactions are generated based on the configuration settings like 
     * address alignment, burst type, and other parameters.
     */
    virtual task body();
        // Repeat transaction generation based on `no_of_trans`
        repeat (number_of_transactions) begin
            id++;  // Increment the transaction ID

            // Create a new AXI transaction object
            trans = axi_master_seq_item::type_id::create("trans");

            // Apply address alignment constraints based on the configuration
            if (test_cfg.address_alignment == 1) begin
                // Enforce aligned addresses
                trans.addr_alignment_constraint.constraint_mode(1); 
                trans.addr_unalignment_constraint.constraint_mode(0); 
                trans.addr_constraint.constraint_mode(0);
            end
            else if (test_cfg.address_alignment == 0) begin
                // Enforce unaligned addresses
                trans.addr_alignment_constraint.constraint_mode(0); 
                trans.addr_unalignment_constraint.constraint_mode(1); 
                trans.addr_constraint.constraint_mode(0);
            end
            else begin
                // Enable random address alignment (both aligned and unaligned)
                trans.addr_alignment_constraint.constraint_mode(0); 
                trans.addr_unalignment_constraint.constraint_mode(0);
                trans.addr_constraint.constraint_mode(1);
            end

            // Start the transaction item (prepare for sequencing)
            start_item(trans);

            // Randomize burst type based on the test configuration
            if (test_cfg.burst_type == 0)
                assert(trans.randomize() with { BURST_TYPE == FIXED; });
            else if (test_cfg.burst_type == 1)
                assert(trans.randomize() with { BURST_TYPE == INCR; });
            else if (test_cfg.burst_type == 2)
                assert(trans.randomize() with { BURST_TYPE == WRAP; });
            else
                assert(trans.randomize()); // Default randomization

            // Set transaction ID
            trans.ID = {1'b1, id};

            // Complete the transaction item (submit to sequencer)
            finish_item(trans);

            // Print transaction details for debugging purposes
            trans.print();

            // Introduce a small delay between transactions for simulation purposes
            #10;
        end
    endtask: body

endclass: axi_read_sequence

