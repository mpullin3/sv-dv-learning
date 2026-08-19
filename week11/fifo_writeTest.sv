//============================================================================
// FIFO WRITE TEST
// Test scenario: Fill FIFO with sequential writes
//============================================================================

class fifo_write_sequence extends uvm_sequence #(fifo_transaction);
  `uvm_object_utils(fifo_write_sequence)
  
  int num_writes = 10;
  
  function new(string name = "fifo_write_sequence");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("SEQ", $sformatf("Write sequence: %d writes", num_writes), UVM_HIGH);
    
    repeat (num_writes) begin
      fifo_write_transaction wtxn;
      wtxn = fifo_write_transaction::type_id::create("wtxn");
      
      assert(wtxn.randomize()) else
        `uvm_error("SEQ", "Write randomization failed");
      
      start_item(wtxn);
      `uvm_info("SEQ", $sformatf("Sending: %s", wtxn.convert2string()), UVM_LOW);
      finish_item(wtxn);
    end
    
    `uvm_info("SEQ", "Write sequence complete", UVM_HIGH);
  endtask
endclass

class fifo_write_test extends fifo_test_base;
  `uvm_component_utils(fifo_write_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  task run_test_sequence(uvm_phase phase);
    fifo_write_sequence seq;
    
    seq = fifo_write_sequence::type_id::create("seq");
    seq.num_writes = 16;  // Fill FIFO
    
    `uvm_info("TEST", "Running write test (fill FIFO)", UVM_HIGH);
    seq.start(env.agent.sequencer);
  endtask
endclass