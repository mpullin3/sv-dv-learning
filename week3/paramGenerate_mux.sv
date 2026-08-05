// Code your design here
module paramGenerate_mux #(parameter Width = 8) (
  input logic [Width - 1:0] in0, in1, in2, in3,
  input logic [1:0] sel,
  output logic [Width*4 - 1:0] out
);
  
  generate
    for(genvar i = 0; i < 4; i += 1) begin : mux_gen
      assign out [i*Width + Width - 1 : i*Width] = (sel == 0) ? in0 :
        (sel == 1) ? in1 : (sel == 2) ? in2 : in3;
    end
  endgenerate
endmodule