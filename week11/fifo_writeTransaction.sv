//============================================================================
// FIFO WRITE TRANSACTION
// Represents a write operation to FIFO
//============================================================================

class fifo_write_transaction extends fifo_transaction;
  `uvm_object_utils(fifo_write_transaction)
  
  rand logic [7:0] write_data;  // Data to write
  
  // Constraint: Data can be any 8-bit value
  constraint write_data_c {
    write_data inside {[0:255]};
  }
  
  function new(string name = "fifo_write_transaction");
    super.new(name);
  endfunction
  
  function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field("write_data", write_data, 8);
    printer.print_field("delay_cycles", delay_cycles, 32);
  endfunction
  
  function string convert2string();
    return $sformatf("WRITE: data=%h, delay=%d", write_data, delay_cycles);
  endfunction

endclass