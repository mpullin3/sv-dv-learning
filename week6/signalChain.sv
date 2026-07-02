// Level 1: Simple modules
module stage1_process (
  input logic [7:0] data_in,
  output logic [7:0] data_out
);
  assign data_out = data_in + 10;
endmodule

module stage2_process (
  input logic [7:0] data_in,
  output logic [7:0] data_out
);
  assign data_out = data_in * 2;
endmodule

// Level 2: Pipeline (connects stages)
module pipeline (
  input logic [7:0] input_data,
  output logic [7:0] output_data
);
  logic [7:0] stage1_out;  // Intermediate signal
  
  stage1_process s1 (
    .data_in(input_data),
    .data_out(stage1_out)
  );
  
  stage2_process s2 (
    .data_in(stage1_out),
    .data_out(output_data)
  );
endmodule