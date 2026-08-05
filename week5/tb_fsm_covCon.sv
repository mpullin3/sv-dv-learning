// Interface bundles related signals into one package
interface fsm_if;
  logic clk, resetN, start, active;
  
  clocking cb @(posedge clk);
    output start;
    input active;
  endclocking
endinterface

// Constraint class defines randomization rules for stimulus
class fsm_stimulus;
  rand logic start;
  
  constraint start_bias {
    start dist {0 := 70, 1 := 30}; // 70% = 0, 30% = 1
  }
endclass

module tb_clkblk_fsm;
  fsm_if if_inst();
  
  three_state_fsm_covCon dut(
    .clk(if_inst.clk),
    .resetN(if_inst.resetN),
    .start(if_inst.start),
    .active(if_inst.active)
  );
  
  always #10 if_inst.clk = ~if_inst.clk;
  
  initial begin
    // Declare constraint class variable BEFORE any statements
    fsm_stimulus gen;
    
    // Generate waveform for debugging
    $dumpfile("dump.vcd");
    $dumpvars;
    
    // Initialize all signals
    if_inst.clk = 0;
    if_inst.resetN = 0;
    if_inst.start = 0;
    
    // Apply reset for 30 time units
    #30 if_inst.resetN = 1;
    
    // DETERMINISTIC TESTS (verify baseline functionality) 
    
    // TEST 1: Verify reset state (IDLE)
    @(if_inst.cb);
    #1;
    assert(if_inst.active == 0) else $display("ERROR Test 1: active should be 0 in IDLE");
    $display("Test 1 Pass: Reset to IDLE");
    cover(if_inst.active == 0 && dut.current_state == 0);
    
    // TEST 2: Trigger IDLE → WAIT transition
    if_inst.cb.start = 1;
    @(if_inst.cb);
    #1;
    assert(if_inst.active == 0) else $display("ERROR Test 2: active should be 0 in WAIT");
    $display("Test 2 Pass: IDLE to WAIT");
    cover(if_inst.active == 0 && dut.current_state == 1);
    
    // Allow WAIT state to stabilize
    @(if_inst.cb);
    
    // TEST 3: Trigger WAIT → ACTIVE transition
    if_inst.cb.start = 0;
    @(if_inst.cb);
    #1;
    assert(if_inst.active == 1) else $display("ERROR Test 3: active should be 1 in ACTIVE");
    $display("Test 3 Pass: WAIT to ACTIVE");
    cover(if_inst.active == 1 && dut.current_state == 2);
    
    // TEST 4: Verify ACTIVE → IDLE auto-transition
    if_inst.cb.start = 0;
    @(if_inst.cb);
    #1;
    assert(if_inst.active == 0) else $display("ERROR Test 4: active should be 0 in IDLE");
    $display("Test 4 Pass: ACTIVE to IDLE");
    cover(if_inst.active == 0 && dut.current_state == 0);
    
    //  RANDOMIZED STIMULUS PHASE 
    
    $display("\n Randomized Stimulus Phase");
    
    // Instantiate constraint class
    gen = new();
    
    // Generate 50 random test cycles
    repeat (50) begin
      gen.randomize();
      if_inst.cb.start = gen.start;
      @(if_inst.cb);
      #1;
      
      // Log state and input
      $display("Time: %0t, state: %0d, start: %b, active: %b", 
        $time, dut.current_state, if_inst.start, if_inst.active);
      
      // Continuous assertions
      assert(dut.current_state <= 2) else $display("ERROR: Invalid state");
      
      // Cover all state/output combinations
      cover(dut.current_state == 0);
      cover(dut.current_state == 1);
      cover(dut.current_state == 2);
      cover(if_inst.active == 1);
      cover(if_inst.active == 0);
    end
    
    $display("\n--- Simulation Complete ---");
    $finish;
  end
endmodule