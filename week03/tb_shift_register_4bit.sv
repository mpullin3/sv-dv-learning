// Code your testbench here
// or browse Examples
module tb_shift_register_4bit;
  // Signal declarations
  logic clk, resetN;
  logic [3:0] data_in, data_out;
  
  // Instantiate DUT (Design Under Test)
  shift_register_4bit dut (
    .clk(clk),
    .resetN(resetN),
    .data_in(data_in),
    .data_out(data_out)
  );
  
  // Clock generation: toggle every 10 time units (20ns period)
  always #10 clk = ~clk;
  
  initial begin
    // VCD waveform generation for viewing in EPWave
    $dumpfile("dump.vcd");
    $dumpvars;
    
    // Initialize clock to 0 to avoid infinite loop
    clk = 0;
    
    // Assert reset (active low)
    resetN = 0;
    
    // Hold reset for 30 time units
    #30 resetN = 1;
    
    // Synchronize to clock edge after reset release
    @(posedge clk);
    
    // Test loop: apply 4 test values (0, 1, 2, 3)
    for (int i = 0; i < 4; i = i + 1) begin
      // Set input to test value
      data_in = i;
      
      // Wait for clock edge for register to capture
      @(posedge clk);
      
      // Assertion: verify output matches input
      assert (data_out == i)
        else $display("Error at test %0d: Expected 0x%02x but got 0x%02x", i, i, data_out);
      
      // Print result if assertion passes
      if (data_out == i)
        $display("Test %0d: Pass (Sent 0x%02x, Got 0x%02x)", i, i, data_out);
    end
    
    // End simulation
    $finish;
  end
endmodule