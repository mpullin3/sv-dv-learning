//============================================================================
// FIFO CONFIGURATION
// Stores testbench configuration settings
//============================================================================

class fifo_config extends uvm_object;
  `uvm_object_utils(fifo_config)
  
  // Interface instance
  virtual fifo_if fifo_vif;
  
  // FIFO parameters
  int fifo_depth = 16;
  int data_width = 8;
  
  // Test parameters
  int num_transactions = 10;
  int test_timeout_cycles = 10000;
  
  function new(string name = "fifo_config");
    super.new(name);
  endfunction
  
  function void display();
    `uvm_info("CFG", "=== FIFO Configuration ===", UVM_HIGH);
    `uvm_info("CFG", $sformatf("FIFO Depth: %d", fifo_depth), UVM_HIGH);
    `uvm_info("CFG", $sformatf("Data Width: %d", data_width), UVM_HIGH);
    `uvm_info("CFG", $sformatf("Num Transactions: %d", num_transactions), UVM_HIGH);
  endfunction

endclass