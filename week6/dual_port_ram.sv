// Code your design here
module dual_port_ram #(
  parameter int ADDR_WIDTH = 4,
  parameter int DATA_WIDTH = 8,
  parameter int DEPTH = 16
) (
  input logic clk,
  input logic resetN,
  
  input logic [ADDR_WIDTH-1:0] addr_a,
  input logic [DATA_WIDTH-1:0] write_data_a,
  input logic write_enable_a,
  output logic [DATA_WIDTH-1:0] read_data_a,
  
  input logic [ADDR_WIDTH-1:0] addr_b,
  input logic [DATA_WIDTH-1:0] write_data_b,
  input logic write_enable_b,
  output logic [DATA_WIDTH-1:0] read_data_b
);

  logic [DATA_WIDTH-1:0] mem [DEPTH];
  
  // SINGLE always_ff block for both ports
  always_ff @(posedge clk, negedge resetN) begin
    if (!resetN) begin
      read_data_a <= 0;
      read_data_b <= 0;
    end else begin
      if (write_enable_a)
        mem[addr_a] <= write_data_a;
      if (write_enable_b)
        mem[addr_b] <= write_data_b;
      
      read_data_a <= mem[addr_a];
      read_data_b <= mem[addr_b];
    end
  end
  
endmodule