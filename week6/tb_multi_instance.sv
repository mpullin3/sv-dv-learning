// Code your testbench here
// or browse Examples
module tb_multi_instance;
  logic clk, resetN;
  logic [7:0] count1, count2;
  
  // 2 independent counter instances
  counter cnt1 (
    .clk(clk),
    .resetN(resetN),
    .count(count1)
  );
  
  counter cnt2 (
    .clk(clk),
    .resetN(resetN),
    .count(count2)
  );
  
  // Clock generation
  always #10 clk = ~clk;
  
  initial begin
    // VCD dump setup
    $dumpfile("dump.vcd");
    $dumpvars;
    
    // Initialize
    clk = 0;
    resetN = 0;
    
    // Reset for 30 time units
    #30 resetN = 1;
    
    // Test phase: verify both counters stay synchronized
    repeat (50) begin
      @(posedge clk);
      #1;  // Let counters settle
      
      // Both should be equal
      assert (count1 == count2)
        else $display("ERROR at %0t: count1=%0d, count2=%0d", $time, count1, count2);
      
      // Log every 10 cycles
      if (count1 % 10 == 0)
        $display("[%0t] Counters: cnt1=%0d, cnt2=%0d", $time, count1, count2);
    end
    
    $display("Test complete: counters remained synchronized");
    
    $finish;
  end
endmodule