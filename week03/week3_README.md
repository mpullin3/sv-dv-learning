# Week 3 Checkpoint 3: Parameterized 4-to-1 Multiplexer with Generate Statements

## Overview
Parameterized multiplexer that replicates 4x identical 4-to-1 mux logic using SystemVerilog generate statements. This week I learned about if/case statements, generate blocks, parameters, blocking vs. nonblocking assignments, concatenation and bit manipulation, and nested logic.

## Module: paramGenerate_mux
- **Parameters:** `Width` (default: 8 bits)
- **Inputs:** `in0, in1, in2, in3` (Width bits each), `sel` (2 bits)
- **Output:** `out` (Width*4 bits)

## Design Features
- Uses `generate` loop to replicate mux logic 4 times automatically
- Parameterized width for scalability (8-bit, 4-bit, 16-bit, any width)
- Nested ternary operators for selection logic
- Combinatorial logic (no clock needed)

## Verification
All 4 select values tested with assertions. Test patterns:
- sel=0: All 1s (in0)
- sel=1: All 0s (in1)
- sel=2: Upper half 1s, lower half 0s (in2)
- sel=3: Upper half 0s, lower half 1s (in3)

## Techniques Demonstrated
- Parameters and parameterization
- Generate statements for logic replication
- Nested ternary operators for multiplexing
- Professional assertions and testbenches