//============================================================================
// FIFO AGENT
// Bundles driver, sequencer, and monitor
//============================================================================

class fifo_agent extends uvm_agent;
  `uvm_component_utils(fifo_agent)
  
  fifo_driver driver;
  fifo_sequencer sequencer;
  fifo_monitor monitor;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    `uvm_info("AGENT", "Building agent components", UVM_HIGH);
    
    // Create components
    driver = fifo_driver::type_id::create("driver", this);
    sequencer = fifo_sequencer::type_id::create("sequencer", this);
    monitor = fifo_monitor::type_id::create("monitor", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    `uvm_info("AGENT", "Connecting driver to sequencer", UVM_HIGH);
    
    // Connect driver to sequencer
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass