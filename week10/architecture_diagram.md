# FIFO Testbench Architecture Diagram

## High-Level UVM Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                    FIFO_TEST                                │
│         (orchestrates simulation)                           │
└────────────────────┬────────────────────────────────────────┘
                     │
         ┌───────────┴───────────────┐
         │                           │
    ┌────▼──────────────┐    ┌──────▼────────────┐
    │  FIFO_ENV         │    │  FIFO_AGENT       │
    │                   │    │                   │
    │ ┌───────────────┐ │    │ ┌──────────────┐  │
    │ │ SCOREBOARD    │ │    │ │ SEQUENCER    │  │
    │ │               │ │    │ ├──────────────┤  │
    │ │ Verifies      │ │    │ │ DRIVER       │  │
    │ │ data          │ │    │ ├──────────────┤  │
    │ │ integrity     │ │    │ │ MONITOR      │  │
    │ │               │ │    │ │              │  │
    │ │ Checks:       │ │    │ └──────────────┘  │
    │ │ - Expected    │ │    │                   │
    │ │   vs actual   │ │    │ Responsibilities: │
    │ │ - Data        │ │    │ - Generate       │
    │ │   mismatches  │ │    │   sequences      │
    │ │ - Statistics  │ │    │ - Drive DUT      │
    │ └───────────────┘ │    │ - Observe DUT    │
    │                   │    │                   │
    └───────────────────┘    └───────────────────┘
         │
    ┌────▼──────────────────────────────────┐
    │   FIFO_IF (Interface)                  │
    │ ┌──────────────────────────────────┐   │
    │ │ Write Signals:                   │   │
    │ │   - clk, resetN                  │   │
    │ │   - write_en, write_data         │   │
    │ │   - full                         │   │
    │ │                                  │   │
    │ │ Read Signals:                    │   │
    │ │   - read_en, read_data           │   │
    │ │   - empty, occupancy             │   │
    │ │                                  │   │
    │ │ Clocking Block:                  │   │
    │ │   @(posedge clk) for sync        │   │
    │ └──────────────────────────────────┘   │
    └────┬──────────────────────────────────┘
         │
    ┌────▼──────────────────────┐
    │   FIFO DUT (fifo.sv)       │
    │                            │
    │ ┌──────────────────────┐   │
    │ │ Circular Buffer      │   │
    │ │ [16 x 8-bit memory]  │   │
    │ │                      │   │
    │ │ Write Pointer (5-bit)│   │
    │ │ Read Pointer (5-bit) │   │
    │ │ Full/Empty Logic     │   │
    │ │ Occupancy Counter    │   │
    │ └──────────────────────┘   │
    └────────────────────────────┘
```

---

## Data Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    DATA FLOW                                 │
└──────────────────────────────────────────────────────────────┘

Sequence (generates transactions)
    │
    ├─ fifo_write_transaction: {data, write_delay}
    └─ fifo_read_transaction: {read_delay}
    │
    ▼
Sequencer (mediates via UVM handshake)
    │
    ├─ start_item() ──┐
    │                 │
    └─ finish_item()  │
    │                 │
    ▼                 ▼
Driver (applies stimulus)
    │
    ├─ Receives transaction from sequencer
    ├─ For writes: set write_en=1, write_data, wait for !full
    ├─ For reads: set read_en=1, wait for !empty
    │
    ▼
FIFO DUT
    │
    ├─ Writes: Store at mem[wr_ptr], increment wr_ptr
    ├─ Reads: Output mem[rd_ptr], increment rd_ptr
    ├─ Asserts full/empty flags
    ├─ Updates occupancy counter
    │
    ▼
Monitor (observes interface)
    │
    ├─ Samples write_en, write_data, full
    ├─ Samples read_en, read_data, empty
    ├─ Creates observation transactions
    │
    ├─ Write Analysis Port ──────┐
    │   (broadcast writes)       │
    │                            │
    └─ Read Analysis Port ───────┤
        (broadcast reads)        │
                                 │
                                 ▼
                            Scoreboard
                            │
                            ├─ write_fifo (internal queue)
                            │   Tracks expected values
                            │
                            ├─ read_fifo (internal queue)
                            │   Receives read observations
                            │
                            └─ Compare & report
                                - Expected vs actual
                                - Mismatches
                                - Pass/Fail verdict
```

---

## Component Responsibilities

### **FIFO_TEST**
```
├─ Instantiate environment
├─ Create and run sequences
├─ Control simulation flow
├─ Raise/drop objections
└─ Call report_phase for results
```

### **FIFO_ENV**
```
├─ Create FIFO_AGENT
├─ Create FIFO_SCOREBOARD
├─ Connect agent monitor to scoreboard
└─ Coordinate testbench components
```

### **FIFO_AGENT**
```
├─ Create FIFO_DRIVER
├─ Create FIFO_SEQUENCER
├─ Create FIFO_MONITOR
└─ Connect driver to sequencer
```

### **FIFO_DRIVER**
```
├─ Receive transactions from sequencer
├─ Apply stimulus to FIFO
├─ Respect full/empty flags (no protocol violations)
├─ Handle timing (wait cycles)
└─ Optional: Track performance metrics
```

### **FIFO_MONITOR**
```
├─ Passively observe interface
├─ Create write transaction observations
├─ Create read transaction observations
├─ Broadcast via analysis ports
└─ Optional: Track statistics
```

### **FIFO_SCOREBOARD**
```
├─ Receive write observations
├─ Track expected FIFO contents (internal queue)
├─ Receive read observations
├─ Compare expected vs actual
├─ Count mismatches
└─ Report results in report_phase
```

---

## Connection Diagram (Detailed)

```
FIFO_TEST
    │
    ├─ env.agent.sequencer ◄──── Sequence
    │                              (sends items)
    │
    ├─ env.agent.driver ◄────────┐
    │   (gets items from seq)     │
    │                            [UVM handshake]
    │
    └─ env.agent.monitor ────┐
        (observes interface) │
                            │
    env.scoreboard ◄────────┴─ write_ap (analysis port)
                           ├─ read_ap (analysis port)
                           │
                           ├─ write_fifo (internal)
                           ├─ read_fifo (internal)
                           └─ Compare & report
```

---

## Interface Signals

```
FIFO_IF {
  // Clock and reset
  logic clk;              // Clock (generated by testbench)
  logic resetN;           // Active-low reset
  
  // Write side
  logic write_en;         // Write enable (from driver)
  logic [7:0] write_data; // Data to write (from driver)
  logic full;             // FIFO full (from DUT)
  
  // Read side
  logic read_en;          // Read enable (from driver)
  logic [7:0] read_data;  // Data to read (from DUT)
  logic empty;            // FIFO empty (from DUT)
  
  // Status
  logic [4:0] occupancy;  // Number of entries (from DUT)
  
  // Clocking block for synchronization
  clocking cb @(posedge clk);
    output write_en, write_data;  // Driver outputs
    output read_en;
    input full, empty;            // DUT outputs
    input read_data, occupancy;
  endclocking;
}
```

---

## Execution Timeline

```
TIME:
0ns ─────────────────────────────────────────────────────────────
    │
    ├─ build_phase (create components)
    │
    ├─ connect_phase (wire components)
    │
    ├─ run_phase (execute stimulus)
    │  ├─ Sequence generates transactions
    │  ├─ Driver applies to FIFO
    │  ├─ Monitor observes + broadcasts
    │  ├─ Scoreboard checks
    │  └─ Coverage accumulates
    │
    ├─ extract_phase
    │
    ├─ check_phase
    │
    └─ report_phase (print results)

END_OF_SIMULATION
```

---

## Key Design Decisions

### **Single Bidirectional Agent** (not separate read/write agents)
- **Pro:** Simpler, fewer components to coordinate
- **Pro:** Adequate for synchronous FIFO
- **Con:** Less modular (but good for beginning)

### **Internal Scoreboard Queue Model**
- Scoreboard maintains its own FIFO queue
- Tracks expected behavior
- Compares against actual read_data
- **Pro:** Catches data integrity issues
- **Pro:** No need for external reference model

### **Dual Analysis Ports** (write_ap + read_ap)
- Monitor broadcasts writes and reads separately
- Scoreboard receives both
- **Pro:** More visibility into operations
- **Pro:** Easier to debug mismatches

---

**Status:** Architecture complete, ready for Week 11 implementation