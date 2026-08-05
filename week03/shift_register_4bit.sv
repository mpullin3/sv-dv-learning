// Code your design here
module shift_register_4bit (
  input logic clk,
  input logic resetN,
  input logic [3:0] data_in,
  output logic [3:0] data_out
);
  
  logic [3:0] sr;
  
  always_ff @(posedge clk, negedge resetN)
    if(!resetN)
      sr <= 0;
    else
      sr <= {sr[2:0], data_in};
  
  assign data_out = sr;
endmodule