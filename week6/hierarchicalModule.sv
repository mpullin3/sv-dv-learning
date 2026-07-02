// Code your design here
module adder (
  input logic [7:0] x, y,
  output logic [8:0] sum
);
  assign sum = x + y;
endmodule

module comparator (
  input logic [8:0] value,
  output logic is_large
);
  assign is_large = (value > 100);
endmodule

// Top module connects them
module processing_unit (
  input logic [7:0] in_a, in_b,
  output logic result
);
  logic [8:0] sum;  // Wire to connect adder output to comparator input
  
  // Adder takes inputs, produces sum
  adder add_inst (
    .x(in_a),
    .y(in_b),
    .sum(sum)  // Output of adder
  );
  
  // Comparator takes sum as input
  comparator cmp_inst (
    .value(sum),  // Input from adder
    .is_large(result)
  );
endmodule