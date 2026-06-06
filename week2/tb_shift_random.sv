// Testbench: Random stimulus generation with assertions
// Generates 16 random 8-bit patterns, verifies shift register output

module tb_shift_random;
  logic clk, resetN;
  logic [7:0] data_in, data_out;
  logic [7:0] random_value;
  
  shift_register_8bit_random dut ( // DUT connection
    .clk(clk),
    .resetN(resetN),
    .data_in(data_in),
    .data_out(data_out)
  );
  
  always #10 clk = ~clk; // clock generation
  
  initial begin
    $dumpfile("dump.vcd"); // waveform now viewable
    $dumpvars;
    
    clk = 0; // initialize clock to 0 to avoid infinite loop
    resetN = 0; // assert reset
    #30 resetN = 1; // hold for 30 time units then release reset
    @(posedge clk); // synchronize to clock edge
    
    repeat (16) begin // repeat below code 16 times then stop
      random_value = $random % 256; // create random value
      data_in = random_value; // set data_in equal to random_value
      @(posedge clk); // synchronize to clock edge.
      
      assert (data_out == random_value) // assertion check
        else $display("FAILED: Expected 0x%02X but got 0x%02X", random_value, data_out);
      
      $display("Test PASS: Sent 0x%02X, Got 0x%02X", random_value, data_out); // output display
    end
    
    $finish;
  end
endmodule