module tb_shift_forLoop;
  logic clk, resetN;
  logic [7:0] data_in, data_out;
  
  shift_register_8bit_forLoop dut (
    .clk(clk),
    .resetN(resetN),
    .data_in(data_in),
    .data_out(data_out)
  );
  
  always #10 clk = ~clk;
  
  initial begin
    clk = 0;  // INITIALIZE CLOCK TO 0
    
    $dumpfile("dump.vcd");
    $dumpvars;
    
    resetN = 0; 
    #30 resetN = 1;
    @(posedge clk);
    
    for(int i = 0; i < 8; i = i + 1) begin
      data_in = i;
      @(posedge clk);
      $display("Test %0d: Sent 0x%02X, Output: 0x%02X", i, i, data_out);
    end
    
    $finish;
  end
endmodule