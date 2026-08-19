//============================================================================
// FIFO READ TRANSACTION
// Represents a read operation from FIFO
//============================================================================

class fifo_read_transaction extends fifo_transaction;
  `uvm_object_utils(fifo_read_transaction)
  
  logic [7:0] read_data;      // Data read from FIFO
  logic data_valid;            // Whether read_data is valid
  
  function new(string name = "fifo_read_transaction");
    super.new(name);
    data_valid = 0;
    read_data = 0;
  endfunction
  
  function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field("read_data", read_data, 8);
    printer.print_field("data_valid", data_valid, 1);
    printer.print_field("delay_cycles", delay_cycles, 32);
  endfunction
  
  function string convert2string();
    return $sformatf("READ: data=%h, valid=%b, delay=%d", read_data, data_valid, delay_cycles);
  endfunction

endclass