//============================================================================
// FIFO MIXED TEST
// Test scenario: Concurrent read/write operations
//============================================================================

class fifo_mixed_sequence extends uvm_sequence #(fifo_transaction);
  `uvm_object_utils(fifo_mixed_sequence)
  
  int num_operations = 20;
  
  function new(string name = "fifo_mixed_sequence");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("SEQ", $sformatf("Mixed sequence: %d operations", num_operations), UVM_HIGH);
    
    repeat (num_operations) begin
      fifo_transaction txn;
      
      if ($random % 2 == 0) begin
        fifo_write_transaction wtxn;
        wtxn = fifo_write_transaction::type_id::create("wtxn");
        
        assert(wtxn.randomize()) else
          `uvm_error("SEQ", "Write randomization failed");
        
        start_item(wtxn);
        `uvm_info("SEQ", "Sending: WRITE", UVM_LOW);
        finish_item(wtxn);
      end else begin
        fifo_read_transaction rtxn;
        rtxn = fifo_read_transaction::type_id::create("rtxn");
        
        assert(rtxn.randomize()) else
          `uvm_error("SEQ", "Read randomization failed");
        
        start_item(rtxn);
        `uvm_info("SEQ", "Sending: READ", UVM_LOW);
        finish_item(rtxn);
      end
    end
    
    `uvm_info("SEQ", "Mixed sequence complete", UVM_HIGH);
  endtask
endclass

class fifo_mixed_test extends fifo_test_base;
  `uvm_component_utils(fifo_mixed_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  task run_test_sequence(uvm_phase phase);
    fifo_mixed_sequence seq;
    
    seq = fifo_mixed_sequence::type_id::create("seq");
    seq.num_operations = 32;  // Random mix
    
    `uvm_info("TEST", "Running mixed test (r/w concurrent)", UVM_HIGH);
    seq.start(env.agent.sequencer);
  endtask
endclass