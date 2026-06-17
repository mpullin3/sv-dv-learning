// Code your testbench here
// or browse Examples
module tb_sequence_generator;
  logic clk, resetN;
  logic data_in; // input
  logic detected; // output
  
  sequence_detector dut (
    .clk(clk),
    .resetN(resetN),
    .data_in(data_in),
    .detected(detected)
  );
  
  // clock generation
  always #10 clk = ~clk;
  
  initial begin
    // initialize
    clk = 0;
    resetN = 0;
    data_in = 0;
    
    // Reset
    #30 resetN = 1;
    @(posedge clk);
    
    // Test 1: "101" > detected
    data_in = 1; @(posedge clk);
    assert(detected == 0) else $display("Error");
    
    data_in = 0; @(posedge clk);
    assert(detected == 0) else $display("Error");
    
    data_in = 1; @(posedge clk);
    assert(detected == 1) else $display("Error");
    $display("Test 1 Pass: 101 detected");
    
    // Test 2: "001" > no detection
    data_in = 0; @(posedge clk);
    assert(detected == 0) else $display("Error");
    
    data_in = 0; @(posedge clk);
    assert(detected == 0) else $display("Error");
    
    data_in = 1; @(posedge clk);
    assert(detected == 0) else $display("Error");
    $display("Test 2 Pass: 001 not detected");
    
    // Test 3: "1011" > detects, resets
	data_in = 1; @(posedge clk);
	assert(detected == 0) else $display("Error");

	data_in = 0; @(posedge clk);
	assert(detected == 0) else $display("Error");

	data_in = 1; @(posedge clk);
	assert(detected == 1) else $display("Error");

	data_in = 1; @(posedge clk);
	assert(detected == 0) else $display("Error");
	$display("Test 3 Pass: 1011 detects once, resets");

	// Test 4: "10101" > detects twice
	data_in = 0; @(posedge clk);
	assert(detected == 0) else $display("Error");

	data_in = 1; @(posedge clk);
	assert(detected == 1) else $display("Error");
	$display("Test 4 Pass: 10101 detects twice");
    
    $finish;
  end
endmodule
    
    