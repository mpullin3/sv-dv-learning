# Week 5 Checkpoint 5: FSM Testbench with Assertions, Coverage & Constraints

## Overview
Advanced FSM verification demonstrating professional DV methodologies: assertions for correctness, coverage statements for verification completeness, and constraint-based randomization for robust testing. This checkpoint integrates interfaces, clocking blocks, assertions, and coverage — the core tools of hardware verification engineering.

## Module: three_state_fsm_covCon
- **States:** IDLE (0), WAIT (1), ACTIVE (2)
- **Inputs:** clk, resetN, start
- **Output:** active (Moore - 1 only in ACTIVE state)

## Testbench: tb_three_state_fsm_covCon
- **Note:** Please note that the module/tb file names were shortened when transferred from vs_code to github.

### Architecture
- **Interface + Clocking Block:** Bundles signals and synchronizes stimulus to clock
- **Constraint Class:** Randomizes `start` signal with weighted distribution (70% idle, 30% transitions)
- **Assertions:** Verify correctness (state validity, output accuracy)
- **Cover Statements:** Track coverage of all states, transitions, and output combinations
- **Formatted Output:** Professional $display debugging

### Test Phases

**Deterministic Tests (1-4):**
- Test 1: Verify reset to IDLE state
- Test 2: Test IDLE → WAIT transition
- Test 3: Test WAIT → ACTIVE transition
- Test 4: Test ACTIVE → IDLE transition
- Each test includes assertions and cover statements

**Randomized Stimulus Phase:**
- 50 cycles of random input respecting constraints
- Continuous assertions (state always valid)
- Continuous coverage tracking
- Formatted logging of all state changes

## Coverage Results

### State Coverage
- IDLE: 100% (covered)
- WAIT: 100% (covered)
- ACTIVE: 100% (covered)

### Transition Coverage
- IDLE→WAIT: 100% (covered)
- WAIT→ACTIVE: 100% (covered)
- ACTIVE→IDLE: 100% (covered)

### Output Coverage
- active=0: 100% (covered)
- active=1: 100% (covered)

**Overall: 100% functional coverage**

## Verification Techniques Demonstrated

### Assertions
- Verify state machine transitions work correctly
- Validate output matches expected values based on state
- Continuous assertions ensure state never becomes invalid

### Coverage
- Cover statements track which states were visited
- Identify all state transitions exercised
- Monitor output behavior in each state
- Measure verification completeness

### Constraints
- Randomize `start` signal with weighted distribution
- 70% probability idle (start=0)
- 30% probability transition (start=1)
- Realistic stimulus patterns

### Professional Patterns
- Interface bundles 4 signals into 1 reusable package
- Clocking block provides clean synchronization
- Blocking assignments for stimulus, direct reads for verification
- $display with format specifiers for organized output

## Waveform
Included waveform (checkpoint5.png) shows:
- All state transitions (0→1→2→0) repeated multiple times
- Randomized `start` signal respecting constraint distribution
- Correct `active` output behavior
- Clean clock and synchronization

## Files
- fsm_covCon.sv: FSM module
- tb_fsm_covCon.sv: Testbench with assertions, cover, constraints
- coverageReport.md: Coverage metrics and results
- checkpoint5.png: Waveform screenshot

## Skills Mastered
- Interfaces and modports for clean testbench architecture
- Clocking blocks for professional synchronization
- Assertions and coverage for verification methodology
- Constraints and randomization for robust testing
- Professional formatted output for debugging
- Integration of multiple verification techniques into one testbench