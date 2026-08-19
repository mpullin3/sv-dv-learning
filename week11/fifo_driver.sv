//============================================================================
// FIFO DRIVER (ENHANCED)
// Applies transactions to DUT interface with improved error handling
//============================================================================

class fifo_driver extends uvm_driver #(fifo_transaction);
  `uvm_component_utils(fifo_driver)
  
  virtual fifo_if vif;  // Virtual interface
  
  // Statistics
  int write_count = 0;
  int read_count = 0;
  int blocked_writes = 0;  // Attempts to write when full
  int blocked_reads = 0;   // Attempts to read when empty
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    `uvm_info("DRV", "Driver build_phase", UVM_HIGH);
    
    // Get virtual interface from config database
    if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("DRV", "Virtual interface 'vif' not found in config_db!");
    end
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("DRV", "Driver connect_phase", UVM_HIGH);
  endfunction
  
  task run_phase(uvm_phase phase);
    `uvm_info("DRV", "Driver run_phase started", UVM_HIGH);
    
    // Initialize interface signals
    vif.cb.write_en <= 0;
    vif.cb.read_en <= 0;
    
    // Main loop: Get transactions from sequencer and apply them
    forever begin
      fifo_transaction txn;
      
      // Get next transaction from sequencer
      seq_item_port.get_next_item(txn);
      
      `uvm_info("DRV", $sformatf("Got transaction: %s", txn.convert2string()), UVM_HIGH);
      
      // Apply the transaction
      apply_transaction(txn);
      
      // Tell sequencer we're done with this transaction
      seq_item_port.item_done();
    end
  endtask
  
  task apply_transaction(fifo_transaction txn);
    
    // Dispatch based on transaction type
    if ($cast(fifo_write_transaction, txn)) begin
      apply_write_transaction(fifo_write_transaction'(txn));
    end
    else if ($cast(fifo_read_transaction, txn)) begin
      apply_read_transaction(fifo_read_transaction'(txn));
    end
    else begin
      `uvm_warning("DRV", "Unknown transaction type!");
    end
  endtask
  
  task apply_write_transaction(fifo_write_transaction wtxn);
    int wait_cycles = 0;
    
    `uvm_info("DRV", $sformatf("Applying WRITE: data=%h, delay=%d", 
      wtxn.write_data, wtxn.delay_cycles), UVM_LOW);
    
    // Wait for initial delay
    repeat (wtxn.delay_cycles) @(vif.cb);
    
    // Wait until FIFO is not full
    while (vif.cb.full) begin
      blocked_writes++;
      `uvm_info("DRV", $sformatf("FIFO full, waiting... (attempt %d)", blocked_writes), UVM_HIGH);
      @(vif.cb);
      wait_cycles++;
    end
    
    // Apply write for one cycle
    vif.cb.write_en <= 1;
    vif.cb.write_data <= wtxn.write_data;
    @(vif.cb);
    
    // Deassert write
    vif.cb.write_en <= 0;
    
    write_count++;
    `uvm_info("DRV", $sformatf("WRITE #%d complete: data=%h (waited %d cycles)", 
      write_count, wtxn.write_data, wait_cycles), UVM_LOW);
  endtask
  
  task apply_read_transaction(fifo_read_transaction rtxn);
    int wait_cycles = 0;
    
    `uvm_info("DRV", $sformatf("Applying READ: delay=%d", rtxn.delay_cycles), UVM_LOW);
    
    // Wait for initial delay
    repeat (rtxn.delay_cycles) @(vif.cb);
    
    // Wait until FIFO is not empty
    while (vif.cb.empty) begin
      blocked_reads++;
      `uvm_info("DRV", $sformatf("FIFO empty, waiting... (attempt %d)", blocked_reads), UVM_HIGH);
      @(vif.cb);
      wait_cycles++;
    end
    
    // Apply read for one cycle
    vif.cb.read_en <= 1;
    @(vif.cb);
    
    // Capture read data and deassert read
    rtxn.read_data = vif.cb.read_data;
    rtxn.data_valid = 1;
    vif.cb.read_en <= 0;
    
    read_count++;
    `uvm_info("DRV", $sformatf("READ #%d complete: data=%h (waited %d cycles)", 
      read_count, rtxn.read_data, wait_cycles), UVM_LOW);
  endtask
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info("DRV", "=== DRIVER REPORT ===", UVM_HIGH);
    `uvm_info("DRV", $sformatf("Writes applied: %d", write_count), UVM_HIGH);
    `uvm_info("DRV", $sformatf("Reads applied: %d", read_count), UVM_HIGH);
    `uvm_info("DRV", $sformatf("Write attempts blocked by full: %d", blocked_writes), UVM_HIGH);
    `uvm_info("DRV", $sformatf("Read attempts blocked by empty: %d", blocked_reads), UVM_HIGH);
  endfunction

endclass