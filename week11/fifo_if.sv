//============================================================================
// FIFO INTERFACE
// Bundles all FIFO signals and provides clocking block
//============================================================================

interface fifo_if #(int DATA_WIDTH = 8);
  
  // Clock and reset
  logic clk;
  logic resetN;
  
  // Write side
  logic write_en;
  logic [DATA_WIDTH-1:0] write_data;
  logic full;
  
  // Read side
  logic read_en;
  logic [DATA_WIDTH-1:0] read_data;
  logic empty;
  
  // Status
  logic [4:0] occupancy;  // For 16 deep FIFO
  
  //============================================================================
  // CLOCKING BLOCK: Synchronizes testbench to clock
  //============================================================================
  clocking cb @(posedge clk);
    // Testbench drives these outputs
    output write_en, write_data;
    output read_en;
    
    // Testbench reads these inputs
    input full, empty;
    input read_data, occupancy;
  endclocking
  
  //============================================================================
  // MODPORT: Defines what each component can access
  //============================================================================
  
  // Driver modport (drives write/read, reads flags)
  modport driver (
    clocking cb,
    input full, empty, occupancy
  );
  
  // Monitor modport (observes everything, doesn't drive)
  modport monitor (
    input clk, resetN,
    input write_en, write_data, full,
    input read_en, read_data, empty, occupancy
  );
  
  // Passive modport (for passive observers)
  modport passive (
    input clk, resetN,
    input write_en, write_data, full,
    input read_en, read_data, empty, occupancy
  );

endinterface