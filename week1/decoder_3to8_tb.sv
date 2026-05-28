module tb_decoder;
  logic [2:0] sel;
  logic [7:0] out;
  
  decoder_3to8 dut (
    .sel(sel),
    .out(out)
  );
  
  initial begin
    sel = 3'd0; #10;
    sel = 3'd1; #10;
    sel = 3'd2; #10;
    sel = 3'd3; #10;
    sel = 3'd4; #10;
    sel = 3'd5; #10;
    sel = 3'd6; #10;
    sel = 3'd7; #10;
    $finish;
  end
endmodule
  