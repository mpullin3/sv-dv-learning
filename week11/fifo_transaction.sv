//============================================================================
// FIFO BASE TRANSACTION
// Foundation for all FIFO transactions
//============================================================================

class fifo_transaction extends uvm_sequence_item;
  `uvm_object_utils(fifo_transaction)
  
  // Base fields applicable to both read and write
  int delay_cycles;  // Cycles to wait before operation
  
  constraint delay_c {
    delay_cycles inside {[0:5]};  // 0-5 cycle delay
  }
  
  function new(string name = "fifo_transaction");
    super.new(name);
    delay_cycles = 0;
  endfunction
  
  function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field("delay_cycles", delay_cycles, 32);
  endfunction

endclass