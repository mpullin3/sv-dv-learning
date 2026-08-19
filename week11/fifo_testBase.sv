//============================================================================
// FIFO BASE TEST
// Foundation for all FIFO test scenarios
//============================================================================

class fifo_test_base extends uvm_test;
  `uvm_component_utils(fifo_test_base)
  
  fifo_env env;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    `uvm_info("TEST", "Test build_phase", UVM_HIGH);
    
    // Create environment
    env = fifo_env::type_id::create("env", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("TEST", "Test connect_phase", UVM_HIGH);
  endfunction
  
  task run_phase(uvm_phase phase);
    `uvm_info("TEST", "Test run_phase started", UVM_HIGH);
    
    phase.raise_objection(this);
    
    // Subclass will implement specific sequences here
    run_test_sequence(phase);
    
    phase.drop_objection(this);
  endtask
  
  task run_test_sequence(uvm_phase phase);
    // Override in derived classes
    `uvm_info("TEST", "Base test - no sequence", UVM_HIGH);
  endtask
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("TEST", "=== TEST COMPLETE ===", UVM_HIGH);
  endfunction

endclass