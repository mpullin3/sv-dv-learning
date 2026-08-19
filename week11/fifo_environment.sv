//============================================================================
// FIFO ENVIRONMENT
// Top-level verification container
//============================================================================

class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)
  
  fifo_agent agent;
  fifo_scoreboard scoreboard;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    `uvm_info("ENV", "Building environment", UVM_HIGH);
    
    // Create agent and scoreboard
    agent = fifo_agent::type_id::create("agent", this);
    scoreboard = fifo_scoreboard::type_id::create("scoreboard", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    `uvm_info("ENV", "Connecting monitor to scoreboard", UVM_HIGH);
    
    // Connect monitor analysis ports to scoreboard
    agent.monitor.write_ap.connect(scoreboard.write_fifo.analysis_export);
    agent.monitor.read_ap.connect(scoreboard.read_fifo.analysis_export);
  endfunction
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info("ENV", "=== ENVIRONMENT REPORT ===", UVM_HIGH);
    `uvm_info("ENV", "All components report generated", UVM_HIGH);
    
    // Print overall statistics
    `uvm_info("ENV", $sformatf("Total writes: %d", agent.driver.write_count), UVM_HIGH);
    `uvm_info("ENV", $sformatf("Total reads: %d", agent.driver.read_count), UVM_HIGH);
    `uvm_info("ENV", $sformatf("Scoreboard mismatches: %d", scoreboard.mismatch_count), UVM_HIGH);
  endfunction

endclass