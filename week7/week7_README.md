# Week 7: UVM Fundamentals & Architecture

## Overview

Week 7 marks my transition from SystemVerilog basics to industry-standard verification methodology. UVM (Universal Verification Methodology) is the framework used by every major semiconductor company. This week covers UVM's philosophy, class hierarchy, and component architecture.

## Why UVM Exists

**Problem:** Every testbench was custom, one-off code. No reusability across projects.

**Solution:** UVM provides a standardized framework where components are reusable across projects, teams, and companies.

**Benefit:** Write a UART driver once, use it on 10 projects. Write once, use infinitely.

---

## Daily Content Breakdown

### Monday 7/7: UVM Overview

**Key Concepts:**
- UVM = Universal Verification Methodology (standardized framework on top of SystemVerilog)
- Solves reusability problem (components shared across projects)
- Built on base classes that provide common functionality
- Industry standard at NVIDIA, Apple, AMD, Intel, etc.

**UVM Philosophy:**
- Modularity: Each component does one job
- Reusability: Write once, use many times
- Hierarchy: Components contain sub-components
- Configuration: Change behavior without rewriting code
- Automation: UVM handles scheduling and communication

---

### Tuesday 7/8: Class Hierarchy

**Base Classes:**

| Class | Purpose | Usage |
|-------|---------|-------|
| uvm_object | Foundation for all UVM classes | Data packets, configurations |
| uvm_component | Extends uvm_object, adds hierarchy | Testbench structures (drivers, agents, env) |
| uvm_env | Top-level container | Orchestrates all verification components |
| uvm_agent | Protocol bundle | Driver + sequencer + monitor for one protocol |
| uvm_driver | Applies stimulus | Drives DUT inputs via interface |
| uvm_sequencer | Generates sequences | Coordinates between test sequences and driver |
| uvm_monitor | Observes outputs | Passive observation, broadcasts data |
| uvm_scoreboard | Compares results | Expected vs actual verification |

**Key Distinction:**
- Use `uvm_object` for passive data (transactions, packets, config)
- Use `uvm_component` for active logic (drivers, monitors, scoreboards)

**UVM Phases (Execution Order):**
1. build() — Create components
2. connect() — Wire components together
3. end_of_elaboration() — Final setup
4. start_of_simulation() — Print banners
5. run() — Execute test
6. extract() — Gather coverage
7. check() — Final assertions
8. report() — Print results
9. final() — Cleanup

---

### Wednesday 7/9: uvm_env & uvm_agent

**uvm_env (Environment):**
- Top-level container orchestrating all verification
- Creates agents, scoreboard, coverage collectors
- Connects components together
- Passes configuration to sub-components
- Think of it as the "testbench director"

**uvm_agent (Agent):**
- Reusable bundle for one protocol
- Contains: driver, sequencer, monitor, configuration
- Can be active (has driver) or passive (monitor only)
- Controlled by environment's configuration
- Think of it as "everything needed to verify one UART port"

**Multiple Agents Pattern:**
- Environment with 2+ agents for different protocols
- Each agent operates independently
- Environment wires them together
- Real design: CPU core agents + memory controller agents + I/O agents

**Configuration Pattern:**
- Environment creates configuration object
- Stores in uvm_config_db (global database)
- Agents retrieve configuration during build_phase
- Allows behavior changes without rewriting code

---

### Thursday 7/10: uvm_driver & uvm_monitor

**Virtual Interfaces:**
- Reference to actual interface (not instance)
- Allows testbench components to access interface signals
- Pattern: Top-level instantiates interface, passes virtual reference to driver/monitor

**uvm_driver:**
- Applies stimulus to DUT via virtual interface
- Pulls transactions from sequencer via handshake
- Forever loop: get_next_item() → drive to DUT → item_done()
- Synchronous operation tied to clock edge
- Handles reset safely

**Handshake Pattern:**
1. Sequencer creates transaction
2. Sequencer sends to driver via seq_item_port.get_next_item()
3. Driver receives and applies to DUT
4. Driver waits for completion
5. Driver tells sequencer: item_done()
6. Loop repeats

**uvm_monitor:**
- Passive observation of DUT outputs
- Doesn't drive anything
- Broadcasts observations via analysis_port (ap)
- Connected to scoreboard in environment
- Can collect coverage on observed behavior

**Analysis Port (ap):**
- Broadcast mechanism
- Monitor sends: ap.write(transaction)
- Listeners receive: scoreboard, coverage, etc.
- Connection happens in environment's connect_phase()

---

### Friday 7/11: uvm_sequencer & uvm_sequence

**uvm_sequencer:**
- Mediator between sequences and driver
- Manages handshake between them
- Provides seq_item_export for driver
- Provides seq_item_port for sequences
- Same sequencer works with all sequence/driver pairs

**uvm_sequence:**
- Generates stimulus (transactions)
- Has task body() that runs
- Uses start_item() → finish_item() handshake
- Can randomize with constraints
- Can have procedural logic (loops, conditionals)
- Reusable across projects

**Sequence Handshake:**
1. start_item(transaction) — "Driver, ready?"
2. (Wait for driver readiness)
3. finish_item() returns — "Driver completed"

**Sequence Types:**
- Basic random sequence (randomize each transaction)
- Constrained sequence (randomize with constraints)
- Procedural sequence (complex logic, decision-making)
- Virtual sequence (coordinates multiple agents)
- Sequence library (base class + specific sequences)

**Key Feature:**
- Sequences control WHAT to send (transaction content)
- Sequences control WHEN to send (pacing)
- Driver applies HOW to send (interface details)
- Separation of concerns = reusability

---

### Saturday 7/12: uvm_scoreboard & Checking

**uvm_scoreboard:**
- Compares expected vs actual results
- Referee that flags rule violations
- Uses analysis FIFOs to buffer transactions
- Runs comparison loop in run_phase()
- Reports mismatches via `uvm_error`

**Analysis FIFO:**
- TLM (Transaction Level Modeling) analysis FIFO
- Buffers transactions from driver/monitor
- Prevents data loss if monitor faster than scoreboard
- Get/put interface for retrieval

**Comparison Patterns:**
- Immediate comparison (expected vs actual)
- Prediction-based (compute expected, compare)
- State-machine verification (track valid sequences)
- Multiple parallel checkers (fork/join_none)

**Professional Error Reporting:**
- Include timestamp
- Show both expected and actual values
- Count/summarize errors
- Print final verdict in report_phase()

**Connection Pattern (in environment):**
- Driver.ap → Scoreboard.expected_fifo
- Monitor.ap → Scoreboard.actual_fifo
- Scoreboard compares both streams

**Scoreboard can also:**
- Collect coverage on verified transactions
- Track state machine sequences
- Implement complex prediction logic
- Generate final test pass/fail verdict

---

## UVM Component Hierarchy (Visual)

```
uvm_env (Environment)
├── Config (uvm_object - not a component)
├── Agent1 (uvm_agent - active)
│   ├── Driver (uvm_driver)
│   ├── Sequencer (uvm_sequencer)
│   └── Monitor (uvm_monitor)
├── Agent2 (uvm_agent - passive)
│   └── Monitor (uvm_monitor)
├── Scoreboard (uvm_scoreboard)
└── Coverage Collector (uvm_subscriber)
```

---

## Key Patterns Learned

### 1. Component Creation & Connection

**Build Phase:** Create all components
**Connect Phase:** Wire them together
**Run Phase:** Execute test logic

### 2. Stimulus Generation

Sequence → Sequencer → Driver → DUT

### 3. Response Verification

Monitor → Analysis Port → Scoreboard → Comparison

### 4. Configuration Management

Environment creates config → uvm_config_db stores it → Components retrieve during build

### 5. Handshake Communication

Driver: get_next_item() ← → Sequencer: item_done()

---

## Summary

Week 7 covered UVM's architecture and philosophy. I learned:
- What UVM is and why it matters
- How classes organize (hierarchy)
- How environments orchestrate components
- How agents bundle protocol verification
- How drivers apply stimulus
- How monitors observe response
- How sequencers and sequences generate tests
- How scoreboards verify correctness

**Next week:** I'll implement all of this into a working UVM testbench.

---

## Resources

- UVM 1.2 Reference Manual (official spec)

## Notes

This week focused entirely on conceptual understanding. No coding, no checkpoints — pure learning of framework architecture. 