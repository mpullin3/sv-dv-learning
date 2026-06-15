// Code your testbench here
// or browse Examples
module tb_paramGenerate #(parameter Width = 8);
  logic [Width - 1:0] in0, in1, in2, in3;
  logic [1:0] sel;
  logic [Width*4 - 1:0] out;
  logic [Width-1:0] expected;  // Declare here (outside loop)
  
  // Instantiate with parameterized Width
  paramGenerate_mux #(.Width(Width)) dut (
    .in0(in0),
    .in1(in1),
    .in2(in2),
    .in3(in3),
    .sel(sel),
    .out(out)
  );
  
  initial begin
  // set test values
    in0 = {Width{1'b1}}; // All 1s
    in1 = {Width{1'b0}}; // All 0s
    in2 = {{Width/2{1'b1}}, {Width/2{1'b0}}}; // Alternating
    in3 = {{Width/2{1'b0}}, {Width/2{1'b1}}}; // Reverse alternating
    
    // Test all 4 select values 
    for (int sel_test = 0; sel_test < 4; sel_test++) begin
      sel = sel_test;
      #1;
      
      // Expected value based on sel
      expected = (sel_test == 0) ? in0 :
                 (sel_test == 1) ? in1 :
                 (sel_test == 2) ? in2 : in3;
      
      assert (out[Width-1:0] == expected)
        else $display("ERROR: sel=%0d, expected=0x%X, got=0x%X", sel_test, expected, out[Width-1:0]);
      
      if (out[Width-1:0] == expected)
        $display("Test PASS: sel=%0d, out=0x%X", sel_test, out[Width-1:0]);
    end
    
    $finish;
  end
endmodule