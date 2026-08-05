module tb_shift_tasks;
  logic clk, resetN;
  logic [7:0] data_in, data_out;
  
  shift_register_8bit_tasks dut (
    .clk(clk),
    .resetN(resetN),
    .data_in(data_in),
    .data_out(data_out)
  );
  
  always #10 clk = ~clk;
  
  // Task definition (at module level, BEFORE initial)
  task send_and_verify(logic [7:0] value);
    data_in = value;
    @(posedge clk);
    assert (data_out == value)
      else $display("FAILED: Expected 0x%02X but got 0x%02X", value, data_out);
    if(data_out == value)
      $display("Test %0d: PASS (Sent 0x%02x, Got 0x%02x)", value, value, data_out);
  endtask
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
    clk = 0;
    resetN = 0;
    #30 resetN = 1;
    @(posedge clk);
    
    // Task calls (inside initial)
    send_and_verify(8'h00);
    send_and_verify(8'h01);
    send_and_verify(8'h02);
    send_and_verify(8'h03);
    send_and_verify(8'h04);
    send_and_verify(8'h05);
    send_and_verify(8'h06);
    send_and_verify(8'h07);
    
    $finish;
  end
endmodule