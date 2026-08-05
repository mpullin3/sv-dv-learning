# Week 2 Checkpoint 2: 8-bit Shift Register Verification

## Overview
Comprehensive testbench for 8-bit shift register using professional verification techniques.
This weeks learning covered clock generation patterns, Loops and Stimulus, assertions, functions and tasks, 
randomization, and waveform debugging.

## Module: shift_register_8bit
- Captures 8-bit input on each clock edge
- Asynchronous active-low reset
- Synchronous operation on clock edges

## Testbench Features
- **Random stimulus generation** — 16 random test vectors automatically generated
- **Helper task** — `repeat(16) begin encapsulates test logic
- **Assertions** — Automatic verification of correct behavior
- **Waveform validation** — VCD dump for visual verification

## Verification Results
All 16 random tests passed with assertions.

## Waveform
random.png

Shows random input patterns flowing through shift register with correct output matching.

## Techniques Demonstrated
- Loop-based stimulus generation
- Helper tasks for code reuse
- Assertions for automatic checking
- Random value generation with `$random`