//============================================================================
// FIFO READ TEST
// Test scenario: Read from FIFO
//============================================================================

class fifo_read_sequence extends uvm_sequence #(fifo_transaction);
  `uvm_object_utils(fifo_read_sequence)
  
  int num_reads = 10;
  
  function new(string name = "fifo_read_sequence");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("SEQ", $sformatf("Read sequence: %d reads", num_reads), UVM_HIGH);
    
    repeat (num_reads) begin
      fifo_read_transaction rtxn;
      rtxn = fifo_read_transaction::type_id::create("rtxn");
      
      assert(rtxn.randomize()) else
        `uvm_error("SEQ", "Read randomization failed");
      
      start_item(rtxn);
      `uvm_info("SEQ", $sformatf("Sending: %s", rtxn.convert2string()), UVM_LOW);
      finish_item(rtxn);
    end
    
    `uvm_info("SEQ", "Read sequence complete", UVM_HIGH);
  endtask
endclass

class fifo_read_test extends fifo_test_base;
  `uvm_component_utils(fifo_read_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  task run_test_sequence(uvm_phase phase);
    fifo_read_sequence seq;
    
    seq = fifo_read_sequence::type_id::create("seq");
    seq.num_reads = 8;  // Drain some entries
    
    `uvm_info("TEST", "Running read test (drain FIFO)", UVM_HIGH);
    seq.start(env.agent.sequencer);
  endtask
endclass