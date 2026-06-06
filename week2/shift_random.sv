// 8-bit Shift Register
// Synchronously captures 8-bit input on each rising clock edge
// Asynchronous active-low reset clears register to zero

module shift_register_8bit_random (
  input logic clk,
  input logic resetN,
  input logic [7:0] data_in,
  output logic [7:0] data_out
);
  
  logic [7:0] sr;  // Internal 8-bit register
  
  always_ff @(posedge clk, negedge resetN)
    if (!resetN)
      sr <= 0;  // Reset: clear register to zero
    else
      sr <= {sr[6:0], data_in};  // Load: capture input on clock edge
  
  assign data_out = sr;  // Output the captured value
endmodule