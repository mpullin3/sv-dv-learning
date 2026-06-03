module tb_shift_assertions;
  // Signal declarations
  logic clk, resetN;
  logic [7:0] data_in, data_out;
  
  // Instantiate DUT (Design Under Test)
  shift_register_8bit_assertions dut (
    .clk(clk),
    .resetN(resetN),
    .data_in(data_in),
    .data_out(data_out)
  );
  
  // Clock generation: toggle every 10ns (20ns period)
  always #10 clk = ~clk;
  
  initial begin
    // VCD waveform generation
    $dumpfile("dump.vcd");
    $dumpvars;
    
    // Initialize clock and reset
    clk = 0;
    resetN = 0;
    #30 resetN = 1;        // Hold reset for 30ns
    @(posedge clk);        // Wait for clock edge after reset
    
    // Test loop: shift 8 values (0-7) through the register
    for (int i = 0; i < 8; i = i + 1) begin
      data_in = i;         // Apply test value
      @(posedge clk);      // Wait for register to shift
      
      // Assertion: Verify output matches input
      assert (data_out == i)
        else $display("ASSERTION FAILED at test %0d: Expected 0x%02X but got 0x%02X", i, i, data_out);
      
      // Print result if test passes
      if (data_out == i)
        $display("Test %0d: PASS (Sent 0x%02X, Got 0x%02X)", i, i, data_out);
    end
    
    // End simulation
    $finish;
  end
endmodule