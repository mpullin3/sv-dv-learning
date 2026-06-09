// Code your design here
// Parameterized N-bit Counter
// Increments on each clock edge, resets on active-low reset
// Width customizable via parameter (default: 8-bit)
module parameterized_counter #(parameter Width = 8) (
  input logic clk, 
  input logic resetN,
  output logic [Width - 1 : 0] count
);
  
  always_ff @(posedge clk, negedge resetN)
    if(!resetN)
      count <= 0;
    else
      count <= count + 1;
endmodule