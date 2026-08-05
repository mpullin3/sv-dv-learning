// Code your testbench here
// or browse Examples
// This design uses always_comb in professional practice, but Icarus requires // workaround.It won't run here but code should be correct.
module tb_barrel_shifter;
  logic direction;
  logic [1:0] shift_amt;
  logic [3:0] data_in, data_out;
  
  barrel_shifter_4bit dut (
    .direction(direction),
    .shift_amt(shift_amt),
    .data_in(data_in),
    .data_out(data_out)
  );
  
  initial begin
    // no clk so no waveform
    // Test 1: no shift
    data_in = 4'b1010;
    shift_amt = 2'b00;
    direction = 0;
    #1; // wait 1 time unit
    assert (data_out == 4'b1010)
      else $display("ERROR");
    if(data_out == 4'b1010)
      $display("Result is 0x%b.", data_out);
    
    // Test 2: left shift 1
    data_in = 4'b1010;
    shift_amt = 2'b01;
    direction = 0;
    #1;
    assert (data_out == 4'b0101)
      else $display("ERROR");
    if(data_out == 4'b0101)
      $display("Result is 0x%b.", data_out);
    
    // Test 3: right shift 1
    data_in = 4'b1011;
    shift_amt = 2'b11;
    direction = 1;
    #1;
    assert(data_out == 4'b1101)
      else $display("ERROR");
    if(data_out == 4'b1101)
      $display("Result is 0x%b.", data_out);
    
    $finish;
  end 
endmodule
    
  