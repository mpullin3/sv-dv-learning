// Code your testbench here
// or browse Examples
module tb_processing_unit;
  logic [7:0] in_a, in_b;
  logic result;
  
  // Instantiate top module (hierarchy is internal)
  processing_unit dut (
    .in_a(in_a),
    .in_b(in_b),
    .result(result)
  );
  
  initial begin
    in_a = 50;
    in_b = 60;
    #10;
    
    // Can access internal signals for debugging
    $display("Sum: %0d, Result: %b", dut.sum, dut.result);
    $display("Adder output: %0d", dut.add_inst.sum);
    
    assert (result == 1) else $display("ERROR");
    $finish;
  end
endmodule