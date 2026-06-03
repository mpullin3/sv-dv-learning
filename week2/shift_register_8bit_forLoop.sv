// Code your design here
module shift_register_8bit_forLoop (
  input logic clk,
  input logic resetN,
  input logic [7:0] data_in,
  output logic [7:0] data_out
);
  
  logic [7:0] sr;
  
  always_ff @(posedge clk, negedge resetN)
    if(!resetN)
      sr <= 0;
  	else
      sr <= {sr[6:0], data_in}; // shift left, LSB is the input value
  								// new data enters from the right
  assign data_out = sr;
endmodule