//============================================================================
// FIFO STRESS TEST
// Test scenario: High volume random operations
//============================================================================

class fifo_stress_sequence extends uvm_sequence #(fifo_transaction);
  `uvm_object_utils(fifo_stress_sequence)
  
  int num_operations = 100;
  
  function new(string name = "fifo_stress_sequence");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("SEQ", $sformatf("Stress sequence: %d operations", num_operations), UVM_HIGH);
    
    repeat (num_operations) begin
      if ($random % 2 == 0) begin
        fifo_write_transaction wtxn;
        wtxn = fifo_write_transaction::type_id::create("wtxn");
        
        assert(wtxn.randomize()) else
          `uvm_error("SEQ", "Write randomization failed");
        
        start_item(wtxn);
        finish_item(wtxn);
      end else begin
        fifo_read_transaction rtxn;
        rtxn = fifo_read_transaction::type_id::create("rtxn");
        
        assert(rtxn.randomize()) else
          `uvm_error("SEQ", "Read randomization failed");
        
        start_item(rtxn);
        finish_item(rtxn);
      end
    end
    
    `uvm_info("SEQ", "Stress sequence complete", UVM_HIGH);
  endtask
endclass

class fifo_stress_test extends fifo_test_base;
  `uvm_component_utils(fifo_stress_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  task run_test_sequence(uvm_phase phase);
    fifo_stress_sequence seq;
    
    seq = fifo_stress_sequence::type_id::create("seq");
    seq.num_operations = 500;  // High volume
    
    `uvm_info("TEST", "Running stress test (500 ops)", UVM_HIGH);
    seq.start(env.agent.sequencer);
  endtask
endclass