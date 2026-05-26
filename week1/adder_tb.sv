module tb_adder;
  reg [3:0] a, b;
  reg cin;
  wire [3:0] sum;
  wire cout;
  
  adder_4bit dut (
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
  );
  
  initial begin
    a = 4'h3; b = 4'h5; cin = 0; #10;
    a = 4'hF; b = 4'h1; cin = 0; #10;
    a = 4'h7; b = 4'h8; cin = 1; #10;
    $finish;
  end
endmodule

