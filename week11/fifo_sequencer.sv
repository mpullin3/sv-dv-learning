//============================================================================
// FIFO SEQUENCER
// Mediates between sequences and driver
//============================================================================

class fifo_sequencer extends uvm_sequencer #(fifo_transaction);
  `uvm_component_utils(fifo_sequencer)
  
  // Statistics
  int items_generated = 0;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SEQ", "Sequencer build_phase", UVM_HIGH);
  endfunction
  
  // Note: Sequencer doesn't need run_phase
  // UVM automatically handles the handshake between sequence and driver
  // through seq_item_port and seq_item_export
  
endclass