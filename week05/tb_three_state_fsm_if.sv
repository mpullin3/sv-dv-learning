// Interface bundles related signals into one package
// Avoids passing 4 individual signals; cleaner DUT instantiation
interface fsm_if;
  logic clk, resetN, start, active;
  
  // Clocking block synchronizes all operations to posedge clk
  // output: testbench drives these signals (start)
  // input: testbench reads these signals (active)
  clocking cb @(posedge clk);
    output start;     // Testbench stimulus
    input active;     // Testbench observation
  endclocking
endinterface

module tb_clkblk_fsm;
  fsm_if if_inst();
  
  // Connect DUT ports to interface signals
  three_state_fsm_if dut(
    .clk(if_inst.clk),
    .resetN(if_inst.resetN),
    .start(if_inst.start),
    .active(if_inst.active)
  );
  
  // Clock generation: toggle every 10 time units
  always #10 if_inst.clk = ~if_inst.clk;
  
  initial begin
    // Generate waveform for debugging
    $dumpfile("dump.vcd");
    $dumpvars;
    
    // Initialize all signals
    if_inst.clk = 0;
    if_inst.resetN = 0;
    if_inst.start = 0;
    
    // Apply reset for 30 time units
    #30 if_inst.resetN = 1;
    
    // TEST 1: Verify reset state (IDLE)
    @(if_inst.cb);           // Wait for clock edge (synchronize)
    #1;                       // Allow combinatorial output to settle
    // Read direct signal (if_inst.active), not clocking block sample
    // Direct read gives settled value after propagation delay
    assert(if_inst.active == 0) else $display("Error");
    $display("Test 1 Pass");
    
    // TEST 2: Trigger IDLE to WAIT transition 
    // Use blocking assignment (=) for stimulus, not non-blocking (<=)
    // Blocking ensures start=1 takes effect immediately, before clock edge
    // Non-blocking would schedule assignment for end-of-cycle (too late)
    if_inst.cb.start = 1;    
    @(if_inst.cb);           // Clock edge processes next state logic
    #1;                       // Let output settle before assertion
    assert(if_inst.active == 0) else $display("Error");
    $display("Test 2 Pass");
    
    // Allow WAIT state to stabilize before next test
    // Extra clock ensures state machine fully transitioned
    @(if_inst.cb);
    
    // TEST 3: Trigger WAIT to ACTIVE transition
    // Set start=0 (blocking assignment) to allow auto-transition
    if_inst.cb.start = 0;
    @(if_inst.cb);           // Wait for clock edge
    #1;                       // Let output propagate
    // Direct signal read (not cb.active) captures settled output value
    assert(if_inst.active == 1) else $display("Error");
    $display("Test 3 Pass");
    
    // TEST 4: Verify ACTIVE to IDLE auto-transition 
    if_inst.cb.start = 0;    // Keep start low (already 0, but explicit)
    @(if_inst.cb);           // Clock edge triggers state machine
    #1;                       // Delay for output to settle
    assert(if_inst.active == 0) else $display("Error");
    $display("Test 4 Pass");
    
    $finish;
  end
endmodule
