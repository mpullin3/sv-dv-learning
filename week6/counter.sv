// Code your design here
module counter (
  input logic clk, resetN,
  output logic [7:0] count
);
  always_ff @(posedge clk, negedge resetN)
    if (!resetN)
      count <= 0;
    else
      count <= count + 1;
endmodule