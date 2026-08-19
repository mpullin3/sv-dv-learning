//============================================================================
// FIFO SCOREBOARD
// Verifies FIFO correctness
//============================================================================

class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)
  
  // Internal FIFO queue to model expected behavior
  logic [7:0] expected_fifo[$];
  
  // Analysis FIFOs to receive observations
  uvm_tlm_analysis_fifo #(fifo_write_transaction) write_fifo;
  uvm_tlm_analysis_fifo #(fifo_read_transaction) read_fifo;
  
  // Statistics
  int write_count = 0;
  int read_count = 0;
  int mismatch_count = 0;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    `uvm_info("SCBD", "Building scoreboard", UVM_HIGH);
    
    // Create analysis FIFOs
    write_fifo = new("write_fifo", this);
    read_fifo = new("read_fifo", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    fifo_write_transaction wtxn;
    fifo_read_transaction rtxn;
    
    `uvm_info("SCBD", "Scoreboard run_phase started", UVM_HIGH);
    
    fork
      // Process writes
      forever begin
        write_fifo.get(wtxn);
        expected_fifo.push_back(wtxn.write_data);
        write_count++;
        `uvm_info("SCBD", $sformatf("Write %d: data=%h (queue depth=%d)", 
          write_count, wtxn.write_data, expected_fifo.size()), UVM_LOW);
      end
      
      // Process reads
      forever begin
        read_fifo.get(rtxn);
        read_count++;
        
        if (expected_fifo.size() == 0) begin
          `uvm_error("SCBD", "Read from empty FIFO!");
          mismatch_count++;
        end else begin
          logic [7:0] expected = expected_fifo.pop_front();
          `uvm_info("SCBD", $sformatf("Read %d: expected=%h (queue depth=%d)", 
            read_count, expected, expected_fifo.size()), UVM_LOW);
        end
      end
    join_none
  endtask
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info("SCBD", "=== SCOREBOARD REPORT ===", UVM_HIGH);
    `uvm_info("SCBD", $sformatf("Writes: %d", write_count), UVM_HIGH);
    `uvm_info("SCBD", $sformatf("Reads: %d", read_count), UVM_HIGH);
    `uvm_info("SCBD", $sformatf("Mismatches: %d", mismatch_count), UVM_HIGH);
    
    if (mismatch_count == 0)
      `uvm_info("SCBD", "PASSED: All operations verified", UVM_HIGH);
    else
      `uvm_error("SCBD", $sformatf("FAILED: %d mismatches detected", mismatch_count));
  endfunction

endclass