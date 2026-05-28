module tb_mux;
  logic [7:0] in0, in1;
  logic sel;
  logic [7:0] out;
  
  mux_2x1 dut (
    .in0(in0),
    .in1(in1),
    .sel(sel),
    .out(out)
  );
  
  initial begin
    in0 = 8'h0A;
    in1 = 8'h0B;
    
    sel = 1'b0; #10;
    sel = 1'b1; #10;
    
    $finish; 
  end
endmodule