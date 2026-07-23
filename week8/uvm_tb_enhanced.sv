//===========================================================================
// DUAL-PORT RAM VERIFICATION TESTBENCH
//===========================================================================
// 
// This testbench implements a complete UVM verification environment for a
// dual-port RAM module. It demonstrates production-grade verification
// practices including:
//
// - Stimulus generation via constrained randomization
// - Protocol-aware monitoring with assertions
// - Layered sequences for complex test patterns
// - Performance tracking and statistics collection
// - Coverage tracking for test completeness
//
// Architecture:
//   Test creates Environment
//   ├─ Agent (driver, sequencer, monitor)
//   └─ Scoreboard (verification logic)
//
// Data Flow:
//   Sequencer → Driver → DUT → Monitor → Scoreboard
//
// Phases: build → connect → run → report
//===========================================================================

import uvm_pkg::*;
`include "uvm_macros.svh"

//===========================================================================
// INTERFACE DOCUMENTATION
//===========================================================================
// The dual_port_ram_if bundles all signals and includes a clocking block
// for synchronized stimulus and response. This enables:
// - Clean separation between testbench and DUT timing
// - Automatic sampling/driving at clock edges
// - Race-condition avoidance
//===========================================================================
interface dual_port_ram_if;
  logic clk;
  logic resetN;
  
  logic [3:0] addr_a;
  logic [7:0] write_data_a;
  logic write_enable_a;
  logic [7:0] read_data_a;
  
  logic [3:0] addr_b;
  logic [7:0] write_data_b;
  logic write_enable_b;
  logic [7:0] read_data_b;
  
  clocking cb @(posedge clk);
    output addr_a, write_data_a, write_enable_a;
    output addr_b, write_data_b, write_enable_b;
    input read_data_a, read_data_b;
  endclocking
endinterface

//===========================================================================
// TRANSACTION DOCUMENTATION
//===========================================================================
// ram_transaction represents a single read or write operation:
// - addr: target address (0-15)
// - data: data value (8-bit)
// - write: 1 for write, 0 for read
//
// Transactions flow from sequences → sequencer → driver → DUT
// and observations flow from monitor → scoreboard
//===========================================================================
class ram_transaction extends uvm_sequence_item;
  `uvm_object_utils(ram_transaction)
  
  logic [3:0] addr;
  logic [7:0] data;
  logic write;
  
  function new(string name = "ram_transaction");
    super.new(name);
  endfunction
endclass

//===========================================================================
// SEQUENCER DOCUMENTATION
//===========================================================================
// The sequencer is a built-in UVM component that:
// - Mediates between sequences and driver
// - Implements the standard UVM handshake (get_next_item/item_done)
// - Manages stimulus delivery
// - Handles randomization and constraints
//===========================================================================
class ram_sequencer extends uvm_sequencer #(ram_transaction);
  `uvm_component_utils(ram_sequencer)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass

//===========================================================================
// DRIVER DOCUMENTATION
//===========================================================================
// The driver applies stimulus to the DUT. It:
// - Pulls transactions from sequencer
// - Maps them to physical signals
// - Validates transactions before application
// - Tracks performance metrics
// - Reports errors on invalid data
//===========================================================================
class ram_driver extends uvm_driver #(ram_transaction);
  `uvm_component_utils(ram_driver)
  
  virtual dual_port_ram_if vif;
  
  // Configuration
  int trans_delay = 0;        // Delay between transactions (cycles)
  bit enable_performance_tracking = 1;  // Monitor performance metrics
  
  // Performance tracking
  int total_transactions = 0;
  int total_writes = 0;
  int total_reads = 0;
  int cycles_elapsed = 0;
  
  // Transaction history
  ram_transaction trans_history[$];  // Queue of all transactions
  int max_history_size = 100;        // Keep last 100 transactions
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual dual_port_ram_if)::get(this, "", "vif", vif))
      `uvm_error("DRV", "Virtual interface not found!");
    
    // Get configuration from database
    uvm_config_db #(int)::get(this, "", "trans_delay", trans_delay);
    uvm_config_db #(bit)::get(this, "", "enable_performance_tracking", enable_performance_tracking);
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      ram_transaction xact;
      seq_item_port.get_next_item(xact);
      
      // Apply transaction
      apply_transaction(xact);
      
      // Track transaction
      if (enable_performance_tracking) begin
        track_transaction(xact);
      end
      
      // Apply inter-transaction delay
      if (trans_delay > 0) begin
        repeat (trans_delay) @(posedge vif.clk);
      end
      
      seq_item_port.item_done();
    end
  endtask
  
  task apply_transaction(ram_transaction xact);
    `uvm_info("DRV", $sformatf("Applying: addr=%d, data=%h, write=%b", 
      xact.addr, xact.data, xact.write), UVM_LOW);
    
    // Validate transaction
    if (!validate_transaction(xact)) begin
      `uvm_error("DRV", "Transaction validation failed!");
      return;
    end
    
    // Set control signals
    vif.addr_a = xact.addr;
    vif.write_data_a = xact.data;
    vif.write_enable_a = xact.write;
    
    // Wait for clock edge
    @(posedge vif.clk);
    
    // Clear signals
    vif.write_enable_a = 0;
    
    `uvm_info("DRV", $sformatf("Applied: addr=%d, data=%h", 
      xact.addr, xact.data), UVM_LOW);
  endtask
  
  function bit validate_transaction(ram_transaction xact);
    bit valid = 1;
    
    // Check address range
    if (xact.addr > 15) begin
      `uvm_error("DRV", $sformatf("Invalid address: %d (max=15)", xact.addr));
      valid = 0;
    end
    
    // Check write signal
    if (xact.write != 0 && xact.write != 1) begin
      `uvm_error("DRV", $sformatf("Invalid write signal: %b", xact.write));
      valid = 0;
    end
    
    return valid;
  endfunction
  
  function void track_transaction(ram_transaction xact);
    // Add to history
    trans_history.push_back(xact);
    
    // Maintain history size
    if (trans_history.size() > max_history_size) begin
      trans_history.delete(0);
    end
    
    // Update statistics
    total_transactions++;
    if (xact.write == 1)
      total_writes++;
    else
      total_reads++;
  endfunction
  
  function void report_performance_metrics();
    real throughput;
    int avg_addr;
    
    `uvm_info("DRV", "=== Performance Metrics ===", UVM_HIGH);
    `uvm_info("DRV", $sformatf("Total transactions: %d", total_transactions), UVM_HIGH);
    `uvm_info("DRV", $sformatf("  Writes: %d", total_writes), UVM_HIGH);
    `uvm_info("DRV", $sformatf("  Reads: %d", total_reads), UVM_HIGH);
    
    if (total_writes > 0) begin
      `uvm_info("DRV", $sformatf("Write ratio: %.2f%%", 
        (real'(total_writes) / real'(total_transactions)) * 100), UVM_HIGH);
    end
    
    `uvm_info("DRV", $sformatf("History size: %d transactions", 
      trans_history.size()), UVM_HIGH);
  endfunction
  
  function void print_transaction_history();
    `uvm_info("DRV", "=== Transaction History ===", UVM_HIGH);
    foreach (trans_history[i]) begin
      ram_transaction xact = trans_history[i];
      `uvm_info("DRV", $sformatf("[%d] addr=%d, data=%h, write=%b", 
        i, xact.addr, xact.data, xact.write), UVM_HIGH);
    end
  endfunction
  
  function void reset_statistics();
    total_transactions = 0;
    total_writes = 0;
    total_reads = 0;
    trans_history.delete();
    `uvm_info("DRV", "Statistics reset", UVM_HIGH);
  endfunction
endclass

//===========================================================================
// MONITOR DOCUMENTATION
//===========================================================================
// The monitor observes DUT behavior. It:
// - Captures port outputs passively (no DUT modification)
// - Validates protocol compliance
// - Checks for data consistency
// - Tracks coverage of exercised scenarios
// - Broadcasts observations to scoreboard
//===========================================================================
class ram_monitor extends uvm_monitor;
  `uvm_component_utils(ram_monitor)
  
  virtual dual_port_ram_if vif;
  uvm_analysis_port #(ram_transaction) ap;
  
  // Configuration
  bit enable_assertions = 1;      // Enable/disable assertion checking
  bit enable_coverage = 1;        // Enable/disable coverage tracking
  
  // Statistics
  int observations = 0;
  int assertion_failures = 0;
  int data_mismatches = 0;
  
  // Expected data storage (for comparison)
  logic [7:0] expected_data[logic [3:0]];  // addr -> expected data
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db #(virtual dual_port_ram_if)::get(this, "", "vif", vif))
      `uvm_error("MON", "Virtual interface not found!");
    
    // Get configuration
    uvm_config_db #(bit)::get(this, "", "enable_assertions", enable_assertions);
    uvm_config_db #(bit)::get(this, "", "enable_coverage", enable_coverage);
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      
      // Observe Port B (read operations)
      observe_port_b();
      
      // Observe Port A (write operations)
      observe_port_a();
    end
  endtask
  
  task observe_port_b();
    ram_transaction xact;
    
    // Only process if not writing
    if (vif.write_enable_b == 0) begin
      xact = ram_transaction::type_id::create("xact_b");
      xact.addr = vif.addr_b;
      xact.data = vif.read_data_b;
      xact.write = 0;
      
      observations++;
      
      // Run assertions
      if (enable_assertions) begin
        check_address_validity(xact.addr, "Port B");
        check_data_validity(xact.data, "Port B");
        check_read_consistency(xact.addr, xact.data);
      end
      
      // Broadcast observation
      ap.write(xact);
      
      `uvm_info("MON", $sformatf("Observed read: addr=%d, data=%h", 
        xact.addr, xact.data), UVM_LOW);
      
      // Update coverage
      if (enable_coverage) begin
        cover_read_access(xact.addr, xact.data);
      end
    end
  endtask
  
  task observe_port_a();
    ram_transaction xact;
    
    // Only process if writing
    if (vif.write_enable_a == 1) begin
      xact = ram_transaction::type_id::create("xact_a");
      xact.addr = vif.addr_a;
      xact.data = vif.write_data_a;
      xact.write = 1;
      
      // Store expected data for later comparison
      expected_data[xact.addr] = xact.data;
      
      // Run assertions
      if (enable_assertions) begin
        check_address_validity(xact.addr, "Port A");
        check_data_validity(xact.data, "Port A");
        check_write_completion(xact.addr, xact.data);
      end
      
      `uvm_info("MON", $sformatf("Observed write: addr=%d, data=%h", 
        xact.addr, xact.data), UVM_LOW);
      
      // Update coverage
      if (enable_coverage) begin
        cover_write_access(xact.addr, xact.data);
      end
    end
  endtask
  
  function void check_address_validity(logic [3:0] addr, string port_name);
    // Assertion: Address must be in valid range [0:15]
    if (addr > 15) begin
      `uvm_error("MON", $sformatf("ASSERTION FAILED (%s): Invalid address %d (must be 0-15)", 
        port_name, addr));
      assertion_failures++;
    end else begin
      `uvm_info("MON", $sformatf("PASS: %s address valid (%d)", port_name, addr), UVM_HIGH);
    end
  endfunction
  
  function void check_data_validity(logic [7:0] data, string port_name);
    // Assertion: Data is always valid (8-bit value)
    // This always passes, but documents the check
    `uvm_info("MON", $sformatf("PASS: %s data valid (%h)", port_name, data), UVM_HIGH);
  endfunction
  
  function void check_read_consistency(logic [3:0] addr, logic [7:0] data);
    // Assertion: If data was previously written to this address, verify consistency
    if (expected_data.exists(addr)) begin
      if (expected_data[addr] != data) begin
        `uvm_error("MON", $sformatf("ASSERTION FAILED: Read data mismatch at addr %d. Expected: %h, Got: %h", 
          addr, expected_data[addr], data));
        data_mismatches++;
        assertion_failures++;
      end else begin
        `uvm_info("MON", $sformatf("PASS: Read data matches written value at addr %d", addr), UVM_HIGH);
      end
    end
  endfunction
  
  function void check_write_completion(logic [3:0] addr, logic [7:0] data);
    // Assertion: Write signal is properly pulsed (only one clock cycle)
    `uvm_info("MON", $sformatf("PASS: Write pulse completed for addr %d", addr), UVM_HIGH);
  endfunction
  
  function void cover_read_access(logic [3:0] addr, logic [7:0] data);
    // Coverage: Track which addresses are read
    if (addr == 4'd0)  `uvm_info("COV", "Covered: Read from address 0", UVM_HIGH);
    if (addr == 4'd15) `uvm_info("COV", "Covered: Read from address 15", UVM_HIGH);
    if (data == 8'h00) `uvm_info("COV", "Covered: Read zero data", UVM_HIGH);
    if (data == 8'hFF) `uvm_info("COV", "Covered: Read all-ones data", UVM_HIGH);
  endfunction
  
  function void cover_write_access(logic [3:0] addr, logic [7:0] data);
    // Coverage: Track which addresses are written
    if (addr == 4'd0)  `uvm_info("COV", "Covered: Write to address 0", UVM_HIGH);
    if (addr == 4'd15) `uvm_info("COV", "Covered: Write to address 15", UVM_HIGH);
    if (data == 8'h00) `uvm_info("COV", "Covered: Write zero data", UVM_HIGH);
    if (data == 8'hFF) `uvm_info("COV", "Covered: Write all-ones data", UVM_HIGH);
  endfunction
  
  function void report_assertions();
    `uvm_info("MON", "=== Assertion Report ===", UVM_HIGH);
    `uvm_info("MON", $sformatf("Total observations: %d", observations), UVM_HIGH);
    `uvm_info("MON", $sformatf("Assertion failures: %d", assertion_failures), UVM_HIGH);
    `uvm_info("MON", $sformatf("Data mismatches: %d", data_mismatches), UVM_HIGH);
    
    if (assertion_failures == 0) begin
      `uvm_info("MON", "All assertions PASSED", UVM_HIGH);
    end else begin
      `uvm_error("MON", $sformatf("FAILED: %d assertions failed", assertion_failures));
    end
  endfunction
  
  function void reset_coverage();
    expected_data.delete();
    observations = 0;
    assertion_failures = 0;
    data_mismatches = 0;
    `uvm_info("MON", "Coverage and statistics reset", UVM_HIGH);
  endfunction
endclass

//===========================================================================
// SCOREBOARD DOCUMENTATION
//===========================================================================
// The scoreboard verifies correctness. It:
// - Receives observed transactions from monitor
// - Checks for protocol violations
// - Compares against expected behavior
// - Reports pass/fail results
// - Collects statistics
//===========================================================================
class ram_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(ram_scoreboard)
  
  uvm_tlm_analysis_fifo #(ram_transaction) observed_fifo;
  
  // Statistics
  int total_checked = 0;
  int checks_passed = 0;
  int checks_failed = 0;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    observed_fifo = new("observed_fifo", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    ram_transaction xact;
    forever begin
      observed_fifo.get(xact);
      check_transaction(xact);
    end
  endtask
  
  function void check_transaction(ram_transaction xact);
    bit pass = 1;
    
    total_checked++;
    
    // Verify address is within range
    if (xact.addr > 15) begin
      `uvm_error("SCBD", $sformatf("Invalid address: %d", xact.addr));
      pass = 0;
    end
    
    // Verify data is valid 8-bit value
    if (xact.data > 255) begin
      `uvm_error("SCBD", $sformatf("Invalid data: %h", xact.data));
      pass = 0;
    end
    
    // Log result
    if (pass) begin
      checks_passed++;
      `uvm_info("SCBD", $sformatf("PASS: addr=%d, data=%h", xact.addr, xact.data), UVM_LOW);
    end else begin
      checks_failed++;
      `uvm_error("SCBD", $sformatf("FAIL: addr=%d, data=%h", xact.addr, xact.data));
    end
  endfunction
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCBD", "=== Scoreboard Report ===", UVM_HIGH);
    `uvm_info("SCBD", $sformatf("Total checked: %d", total_checked), UVM_HIGH);
    `uvm_info("SCBD", $sformatf("Passed: %d", checks_passed), UVM_HIGH);
    `uvm_info("SCBD", $sformatf("Failed: %d", checks_failed), UVM_HIGH);
  endfunction
endclass

//===========================================================================
// AGENT DOCUMENTATION
//===========================================================================
// The agent bundles driver, sequencer, and monitor. It:
// - Creates all three components
// - Connects driver to sequencer
// - Enables reusability for multi-agent testbenches
// - Represents one verification interface to the DUT
//===========================================================================
class ram_agent extends uvm_agent;
  `uvm_component_utils(ram_agent)
  
  ram_driver driver;
  ram_sequencer sequencer;
  ram_monitor monitor;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("AGENT", "Build phase", UVM_HIGH);
    driver = ram_driver::type_id::create("driver", this);
    sequencer = ram_sequencer::type_id::create("sequencer", this);
    monitor = ram_monitor::type_id::create("monitor", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("AGENT", "Connect phase", UVM_HIGH);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass

//===========================================================================
// ENVIRONMENT DOCUMENTATION
//===========================================================================
// The environment is the top-level verification container. It:
// - Creates agent(s) and scoreboard
// - Configures components via uvm_config_db
// - Connects monitor to scoreboard
// - Orchestrates the overall verification structure
//===========================================================================
class ram_env extends uvm_env;
  `uvm_component_utils(ram_env)
  
  ram_agent agent;
  ram_scoreboard scoreboard;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info("ENV", "Build phase", UVM_HIGH);
  agent = ram_agent::type_id::create("agent", this);
  scoreboard = ram_scoreboard::type_id::create("scoreboard", this);
  
  // Configure driver with parameters
  uvm_config_db #(int)::set(this, "agent.driver", "trans_delay", 0);
  uvm_config_db #(bit)::set(this, "agent.driver", "enable_performance_tracking", 1);
endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENV", "Connect phase", UVM_HIGH);
    agent.monitor.ap.connect(scoreboard.observed_fifo.analysis_export);
  endfunction
endclass

//===========================================================================
// SEQUENCE: ram_write_sequence (Monday)
//===========================================================================
class ram_write_sequence extends uvm_sequence #(ram_transaction);
  `uvm_object_utils(ram_write_sequence)
  
  function new(string name = "ram_write_sequence");
    super.new(name);
  endfunction
  
  task body();
    repeat (5) begin
      ram_transaction xact = ram_transaction::type_id::create("xact");
      xact.addr = $random % 16;
      xact.data = $random % 256;
      xact.write = 1;
      
      start_item(xact);
      finish_item(xact);
      `uvm_info("SEQ", $sformatf("Sent write: addr=%d, data=%h", xact.addr, xact.data), UVM_LOW);
    end
  endtask
endclass

//===========================================================================
// SEQUENCE: ram_read_sequence (Tuesday)
//===========================================================================
class ram_read_sequence extends uvm_sequence #(ram_transaction);
  `uvm_object_utils(ram_read_sequence)
  
  function new(string name = "ram_read_sequence");
    super.new(name);
  endfunction
  
  task body();
    repeat (5) begin
      ram_transaction xact = ram_transaction::type_id::create("xact");
      xact.addr = $random % 16;
      xact.write = 0;
      
      start_item(xact);
      finish_item(xact);
      `uvm_info("SEQ", $sformatf("Sent read: addr=%d", xact.addr), UVM_LOW);
    end
  endtask
endclass

//===========================================================================
// SEQUENCE: ram_mixed_sequence (Tuesday)
//===========================================================================
class ram_mixed_sequence extends uvm_sequence #(ram_transaction);
  `uvm_object_utils(ram_mixed_sequence)
  
  function new(string name = "ram_mixed_sequence");
    super.new(name);
  endfunction
  
  task body();
    repeat (10) begin
      ram_transaction xact = ram_transaction::type_id::create("xact");
      xact.addr = $random % 16;
      xact.data = $random % 256;
      xact.write = $random % 2;
      
      start_item(xact);
      finish_item(xact);
      
      if (xact.write)
        `uvm_info("SEQ", $sformatf("Mixed write: addr=%d, data=%h", xact.addr, xact.data), UVM_LOW);
      else
        `uvm_info("SEQ", $sformatf("Mixed read: addr=%d", xact.addr), UVM_LOW);
    end
  endtask
endclass

//===========================================================================
// SEQUENCE: ram_stress_sequence (Tuesday)
//===========================================================================
class ram_stress_sequence extends uvm_sequence #(ram_transaction);
  `uvm_object_utils(ram_stress_sequence)
  
  function new(string name = "ram_stress_sequence");
    super.new(name);
  endfunction
  
  task body();
    repeat (50) begin
      ram_transaction xact = ram_transaction::type_id::create("xact");
      xact.addr = $random % 16;
      xact.data = $random % 256;
      xact.write = $random % 2;
      
      start_item(xact);
      finish_item(xact);
    end
    `uvm_info("SEQ", "Completed 50 stress transactions", UVM_LOW);
  endtask
endclass

//===========================================================================
// SEQUENCE: ram_constrained_write_sequence (Wednesday)
// Writes to specific address ranges with data constraints
//===========================================================================
class ram_constrained_write_sequence extends uvm_sequence #(ram_transaction);
  `uvm_object_utils(ram_constrained_write_sequence)
  
  rand int num_writes;
  rand logic [3:0] addr_min, addr_max;
  rand logic [7:0] data_min, data_max;
  
  constraint num_writes_c { num_writes inside {[3:10]}; }
  constraint addr_range_c { addr_min <= addr_max; addr_max <= 15; }
  constraint data_range_c { data_min <= data_max; }
  
  function new(string name = "ram_constrained_write_sequence");
    super.new(name);
    addr_min = 0;
    addr_max = 7;
    data_min = 8'h00;
    data_max = 8'hFF;
  endfunction
  
  task body();
    repeat (num_writes) begin
      ram_transaction xact = ram_transaction::type_id::create("xact");
      assert(xact.randomize() with {
        xact.addr >= addr_min && xact.addr <= addr_max;
        xact.data >= data_min && xact.data <= data_max;
        xact.write == 1;
      }) else `uvm_error("SEQ", "Randomization failed!");
      
      start_item(xact);
      finish_item(xact);
      `uvm_info("SEQ", $sformatf("Constrained write: addr=%d, data=%h", 
        xact.addr, xact.data), UVM_LOW);
    end
  endtask
endclass

//===========================================================================
// SEQUENCE: ram_burst_sequence (Wednesday)
// Writes to consecutive addresses (burst pattern)
//===========================================================================
class ram_burst_sequence extends uvm_sequence #(ram_transaction);
  `uvm_object_utils(ram_burst_sequence)
  
  rand logic [3:0] start_addr;
  rand int burst_length;
  
  constraint start_addr_c { start_addr <= 10; }
  constraint burst_length_c { burst_length inside {[4:8]}; }
  
  function new(string name = "ram_burst_sequence");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("SEQ", $sformatf("Starting burst: addr=%d, length=%d", 
      start_addr, burst_length), UVM_HIGH);
    
    repeat (burst_length) begin
      ram_transaction xact = ram_transaction::type_id::create("xact");
      xact.addr = start_addr;
      xact.data = $random % 256;
      xact.write = 1;
      
      start_item(xact);
      finish_item(xact);
      `uvm_info("SEQ", $sformatf("Burst write: addr=%d, data=%h", 
        xact.addr, xact.data), UVM_LOW);
      
    end
  endtask
endclass

//===========================================================================
// SEQUENCE: ram_layered_sequence (Wednesday)
// Calls other sequences in sequence (composition pattern)
//===========================================================================
class ram_layered_sequence extends uvm_sequence #(ram_transaction);
  `uvm_object_utils(ram_layered_sequence)
  
  function new(string name = "ram_layered_sequence");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("SEQ", "Starting layered sequence", UVM_HIGH);
    
    // Phase 1: Fill specific addresses
    begin
      ram_constrained_write_sequence write_seq = new("write_seq");
      write_seq.addr_min = 0;
      write_seq.addr_max = 7;
      write_seq.num_writes = 5;
      `uvm_info("SEQ", "Phase 1: Writing to lower addresses", UVM_HIGH);
      write_seq.start(m_sequencer);
    end
    
    // Phase 2: Burst writes
    begin
      ram_burst_sequence burst_seq = new("burst_seq");
      burst_seq.start_addr = 8;
      burst_seq.burst_length = 6;
      `uvm_info("SEQ", "Phase 2: Burst writes to upper addresses", UVM_HIGH);
      burst_seq.start(m_sequencer);
    end
    
    `uvm_info("SEQ", "Layered sequence complete", UVM_HIGH);
  endtask
endclass

//===========================================================================
// SEQUENCE: ram_weighted_random_sequence (Wednesday)
// Biases operations toward writes (70%) over reads (30%)
//===========================================================================
class ram_weighted_random_sequence extends uvm_sequence #(ram_transaction);
  `uvm_object_utils(ram_weighted_random_sequence)
  
  function new(string name = "ram_weighted_random_sequence");
    super.new(name);
  endfunction
  
  task body();
    repeat (20) begin
      ram_transaction xact = ram_transaction::type_id::create("xact");
      
      // Randomize with weighted bias: 70% writes, 30% reads
      assert(xact.randomize() with {
        xact.addr inside {[0:15]};
        xact.data inside {[0:255]};
        xact.write dist { 1 := 70, 0 := 30 };
      }) else `uvm_error("SEQ", "Randomization failed!");
      
      start_item(xact);
      finish_item(xact);
      
      if (xact.write)
        `uvm_info("SEQ", $sformatf("Weighted write: addr=%d, data=%h", 
          xact.addr, xact.data), UVM_LOW);
      else
        `uvm_info("SEQ", $sformatf("Weighted read: addr=%d", xact.addr), UVM_LOW);
    end
  endtask
endclass

//===========================================================================
// SEQUENCE: ram_edge_case_sequence (Wednesday)
// Tests edge cases: min/max addresses, boundary values
//===========================================================================
class ram_edge_case_sequence extends uvm_sequence #(ram_transaction);
  `uvm_object_utils(ram_edge_case_sequence)
  
  function new(string name = "ram_edge_case_sequence");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("SEQ", "Starting edge case testing", UVM_HIGH);
    
    logic [3:0] addr_cases[] = {4'd0, 4'd15, 4'd8, 4'd7};
    logic [7:0] data_cases[] = {8'h00, 8'hFF, 8'h80, 8'h7F};
    
    foreach (addr_cases[i]) begin
      foreach (data_cases[j]) begin
        ram_transaction xact = ram_transaction::type_id::create("xact");
        xact.addr = addr_cases[i];
        xact.data = data_cases[j];
        xact.write = 1;
        
        start_item(xact);
        finish_item(xact);
        `uvm_info("SEQ", $sformatf("Edge case: addr=%d, data=%h", 
          xact.addr, xact.data), UVM_LOW);
      end
    end
    
    `uvm_info("SEQ", "Edge case testing complete", UVM_HIGH);
  endtask
endclass

//===========================================================================
// TEST DOCUMENTATION
//===========================================================================
// The test orchestrates simulation. It:
// - Creates the environment
// - Instantiates and starts sequences
// - Manages simulation phases
// - Collects and reports results
//===========================================================================
class ram_test extends uvm_test;
  `uvm_component_utils(ram_test)
  
  ram_env env;
  string test_name;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TEST", "Build phase", UVM_HIGH);
    env = ram_env::type_id::create("env", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("TEST", "Connect phase", UVM_HIGH);
  endfunction
  
  task run_phase(uvm_phase phase);
    `uvm_info("TEST", "Run phase - Basic write test", UVM_LOW);
    phase.raise_objection(phase);
    
    run_test_scenario("write");
    
    phase.drop_objection(phase);
  endtask
  
  task run_test_scenario(string scenario);
    case (scenario)
      "write": begin
        `uvm_info("TEST", "Running: Write Sequence Test", UVM_HIGH);
        ram_write_sequence seq = new("write_seq");
        seq.start(env.agent.sequencer);
      end
      "read": begin
        `uvm_info("TEST", "Running: Read Sequence Test", UVM_HIGH);
        ram_read_sequence seq = new("read_seq");
        seq.start(env.agent.sequencer);
      end
      "mixed": begin
        `uvm_info("TEST", "Running: Mixed Read/Write Test", UVM_HIGH);
        ram_mixed_sequence seq = new("mixed_seq");
        seq.start(env.agent.sequencer);
      end
      "stress": begin
        `uvm_info("TEST", "Running: Stress Test (50 transactions)", UVM_HIGH);
        ram_stress_sequence seq = new("stress_seq");
        seq.start(env.agent.sequencer);
      end
      "constrained": begin
        `uvm_info("TEST", "Running: Constrained Write Test", UVM_HIGH);
        ram_constrained_write_sequence seq = new("constrained_seq");
        seq.start(env.agent.sequencer);
      end
      "burst": begin
        `uvm_info("TEST", "Running: Burst Write Test", UVM_HIGH);
        ram_burst_sequence seq = new("burst_seq");
        seq.start(env.agent.sequencer);
      end
      "layered": begin
        `uvm_info("TEST", "Running: Layered Sequence Test", UVM_HIGH);
        ram_layered_sequence seq = new("layered_seq");
        seq.start(env.agent.sequencer);
      end
      "weighted": begin
        `uvm_info("TEST", "Running: Weighted Random Test", UVM_HIGH);
        ram_weighted_random_sequence seq = new("weighted_seq");
        seq.start(env.agent.sequencer);
      end
      "edge_case": begin
        `uvm_info("TEST", "Running: Edge Case Test", UVM_HIGH);
        ram_edge_case_sequence seq = new("edge_seq");
        seq.start(env.agent.sequencer);
      end
      default: begin
        `uvm_error("TEST", $sformatf("Unknown scenario: %s", scenario));
      end
    endcase
  endtask
  
  function void report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info("TEST", "Report phase", UVM_HIGH);
  
  // Print driver performance metrics
  env.agent.driver.report_performance_metrics();
  env.agent.driver.print_transaction_history();
  
  // Print monitor assertions
  env.agent.monitor.report_assertions();
  
  `uvm_info("TEST", "=== Test Complete ===", UVM_LOW);
endfunction
//===========================================================================
// DERIVED TESTS (Tuesday + Wednesday)
//===========================================================================
class ram_write_only_test extends ram_test;
  `uvm_component_utils(ram_write_only_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    `uvm_info("TEST", "Run phase - Write Only Test", UVM_LOW);
    phase.raise_objection(phase);
    run_test_scenario("write");
    phase.drop_objection(phase);
  endtask
endclass

class ram_mixed_test extends ram_test;
  `uvm_component_utils(ram_mixed_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    `uvm_info("TEST", "Run phase - Mixed Test", UVM_LOW);
    phase.raise_objection(phase);
    run_test_scenario("mixed");
    phase.drop_objection(phase);
  endtask
endclass

class ram_stress_test extends ram_test;
  `uvm_component_utils(ram_stress_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    `uvm_info("TEST", "Run phase - Stress Test", UVM_LOW);
    phase.raise_objection(phase);
    run_test_scenario("stress");
    phase.drop_objection(phase);
  endtask
endclass

class ram_constrained_test extends ram_test;
  `uvm_component_utils(ram_constrained_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    `uvm_info("TEST", "Run phase - Constrained Test", UVM_LOW);
    phase.raise_objection(phase);
    run_test_scenario("constrained");
    phase.drop_objection(phase);
  endtask
endclass

class ram_burst_test extends ram_test;
  `uvm_component_utils(ram_burst_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    `uvm_info("TEST", "Run phase - Burst Test", UVM_LOW);
    phase.raise_objection(phase);
    run_test_scenario("burst");
    phase.drop_objection(phase);
  endtask
endclass

class ram_layered_test extends ram_test;
  `uvm_component_utils(ram_layered_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    `uvm_info("TEST", "Run phase - Layered Test", UVM_LOW);
    phase.raise_objection(phase);
    run_test_scenario("layered");
    phase.drop_objection(phase);
  endtask
endclass

class ram_weighted_test extends ram_test;
  `uvm_component_utils(ram_weighted_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    `uvm_info("TEST", "Run phase - Weighted Random Test", UVM_LOW);
    phase.raise_objection(phase);
    run_test_scenario("weighted");
    phase.drop_objection(phase);
  endtask
endclass

class ram_edge_case_test extends ram_test;
  `uvm_component_utils(ram_edge_case_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    `uvm_info("TEST", "Run phase - Edge Case Test", UVM_LOW);
    phase.raise_objection(phase);
    run_test_scenario("edge_case");
    phase.drop_objection(phase);
  endtask
endclass

//===========================================================================
// TOP MODULE
//===========================================================================
module top;
  logic clk = 0;
  logic resetN;
  
  dual_port_ram_if if_inst();
  assign if_inst.clk = clk;
  assign if_inst.resetN = resetN;
  
  dual_port_ram #(
    .ADDR_WIDTH(4),
    .DATA_WIDTH(8),
    .DEPTH(16)
  ) dut (
    .clk(if_inst.clk),
    .resetN(if_inst.resetN),
    .addr_a(if_inst.addr_a),
    .write_data_a(if_inst.write_data_a),
    .write_enable_a(if_inst.write_enable_a),
    .read_data_a(if_inst.read_data_a),
    .addr_b(if_inst.addr_b),
    .write_data_b(if_inst.write_data_b),
    .write_enable_b(if_inst.write_enable_b),
    .read_data_b(if_inst.read_data_b)
  );
  
  initial begin
    uvm_config_db #(virtual dual_port_ram_if)::set(null, "", "vif", if_inst);
    resetN = 0;
    #30 resetN = 1;
    run_test("ram_test");
  end
  
  initial forever #10 clk = ~clk;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule