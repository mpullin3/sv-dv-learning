// Code your testbench here
// or browse Examples
module tb_three_state_fsm;
  logic clk, resetN, start; // input
  logic active; // output
  
  three_state_fsm dut (
    .clk(clk),
    .resetN(resetN),
    .start(start),
    .active(active)
  );
  
  // Clock generation
  always #10 clk = ~clk;
  
  initial begin
    // waveform dump
    $dumpfile("dump.vcd");
    $dumpvars;
    
    // initialize
    clk = 0;
    resetN = 0;
    start = 0;
    
    // Reset for 30 time units
    #30 resetN = 1;
    @(posedge clk);
    
    // Test 1: check reset state (idle)
    assert(dut.current_state == 0)
      else $display("Error: Not in Idle after reset");
    assert(active == 0)
      else $display("Error: active should be 0 in Idle");
    $display("Test 1 Pass: Reset to Idle, active = 0");
    
    // Debug: check state values
	$display("Idle = %0d, Wait = %0d, Active = %0d", dut.Idle, dut.Wait, 	dut.Active);
	$display("Current state after reset = %0d", dut.current_state);
    
    // Test 2: Trigger transition (Idle > Wait)
    start = 1; 
    @(posedge clk);
    #1;
    assert(dut.current_state == 1)
      else $display("Error: Should transition to wait on start");
    assert(active == 0)
      else $display("Error: active should be 0 in Wait");
    $display("Test 2 Pass: Idle > Wait, active = 0");
    
    // Test 3: Trigger transition (Wait > Active)
    start = 1; 
    @(posedge clk);
    #1;
    assert(dut.current_state == 2)
      else $display("Error: Should transition to Active on start");
    assert(active == 1)
      else $display("Error: active should be 1 in Active");
    $display("Test 3 Pass: Wait > Active, active = 1");
    
    // Test 4: Auto-transition (Active > Idle)
    start = 0;
    @(posedge clk);
    #1;
    assert(dut.current_state == 0)
      else $display("Error: should return to Idle");
    assert(active == 0)
      else $display("Error: active should be 0");
    $display("Test 4 Pass: Active > Idle, active = 0");
    
    $finish;
  end
endmodule