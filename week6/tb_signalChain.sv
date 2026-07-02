// Level 3: Testbench
module tb_pipeline;
  logic [7:0] input_val, output_val;
  
  pipeline dut (
    .input_data(input_val),
    .output_data(output_val)
  );
  
  initial begin
    input_val = 5;
    #10;
    // Expected: (5+10)*2 = 30
    assert (output_val == 30) else $display("ERROR");
    $display("Output value is: %0d", output_val);
    
    $finish;
  end
endmodule