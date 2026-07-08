# Week 6 Checkpoint 6: Dual-Port RAM with Professional Code Style

## Overview
A dual-port RAM demonstrating independent read/write access from two simultaneous ports sharing the same memory array. This checkpoint integrates all SystemVerilog fundamentals from Weeks 1-6 and introduces professional code review practices, naming conventions, and documentation standards.

## Module: dual_port_ram

**Parameters:**
- `ADDR_WIDTH` (default: 4) — Address bus width, supports 2^ADDR_WIDTH locations
- `DATA_WIDTH` (default: 8) — Data bus width in bits
- `DEPTH` (default: 16) — Total number of memory locations

**Ports:**
- **Port A:** Independent read/write access (addr_a, write_data_a, write_enable_a, read_data_a)
- **Port B:** Independent read/write access (addr_b, write_data_b, write_enable_b, read_data_b)
- **Control:** clk (synchronous), resetN (asynchronous active-low)

## Behavior

**Synchronous Operation:**
- Both reads and writes occur on clock edge
- Port A and Port B operate independently and simultaneously
- Both ports access the same shared memory array
- Reads return data from previous cycle (pipeline)

**Memory Access:**
- Write: `mem[addr] <= write_data` when write_enable=1
- Read: `read_data <= mem[addr]` every clock cycle
- Both operations can happen simultaneously on different or same addresses

**Reset:**
- Active-low async reset clears read_data outputs
- Memory array retains values through reset (realistic for actual RAM)

## Verification

**Test 1: Port A Write, Port B Read**
- Verify cross-port reading works correctly
- Port A writes 0xAA to address 5
- Port B reads address 5 and verifies value matches
- Tests inter-port communication

**Test 2: Independent Simultaneous Writes**
- Port A writes 0x11 to address 3
- Port B writes 0x22 to address 7 (same cycle)
- Verify both writes succeed without conflict
- Tests true dual-port capability

**Test 3: Both Ports Read Same Address**
- Port A writes 0x99 to address 10
- Both ports read address 10 simultaneously
- Verify both get identical value
- Tests shared memory coherency

## Code Quality

### Naming Conventions Applied
- **Signals:** Lowercase with underscores (addr_a, write_enable_a)
- **Active-low:** Suffix _n (resetN)
- **Constants:** UPPERCASE (ADDR_WIDTH, DATA_WIDTH, DEPTH)
- **Module:** PascalCase (dual_port_ram)

### Professional Practices
- **Parameters:** Design is fully parameterized for reusability
- **Port mapping:** Named instantiation in testbench
- **Comments:** Explain WHY the dual-port array works
- **Formatting:** Consistent 2-space indentation
- **Assertions:** Clear error messages on failure
- **Organization:** Logical flow (parameters → ports → signals → logic)

### Documentation
- Module header explains purpose and ports
- Comments describe dual-write synchronization in always_ff block
- Testbench organized by test case with descriptive output
- VCD generation enabled for waveform analysis

## Waveform Analysis

The generated VCD shows:
- **Clock:** Regular synchronization edge
- **Reset:** Asynchronous reset release
- **Port A signals:** Address, write data, write enable, read data
- **Port B signals:** Identical structure, independent operation
- **Memory access:** Correct read/write timing across both ports
- **No conflicts:** Simultaneous operations succeed without interference

## Skills Demonstrated

✅ **Multi-port design:** Managing multiple independent access paths to shared resource
✅ **Synchronous logic:** Clock-edge triggered reads and writes
✅ **Memory modeling:** Array-based memory with address decoding
✅ **Assertions:** Verifying correctness across multiple test scenarios
✅ **Professional style:** Applying naming conventions, comments, and organization
✅ **Self-review:** Creating code style guide for own work
✅ **Waveform debugging:** Analyzing complex dual-port behavior visually

## Files

- `dual_port_ram.sv` — Dual-port RAM module with parameterized width/depth
- `tb_dual_port_ram.sv` — Comprehensive testbench with 3 test cases and assertions
- `checkpoint6.md` — Personal code review document detailing best practices applied
- `dualPortRam.png` — Waveform screenshot showing all port operations

## Summary

Checkpoint 6 marks the transition from learning individual SystemVerilog features to designing real hardware components with professional engineering practices. I've built modules with parameters, testbenches with multiple test vectors, assertions for verification, and documented my own code style. These are skills that directly transfer to production hardware verification teams.
