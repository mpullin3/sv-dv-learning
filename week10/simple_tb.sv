//============================================================================
// SIMPLE FIFO TESTBENCH
// Basic elaboration testbench for Checkpoint 10
// Demonstrates FIFO instantiation and basic interface connection
//============================================================================

`timescale 1ns/1ps

module fifo_tb;
  //==========================================================================
  // SIGNALS
  //==========================================================================
  logic clk;
  logic resetN;
  
  // Write side
  logic write_en;
  logic [7:0] write_data;
  logic full;
  
  // Read side
  logic read_en;
  logic [7:0] read_data;
  logic empty;
  
  // Status
  logic [4:0] occupancy;
  
  //==========================================================================
  // DUT INSTANTIATION
  //==========================================================================
  fifo #(
    .DEPTH(16),
    .DATA_WIDTH(8)
  ) dut (
    .clk(clk),
    .resetN(resetN),
    .write_en(write_en),
    .write_data(write_data),
    .full(full),
    .read_en(read_en),
    .read_data(read_data),
    .empty(empty),
    .occupancy(occupancy)
  );
  
  //==========================================================================
  // CLOCK GENERATION
  //==========================================================================
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10ns period (100MHz)
  end
  
  //==========================================================================
  // RESET AND BASIC SIMULATION
  //==========================================================================
  initial begin
    resetN = 0;
    write_en = 0;
    read_en = 0;
    write_data = 0;
    
    // Reset for 20ns
    #20 resetN = 1;
    
    $display("=== FIFO Testbench Started ===");
    $display("Time: %0t | Empty: %b | Full: %b | Occupancy: %d", 
      $time, empty, full, occupancy);
    
    // Simple write test
    #10 write_en = 1;
    write_data = 8'hAA;
    $display("Time: %0t | Writing: 0x%h", $time, write_data);
    
    #10 write_data = 8'hBB;
    $display("Time: %0t | Writing: 0x%h", $time, write_data);
    
    #10 write_en = 0;
    
    // Simple read test
    #10 read_en = 1;
    $display("Time: %0t | Reading: 0x%h", $time, read_data);
    
    #10 read_en = 0;
    
    // Run for a bit
    #50;
    
    $display("=== FIFO Testbench Complete ===");
    $finish;
  end
  
  //==========================================================================
  // OPTIONAL: VCD DUMP FOR WAVEFORM VIEWING
  //==========================================================================
  initial begin
    $dumpfile("fifo_dump.vcd");
    $dumpvars(0, fifo_tb);
  end

endmodule