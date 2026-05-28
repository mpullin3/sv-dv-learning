module tb_mux4to1;
  logic [7:0] in0, in1, in2, in3;
  logic [1:0] sel;
  logic [7:0] out;
  
  mux_4to1 dut (
    .in0(in0),
    .in1(in1),
    .in2(in2),
    .in3(in3),
    .sel(sel),
    .out(out)
  );
  initial begin
    in0 = 8'b00;
    in1 = 8'b01;
    in2 = 8'b10;
    in3 = 8'b11;
    
    sel = 2'b00; #10;
    sel = 2'b01; #10;
    sel = 2'b10; #10;
    sel = 2'b11; #10;
    
    $finish;
  end
endmodule