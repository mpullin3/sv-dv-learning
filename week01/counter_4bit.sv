module counter_4bit (
  input logic clk,
  input logic resetN,
  output logic [3:0] count
);
  
  always_ff @(posedge clk, negedge resetN)
    if (!resetN)
      count <= 0;
  	else 
      count <= count + 1;
endmodule