//============================================================================
// FIFO MONITOR (ENHANCED)
// Observes FIFO interface, broadcasts observations, and samples coverage
//============================================================================

class fifo_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_monitor)
  
  virtual fifo_if vif;
  
  // Analysis ports for broadcasting observations
  uvm_analysis_port #(fifo_write_transaction) write_ap;
  uvm_analysis_port #(fifo_read_transaction) read_ap;
  
  // Coverage groups
  covergroup write_cov;
    write_addr: coverpoint current_wr_ptr {
      bins addr_low = {[0:7]};
      bins addr_high = {[8:15]};
      bins addr_min = {0};
      bins addr_max = {15};
    }
    write_data: coverpoint current_write_data {
      bins data_zeros = {8'h00};
      bins data_ones = {8'hFF};
      bins data_low = {[0:127]};
      bins data_high = {[128:255]};
    }
  endgroup
  
  covergroup read_cov;
    read_addr: coverpoint current_rd_ptr {
      bins addr_low = {[0:7]};
      bins addr_high = {[8:15]};
      bins addr_min = {0};
      bins addr_max = {15};
    }
    read_data: coverpoint current_read_data {
      bins data_zeros = {8'h00};
      bins data_ones = {8'hFF};
      bins data_low = {[0:127]};
      bins data_high = {[128:255]};
    }
  endgroup
  
  covergroup flag_cov;
    full_flag: coverpoint is_full {
      bins full_asserts = {1};
      bins full_deasserts = {0};
    }
    empty_flag: coverpoint is_empty {
      bins empty_asserts = {1};
      bins empty_deasserts = {0};
    }
    both_flags: cross full_flag, empty_flag {
      illegal_bins impossible = binsof(full_flag) intersect {1} && binsof(empty_flag) intersect {1};
    }
  endgroup
  
  covergroup occupancy_cov;
    occupancy_level: coverpoint current_occupancy {
      bins empty = {0};
      bins quarter = {[1:4]};
      bins half = {[5:8]};
      bins three_quarter = {[9:12]};
      bins almost_full = {[13:15]};
      bins full = {16};
    }
  endgroup
  
  covergroup operation_cov;
    write_operation: coverpoint write_occurs {
      bins write_happens = {1};
      bins no_write = {0};
    }
    read_operation: coverpoint read_occurs {
      bins read_happens = {1};
      bins no_read = {0};
    }
    concurrent: cross write_operation, read_operation;
  endgroup
  
  // Internal state tracking for coverage
  logic [3:0] current_wr_ptr = 0;
  logic [3:0] current_rd_ptr = 0;
  logic [7:0] current_write_data = 0;
  logic [7:0] current_read_data = 0;
  logic [4:0] current_occupancy = 0;
  logic is_full = 0;
  logic is_empty = 1;
  logic write_occurs = 0;
  logic read_occurs = 0;
  
  // Statistics
  int write_count = 0;
  int read_count = 0;
  int write_when_full = 0;
  int read_when_empty = 0;
  int concurrent_rw = 0;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    write_cov = new();
    read_cov = new();
    flag_cov = new();
    occupancy_cov = new();
    operation_cov = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    `uvm_info("MON", "Monitor build_phase", UVM_HIGH);
    
    // Create analysis ports
    write_ap = new("write_ap", this);
    read_ap = new("read_ap", this);
    
    // Get virtual interface from config database
    if (!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MON", "Virtual interface 'vif' not found in config_db!");
    end
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("MON", "Monitor connect_phase", UVM_HIGH);
  endfunction
  
  task run_phase(uvm_phase phase);
    `uvm_info("MON", "Monitor run_phase started", UVM_HIGH);
    
    forever begin
      @(posedge vif.clk);
      
      // Capture interface state
      capture_interface_state();
      
      // Sample coverage
      sample_coverage();
      
      // Monitor write operations
      if (vif.write_en && !vif.full) begin
        monitor_write();
      end
      
      // Monitor read operations
      if (vif.read_en && !vif.empty) begin
        monitor_read();
      end
      
      // Monitor concurrent operations
      if ((vif.write_en && !vif.full) && (vif.read_en && !vif.empty)) begin
        concurrent_rw++;
        `uvm_info("MON", "Concurrent read/write observed", UVM_HIGH);
      end
      
      // Log status periodically
      if (write_count % 10 == 0 && write_count > 0) begin
        `uvm_info("MON", $sformatf("Status: empty=%b, full=%b, occupancy=%d", 
          vif.empty, vif.full, vif.occupancy), UVM_HIGH);
      end
    end
  endtask
  
  task capture_interface_state();
    current_write_data = vif.write_data;
    current_read_data = vif.read_data;
    current_occupancy = vif.occupancy;
    is_full = vif.full;
    is_empty = vif.empty;
    write_occurs = vif.write_en && !vif.full;
    read_occurs = vif.read_en && !vif.empty;
  endtask
  
  task sample_coverage();
    write_cov.sample();
    read_cov.sample();
    flag_cov.sample();
    occupancy_cov.sample();
    operation_cov.sample();
  endtask
  
  task monitor_write();
    fifo_write_transaction wtxn;
    wtxn = fifo_write_transaction::type_id::create("wtxn");
    wtxn.write_data = vif.write_data;
    wtxn.delay_cycles = 0;
    
    write_ap.write(wtxn);
    write_count++;
    
    `uvm_info("MON", $sformatf("WRITE #%d: data=%h, occupancy=%d", 
      write_count, vif.write_data, vif.occupancy), UVM_LOW);
  endtask
  
  task monitor_read();
    fifo_read_transaction rtxn;
    rtxn = fifo_read_transaction::type_id::create("rtxn");
    rtxn.read_data = vif.read_data;
    rtxn.data_valid = 1;
    rtxn.delay_cycles = 0;
    
    read_ap.write(rtxn);
    read_count++;
    
    `uvm_info("MON", $sformatf("READ #%d: data=%h, occupancy=%d", 
      read_count, vif.read_data, vif.occupancy), UVM_LOW);
  endtask
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info("MON", "=== MONITOR REPORT ===", UVM_HIGH);
    `uvm_info("MON", $sformatf("Writes observed: %d", write_count), UVM_HIGH);
    `uvm_info("MON", $sformatf("Reads observed: %d", read_count), UVM_HIGH);
    `uvm_info("MON", $sformatf("Concurrent r/w: %d", concurrent_rw), UVM_HIGH);
    
    `uvm_info("MON", "=== COVERAGE SUMMARY ===", UVM_HIGH);
    `uvm_info("MON", $sformatf("Write coverage: %.1f%%", write_cov.get_coverage()), UVM_HIGH);
    `uvm_info("MON", $sformatf("Read coverage: %.1f%%", read_cov.get_coverage()), UVM_HIGH);
    `uvm_info("MON", $sformatf("Flag coverage: %.1f%%", flag_cov.get_coverage()), UVM_HIGH);
    `uvm_info("MON", $sformatf("Occupancy coverage: %.1f%%", occupancy_cov.get_coverage()), UVM_HIGH);
    `uvm_info("MON", $sformatf("Operation coverage: %.1f%%", operation_cov.get_coverage()), UVM_HIGH);
  endfunction

endclass