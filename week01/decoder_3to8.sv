module decoder_3to8 (
  input logic [2:0] sel,
  output logic [7:0] out
);
  assign out = 8'b0000_0001 << sel;
endmodule