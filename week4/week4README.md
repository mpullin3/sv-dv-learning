# Week 4 Checkpoint 4: 3-State Finite State Machine

## Overview
A 3-state FSM demonstrating multi-state machine design. States: IDLE → WAIT → ACTIVE → IDLE.

## Module: three_state_fsm
- **States:** IDLE (0), WAIT (1), ACTIVE (2)
- **Inputs:** clk, resetN, start
- **Output:** active (Moore - 1 only in ACTIVE state)

## State Transitions
- IDLE: start=1 → WAIT, else stay IDLE
- WAIT: (always) → ACTIVE
- ACTIVE: (always) → IDLE

## Design Features
- Asynchronous reset
- State register (always_ff, non-blocking)
- Next state logic (always_comb, case statement)
- Moore output logic (depends on state only)
- Standard 3-block FSM structure

## Verification
All 4 tests pass:
- Test 1: Reset to IDLE, active=0 ✓
- Test 2: IDLE → WAIT on start=1 ✓
- Test 3: WAIT → ACTIVE auto-transition ✓
- Test 4: ACTIVE → IDLE auto-transition ✓

Waveform screenshot shows all state transitions and timing.

## Skills Demonstrated
- Multi-state FSM design
- Moore output logic
- Professional testbench with assertions
- State coverage (3/3 states tested)
- Waveform verification