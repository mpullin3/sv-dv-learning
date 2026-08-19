//============================================================================
// FIFO FULL DRAIN TEST
// Test scenario: Fill FIFO completely, then drain it
//============================================================================

class fifo_full_drain_sequence extends uvm_sequence #(fifo_transaction);
  `uvm_object_utils(fifo_full_drain_sequence)
  
  function new(string name = "fifo_full_drain_sequence");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("SEQ", "Full-drain sequence: Fill 16, drain 16", UVM_HIGH);
    
    // Phase 1: Fill FIFO completely
    `uvm_info("SEQ", "Phase 1: Filling FIFO (16 writes)", UVM_HIGH);
    repeat (16) begin
      fifo_write_transaction wtxn;
      wtxn = fifo_write_transaction::type_id::create("wtxn");
      
      assert(wtxn.randomize()) else
        `uvm_error("SEQ", "Write randomization failed");
      
      start_item(wtxn);
      finish_item(wtxn);
    end
    
    // Phase 2: Drain FIFO completely
    `uvm_info("SEQ", "Phase 2: Draining FIFO (16 reads)", UVM_HIGH);
    repeat (16) begin
      fifo_read_transaction rtxn;
      rtxn = fifo_read_transaction::type_id::create("rtxn");
      
      assert(rtxn.randomize()) else
        `uvm_error("SEQ", "Read randomization failed");
      
      start_item(rtxn);
      finish_item(rtxn);
    end
    
    `uvm_info("SEQ", "Full-drain sequence complete", UVM_HIGH);
  endtask
endclass

class fifo_full_drain_test extends fifo_test_base;
  `uvm_component_utils(fifo_full_drain_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  task run_test_sequence(uvm_phase phase);
    fifo_full_drain_sequence seq;
    
    seq = fifo_full_drain_sequence::type_id::create("seq");
    
    `uvm_info("TEST", "Running full drain test", UVM_HIGH);
    seq.start(env.agent.sequencer);
  endtask
endclass