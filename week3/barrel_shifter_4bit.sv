// Code your design here
module barrel_shifter_4bit (
  input logic [3:0] data_in,
  output logic [3:0] data_out,
  input logic [1:0] shift_amt,
  input logic direction
); 
  
  always_comb begin
    case({direction,shift_amt})
      // Left shifts (direction = 0)
      3'b000: data_out = data_in; // no shift
      3'b001: data_out = {data_in[2:0], data_in[3]}; // rotate left 1
      
      // Right shifts (direction = 1)
      3'b100: data_out = data_in; // no shift
      3'b101: data_out = {data_in[0], data_in[3:1]}; // rotate right 1
      default: data_out = 4'b0;
    endcase
  end
endmodule