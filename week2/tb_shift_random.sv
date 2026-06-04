module tb_shift_random;
  logic clk, resetN;
  logic [7:0] data_in, data_out;
  logic [7:0] random_value;
  
  shift_register_8bit_random dut (
    .clk(clk),
    .resetN(resetN),
    .data_in(data_in),
    .data_out(data_out)
  );
  
  always #10 clk = ~clk;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
    clk = 0;
    resetN = 0;
    #30 resetN = 1;
    @(posedge clk);
    
    repeat (16) begin
      random_value = $random % 256;
      data_in = random_value;
      @(posedge clk);
      
      assert (data_out == random_value)
        else $display("FAILED: Expected 0x%02X but got 0x%02X", random_value, data_out);
      
      $display("Test PASS: Sent 0x%02X, Got 0x%02X", random_value, data_out);
    end
    
    $finish;
  end
endmodule