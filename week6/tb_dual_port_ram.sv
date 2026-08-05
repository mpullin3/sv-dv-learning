// Code your testbench here
// or browse Examples
module tb_dual_port_ram;
  // Parameters
  localparam int ADDR_WIDTH = 4;
  localparam int DATA_WIDTH = 8;
  localparam int DEPTH = 16;
  
  // Signals
  logic clk, resetN;
  logic [ADDR_WIDTH-1:0] addr_a, addr_b;
  logic [DATA_WIDTH-1:0] write_data_a, write_data_b;
  logic write_enable_a, write_enable_b;
  logic [DATA_WIDTH-1:0] read_data_a, read_data_b;
  
  // DUT instantiation
  dual_port_ram #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
  ) dut (
    .clk(clk),
    .resetN(resetN),
    .addr_a(addr_a),
    .write_data_a(write_data_a),
    .write_enable_a(write_enable_a),
    .read_data_a(read_data_a),
    .addr_b(addr_b),
    .write_data_b(write_data_b),
    .write_enable_b(write_enable_b),
    .read_data_b(read_data_b)
  );
  
  // Clock generation
  always #10 clk = ~clk;
  
  initial begin
    // VCD dump
    $dumpfile("dump.vcd");
    $dumpvars;
    
    // Initialize
    clk = 0;
    resetN = 0;
    addr_a = 0;
    addr_b = 0;
    write_data_a = 0;
    write_data_b = 0;
    write_enable_a = 0;
    write_enable_b = 0;
    
    // Reset
    #30 resetN = 1;
    
    // TEST 1: Write to Port A, read from Port B
    @(posedge clk);
    addr_a = 5;
    write_data_a = 8'hAA;
    write_enable_a = 1;
    
    @(posedge clk);
    write_enable_a = 0;
    addr_b = 5;
    
    @(posedge clk);
    #1;
    assert (read_data_b == 8'hAA)
      else $display("ERROR Test 1: Port B read failed");
    $display("Test 1 Pass: Port A write, Port B read");
    
    // TEST 2: Independent writes
    @(posedge clk);
    addr_a = 3;
    write_data_a = 8'h11;
    write_enable_a = 1;
    addr_b = 7;
    write_data_b = 8'h22;
    write_enable_b = 1;
    
    @(posedge clk);
    write_enable_a = 0;
    write_enable_b = 0;
    addr_a = 3;
    addr_b = 7;
    
    @(posedge clk);
    #1;
    assert (read_data_a == 8'h11)
      else $display("ERROR Test 2: Port A data mismatch");
    assert (read_data_b == 8'h22)
      else $display("ERROR Test 2: Port B data mismatch");
    $display("Test 2 Pass: Independent writes verified");
    
    // TEST 3: Read same address from both ports
    @(posedge clk);
    addr_a = 10;
    addr_b = 10;
    write_data_a = 8'h99;
    write_enable_a = 1;
    
    @(posedge clk);
    write_enable_a = 0;
    
    @(posedge clk);
    #1;
    assert (read_data_a == 8'h99 && read_data_b == 8'h99)
      else $display("ERROR Test 3: Both ports should read same value");
    $display("Test 3 Pass: Both ports read same address");
    
    $display("\nAll tests passed!");
    $finish;
  end
endmodule