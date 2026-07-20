import uvm_pkg::*;
`include "uvm_macros.svh"

//============================================================================
// INTERFACE: dual_port_ram_if
//============================================================================
interface dual_port_ram_if;
  logic clk;
  logic resetN;
  
  logic [3:0] addr_a;
  logic [7:0] write_data_a;
  logic write_enable_a;
  logic [7:0] read_data_a;
  
  logic [3:0] addr_b;
  logic [7:0] write_data_b;
  logic write_enable_b;
  logic [7:0] read_data_b;
  
  clocking cb @(posedge clk);
    output addr_a, write_data_a, write_enable_a;
    output addr_b, write_data_b, write_enable_b;
    input read_data_a, read_data_b;
  endclocking
endinterface

//============================================================================
// TRANSACTION: ram_transaction
//============================================================================
class ram_transaction extends uvm_sequence_item;
  `uvm_object_utils(ram_transaction)
  
  logic [3:0] addr;
  logic [7:0] data;
  logic write;
  
  function new(string name = "ram_transaction");
    super.new(name);
  endfunction
endclass

//============================================================================
// SEQUENCER: ram_sequencer
//============================================================================
class ram_sequencer extends uvm_sequencer #(ram_transaction);
  `uvm_component_utils(ram_sequencer)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass

//============================================================================
// DRIVER: ram_driver
//============================================================================
class ram_driver extends uvm_driver #(ram_transaction);
  `uvm_component_utils(ram_driver)
  
  virtual dual_port_ram_if vif;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual dual_port_ram_if)::get(this, "", "vif", vif))
      `uvm_error("DRV", "Virtual interface not found!");
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      ram_transaction xact;
      seq_item_port.get_next_item(xact);
      
      vif.addr_a = xact.addr;
      vif.write_data_a = xact.data;
      vif.write_enable_a = xact.write;
      
      @(posedge vif.clk);
      vif.write_enable_a = 0;
      
      seq_item_port.item_done();
      `uvm_info("DRV", $sformatf("Drove: addr=%d, data=%h", xact.addr, xact.data), UVM_LOW);
    end
  endtask
endclass

//============================================================================
// MONITOR: ram_monitor
//============================================================================
class ram_monitor extends uvm_monitor;
  `uvm_component_utils(ram_monitor)
  
  virtual dual_port_ram_if vif;
  uvm_analysis_port #(ram_transaction) ap;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db #(virtual dual_port_ram_if)::get(this, "", "vif", vif))
      `uvm_error("MON", "Virtual interface not found!");
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      if (vif.write_enable_b == 0) begin
        ram_transaction xact = ram_transaction::type_id::create("xact");
        xact.addr = vif.addr_b;
        xact.data = vif.read_data_b;
        xact.write = 0;
        ap.write(xact);
        `uvm_info("MON", $sformatf("Observed read: addr=%d, data=%h", xact.addr, xact.data), UVM_LOW);
      end
    end
  endtask
endclass

//============================================================================
// SCOREBOARD: ram_scoreboard
//============================================================================
class ram_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(ram_scoreboard)
  
  uvm_tlm_analysis_fifo #(ram_transaction) observed_fifo;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    observed_fifo = new("observed_fifo", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    ram_transaction xact;
    forever begin
      observed_fifo.get(xact);
      `uvm_info("SCBD", $sformatf("Checked: addr=%d, data=%h", xact.addr, xact.data), UVM_LOW);
    end
  endtask
endclass

//============================================================================
// AGENT: ram_agent
//============================================================================
class ram_agent extends uvm_agent;
  `uvm_component_utils(ram_agent)
  
  ram_driver driver;
  ram_sequencer sequencer;
  ram_monitor monitor;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("AGENT", "Build phase", UVM_LOW);
    driver = ram_driver::type_id::create("driver", this);
    sequencer = ram_sequencer::type_id::create("sequencer", this);
    monitor = ram_monitor::type_id::create("monitor", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("AGENT", "Connect phase", UVM_LOW);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass

//============================================================================
// ENVIRONMENT: ram_env
//============================================================================
class ram_env extends uvm_env;
  `uvm_component_utils(ram_env)
  
  ram_agent agent;
  ram_scoreboard scoreboard;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("ENV", "Build phase", UVM_LOW);
    agent = ram_agent::type_id::create("agent", this);
    scoreboard = ram_scoreboard::type_id::create("scoreboard", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENV", "Connect phase", UVM_LOW);
    agent.monitor.ap.connect(scoreboard.observed_fifo.analysis_export);
  endfunction
endclass

//============================================================================
// SEQUENCE: ram_write_sequence
//============================================================================
class ram_write_sequence extends uvm_sequence #(ram_transaction);
  `uvm_object_utils(ram_write_sequence)
  
  function new(string name = "ram_write_sequence");
    super.new(name);
  endfunction
  
  task body();
    repeat (5) begin
      ram_transaction xact = ram_transaction::type_id::create("xact");
      xact.addr = $random % 16;
      xact.data = $random % 256;
      xact.write = 1;
      
      start_item(xact);
      finish_item(xact);
      `uvm_info("SEQ", $sformatf("Sent: addr=%d, data=%h", xact.addr, xact.data), UVM_LOW);
    end
  endtask
endclass

//============================================================================
// TEST: ram_test
//============================================================================
class ram_test extends uvm_test;
  `uvm_component_utils(ram_test)
  
  ram_env env;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TEST", "Build phase", UVM_LOW);
    env = ram_env::type_id::create("env", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("TEST", "Connect phase", UVM_LOW);
  endfunction
  
  task run_phase(uvm_phase phase);
    `uvm_info("TEST", "Run phase", UVM_LOW);
    phase.raise_objection(phase);
    
    begin
      ram_write_sequence seq = new("seq");
      seq.start(env.agent.sequencer);
    end
    
    phase.drop_objection(phase);
  endtask
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("TEST", "Report phase", UVM_LOW);
  endfunction
endclass

//============================================================================
// TOP MODULE
//============================================================================
module top;
  logic clk = 0;
  logic resetN;
  
  dual_port_ram_if if_inst();
  assign if_inst.clk = clk;
  assign if_inst.resetN = resetN;
  
  dual_port_ram #(
    .ADDR_WIDTH(4),
    .DATA_WIDTH(8),
    .DEPTH(16)
  ) dut (
    .clk(if_inst.clk),
    .resetN(if_inst.resetN),
    .addr_a(if_inst.addr_a),
    .write_data_a(if_inst.write_data_a),
    .write_enable_a(if_inst.write_enable_a),
    .read_data_a(if_inst.read_data_a),
    .addr_b(if_inst.addr_b),
    .write_data_b(if_inst.write_data_b),
    .write_enable_b(if_inst.write_enable_b),
    .read_data_b(if_inst.read_data_b)
  );
  
  initial begin
    uvm_config_db #(virtual dual_port_ram_if)::set(null, "", "vif", if_inst);
    resetN = 0;
    #30 resetN = 1;
    run_test("ram_test");
  end
  
  initial forever #10 clk = ~clk;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule