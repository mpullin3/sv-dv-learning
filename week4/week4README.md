# Week 4 Checkpoint 4: 3-State Finite State Machine

## Overview
A 3-state FSM that demonstrates sequential state machine design and verification. States transition: IDLE → WAIT → ACTIVE → IDLE.

## Module: three_state_fsm
- **States:** IDLE (0), WAIT (1), ACTIVE (2)
- **Inputs:** `clk`, `resetN`, `start`
- **Output:** `active` (Moore output, 1 only in ACTIVE state)

## State Transitions
```
IDLE:   start=1 → WAIT, else stay IDLE
WAIT:   (always) → ACTIVE
ACTIVE: (always) → IDLE
```

## Design Features
- Asynchronous reset (resetN)
- State register (always_ff with non-blocking assignment)
- Next state logic (always_comb with case statement)
- Moore output logic (depends on state only)
- Standard FSM structure: 3 blocks (state register, next state, output)

## Verification
All 4 test cases pass:
- **Test 1:** Reset to IDLE, active=0 ✓
- **Test 2:** IDLE → WAIT transition on start=1 ✓
- **Test 3:** WAIT → ACTIVE auto-transition ✓
- **Test 4:** ACTIVE → IDLE auto-transition ✓

Waveform shows all state transitions with proper timing and output behavior.

## Techniques Demonstrated
- Multi-state FSM design
- Moore state machine output logic
- Professional testbench with assertions
- Waveform debugging and verification
- State coverage testing (3/3 states, all transitions tested)