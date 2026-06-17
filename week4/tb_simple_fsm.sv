// Code your testbench here
// or browse Examples
// Please not that this code won't run on EDA playground because the simulator
// Icarus Verilog 12.0 does not support 'type_def enum'. It should work in   // other simulators though. 
module tb_simple_fsm;
  logic clk, resetN, start; // input
  logic active; // output
  
  simple_fsm dut (
    .clk(clk),
    .resetN(resetN),
    .start(start),
    .active(active)
  );
  
  // Clock generation
  always #10 clk = ~clk;
  
  initial begin
    // initialize
    clk = 0;
    resetN = 0;
    start = 0;
    
    // Reset for 30 time units
    #30 resetN = 1;
    @(posedge clk);
    
    // Test 1: check reset state (idle)
    assert(dut.current_state == dut.Idle)
      else $display("Error: Not in Idle after reset");
    assert(active == 0)
      else $display("Error: active should be 0 in Idle");
    $display("Test 1 Pass: Reset to Idle, active = 0");
    
    // Test 2: Trigger transition (Idle > Active)
    start = 1; 
    @(posedge clk);
    assert(dut.current_state == dut.Active)
      else $display("Error: Should transition to active on start");
    assert(active == 1)
      else $display("Error: active should be 1 in Active");
    $display("Test 2 Pass: Idle > Active, active = 1");
    
    // Test 3: Auto-transition (Active > Idle)
    start = 0;
    @(posedge clk);
    assert(dut.current_state == dut.Idle)
      else $display("Error: should return to Idle");
    assert(active == 0)
      else $display("Error: active should be 0");
    $display("Test 3 Pass: Active > Idle, active = 0");
    
    $finish;
  end
endmodule