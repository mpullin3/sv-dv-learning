module tb_and;
  logic[3:0] a, b;
  logic[3:0] y;
  
  and_4bit dut (
    .a(a),
    .b(b),
    .y(y)
  );
  
  initial begin
    a = 4'h0; b = 4'h0; #10;
    a = 4'h0; b = 4'h1; #10;
    a = 4'h1; b = 4'h0; #10;
    a = 4'h1; b = 4'h1; #10;
    $finish;
  end
endmodule