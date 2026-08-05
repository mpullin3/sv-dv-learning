//============================================================================
// SYNCHRONOUS FIFO
// Single clock domain, circular buffer design
// Parameterized depth and data width
//============================================================================

module fifo #(
  parameter int DEPTH = 16,              // Number of entries
  parameter int DATA_WIDTH = 8,          // Bits per entry
  parameter int PTR_WIDTH = $clog2(DEPTH) + 1  // Pointer width (log2 + 1)
) (
  // Clock and reset
  input logic clk,
  input logic resetN,
  
  // Write side
  input logic write_en,
  input logic [DATA_WIDTH-1:0] write_data,
  output logic full,
  
  // Read side
  input logic read_en,
  output logic [DATA_WIDTH-1:0] read_data,
  output logic empty,
  
  // Optional: Status signals
  output logic [PTR_WIDTH-1:0] occupancy
);

  //============================================================================
  // STORAGE: Circular buffer
  //============================================================================
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  
  //============================================================================
  // POINTERS: Read and write pointers with wrap tracking
  //============================================================================
  logic [PTR_WIDTH-1:0] wr_ptr;     // Write pointer
  logic [PTR_WIDTH-1:0] rd_ptr;     // Read pointer
  logic [PTR_WIDTH-1:0] wr_ptr_next;  // Next write pointer (for full logic)
  
  //============================================================================
  // COMBINATIONAL LOGIC: Full and empty detection
  //============================================================================
  
  // Next write pointer value
  assign wr_ptr_next = (wr_ptr + 1) % (1 << PTR_WIDTH);
  
  // FULL: Next write position would equal read pointer
  // This means all entries are occupied
  assign full = (wr_ptr_next[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0]);
  
  // EMPTY: Write and read pointers are equal
  assign empty = (wr_ptr[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0]);
  
  // OCCUPANCY: Number of valid entries
  // (wr_ptr - rd_ptr) gives count considering wrap
  assign occupancy = wr_ptr[PTR_WIDTH-1:0] - rd_ptr[PTR_WIDTH-1:0];
  
  // READ DATA: Combinational output from memory
  assign read_data = mem[rd_ptr[PTR_WIDTH-2:0]];
  
  //============================================================================
  // SEQUENTIAL LOGIC: Pointer updates on clock edge
  //============================================================================
  
  always_ff @(posedge clk, negedge resetN) begin
    if (!resetN) begin
      wr_ptr <= '0;
      rd_ptr <= '0;
    end else begin
      
      // WRITE OPERATION
      if (write_en && !full) begin
        mem[wr_ptr[PTR_WIDTH-2:0]] <= write_data;
        wr_ptr <= wr_ptr_next;
      end
      
      // READ OPERATION
      if (read_en && !empty) begin
        rd_ptr <= (rd_ptr + 1) % (1 << PTR_WIDTH);
      end
      
    end
  end

  //============================================================================
  // ASSERTIONS: Protocol checking
  //============================================================================
  
  // Cannot write when full
  assert property (@(posedge clk) disable iff (!resetN)
    (write_en) |-> (!full)) else
    $error("Write attempted while FIFO is full!");
  
  // Cannot read when empty
  assert property (@(posedge clk) disable iff (!resetN)
    (read_en) |-> (!empty)) else
    $error("Read attempted while FIFO is empty!");

endmodule