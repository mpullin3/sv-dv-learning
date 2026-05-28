module tb_counter;
  logic clk, resetN;
  logic [3:0] count;
  
  counter_4bit dut (
    .clk(clk),
    .resetN(resetN),
    .count(count)
  );
  
  initial begin
    clk = 0;
    resetN = 0; #10;
    resetN = 1; #10;
    
    repeat (8) begin
  		#10 clk = 1;  // Rising edge
  		$display("Count: %0d", count);
 		 #10 clk = 0;  // Falling edge (no print)
	end
    
    $finish;
  end
endmodule