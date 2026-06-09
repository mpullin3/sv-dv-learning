// Code your testbench here
// or browse Examples
module tb_parameterized_counter;  // No parameter here
  logic clk, resetN;
  logic [3:0] count_4bit;
  logic [7:0] count_8bit;
  
  parameterized_counter #() dut8 (
    .clk(clk),
    .resetN(resetN),
    .count(count_8bit)
  );
  
  parameterized_counter #(.Width(4)) dut4 (
    .clk(clk),
    .resetN(resetN),
    .count(count_4bit)
  );
  
  always #10 clk = ~clk;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
    clk = 0;
    resetN = 0;
    #30 resetN = 1;
    @(posedge clk);
    
    // Test 4-bit counter
    repeat (16) begin
      @(posedge clk);
      assert (count_4bit < 16)
        else $display("Error: 4-bit counter exceeded max");
    end
    
    // Test 8-bit counter
    repeat (256) begin
      @(posedge clk);
      assert (count_8bit < 256)
        else $display("Error: 8-bit counter exceeded max");
    end
    
    $finish;
  end
endmodule