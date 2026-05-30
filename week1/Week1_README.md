# Week 1: SystemVerilog Fundamentals

## Overview
This folder contains five SystemVerilog modules demonstrating basic hardware design concepts: combinatorial logic, sequential logic, and testbench verification.

## Modules

### 1. Adder (4-bit)
- **File:** `adder.sv`, `adder_tb.sv`
- **Description:** Adds two 4-bit numbers plus carry-in
- **Features:** Combinatorial logic, basic arithmetic

### 2. AND Gate (4-bit)
- **File:** `and_4bit.sv`, `and_4bit_tb.sv`
- **Description:** Bitwise AND of two 4-bit inputs
- **Features:** Basic logic gate, simple testbench

### 3. 2x1 Multiplexer (8-bit)
- **File:** `mux_2x1.sv`, `mux_2x1_tb.sv`
- **Description:** Selects between two 8-bit inputs
- **Features:** Ternary operator, data routing

### 4. 3:8 Decoder
- **File:** `decoder_3to8.sv`, `decoder_3to8_tb.sv`
- **Description:** Converts 3-bit select to 8 one-hot outputs
- **Features:** Shift operator, combinatorial logic

### 5. 4-bit Counter (Checkpoint 1)
- **File:** `counter_4bit.sv`, `counter_4bit_tb.sv`
- **Description:** Synchronous counter with asynchronous reset
- **Features:** Sequential logic, always_ff, clock-driven behavior

## Checkpoint 1: 4-bit Counter

### Module Behavior
- **Inputs:** 
  - `clk` — Rising edge increments counter
  - `resetN` — Active-low asynchronous reset
- **Output:** 
  - `count[3:0]` — 4-bit counter (0-15, then wraps)

### How It Works
1. When `resetN = 0`, counter is cleared to 0 (asynchronous)
2. When `resetN = 1`, counter increments on each rising clock edge
3. Counts: 0 → 1 → 2 → ... → 15 → 0 (wraps around)

### Verification
Testbench runs 8 clock cycles after reset release. Counter increments 0→1→2→3→4→5→6→7.

### Waveform
counter_4bit_waveform.png

**Observations:**
- Time 0-20ns: 'resetN = 0` (active low), counter held at 0
- Time 20ns+: `resetN = 1` (released)
- Counter increments on rising clock edges (every 20ns)
- Count values: 0, 1, 2, 3, 4, 5, 6, 7 match expected behavior 

## Key Concepts Learned

### Week 1
- Data types: `logic` (4-state) vs `bit` (2-state)
- Combinatorial logic: `assign`, `always_comb`
- Sequential logic: `always_ff`, `@(posedge)`, `negedge`
- Testbench structure and stimulus generation
- Waveform analysis with EPWave

### Files
All modules synthesizable. Testbenches use non-synthesizable constructs (`$display`, `$finish`).

## How to Run
1. Copy `counter_4bit.sv` and `counter_4bit_tb.sv` to EDA Playground
2. Check "Open EPWave after run"
3. Click Run
4. View waveform in EPWave viewer

## Summary
Week 1 establishes SystemVerilog fundamentals: writing modules, creating testbenches, and verifying behavior with waveforms. Ready for Week 2: advanced testbenches and UVM introduction.