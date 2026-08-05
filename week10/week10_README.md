# Week 10: FIFO Design & Planning

## Overview

Week 10 focuses on FIFO module design and verification planning. This is the foundation for Weeks 11-14 where I build and verify a complete testbench for a synchronous FIFO.

**Status:** Checkpoint 10 Complete ✅
- FIFO RTL designed
- Verification plan written
- Coverage strategy documented
- Testbench architecture planned
- Ready for implementation (Week 11)

---

## Daily Breakdown

### **Monday 7/27: FIFO Architecture**
- Learned synchronous FIFO fundamentals
- Understood circular buffer design
- Studied pointer logic and wraparound
- Learned full/empty flag mechanics
- **Deliverable:** Conceptual understanding documented

### **Tuesday 7/28: FIFO RTL Implementation**
- Designed parameterized FIFO module
- Implemented read/write pointer logic
- Created full/empty detection
- Added assertions for protocol validation
- **Deliverable:** `fifo.sv` (200 lines of production RTL)

### **Wednesday 7/29: Verification Plan**
- Defined 9 test scenarios
- Set coverage targets (>80%)
- Planned assertion strategy
- Documented success criteria
- **Deliverable:** `verification_plan.md`

### **Thursday 7/30: Testbench Architecture**
- Designed UVM component hierarchy
- Planned env → agent → driver/monitor/scoreboard structure
- Created transaction types (write/read)
- Documented data flow
- **Deliverable:** `architecture_diagram.md`

### **Friday 7/31: Sequences & Transactions**
- Designed 7 sequence types (write, read, mixed, stress, constrained, burst, full-drain)
- Created transaction hierarchy
- Documented randomization and constraints
- **Deliverable:** Sequence/transaction code examples

### **Saturday 8/1: Coverage Plan**
- Documented all coverage points (address, data, flags, operations, state, occupancy)
- Set coverage targets and milestones
- Planned gap analysis and mitigation
- **Deliverable:** `coverage_plan.md`

### **Sunday 8/2: Checkpoint 10 Push**
- Consolidated all files
- Pushed to GitHub `/week10` folder
- Created comprehensive README
- **Deliverable:** GitHub checkpoint with 6 files

---

## Deliverables

### **Files in This Checkpoint**

1. **FIFO.sv** (200 lines)
   - Synchronous FIFO module
   - 16-deep, 8-bit data
   - Read/write pointers with wraparound
   - Full/empty flags
   - Occupancy counter
   - Assertions for protocol checking

2. **VerificationPlan.md**
   - 9 test scenarios described
   - Coverage points identified
   - Success criteria defined
   - Known risks and mitigations
   - Testbench architecture overview

3. **CoveragePlan.md**
   - Address coverage strategy
   - Data pattern coverage
   - Flag behavior tracking
   - Operation coverage
   - State machine transitions
   - Occupancy level tracking
   - Coverage targets (>80%)

4. **simple_tb.sv**
   - Basic elaboration testbench
   - Demonstrates FIFO instantiation
   - Simple write/read operations
   - VCD dump capability
   - **Purpose:** Proof-of-concept that RTL elaborates

5. **architecture_diagram.md**
   - UVM component hierarchy ASCII diagram
   - Data flow diagram
   - Component responsibilities
   - Connection details
   - Interface signals
   - Execution timeline

6. **week10_README.md** (this file)
   - Week 10 overview
   - Daily breakdown
   - Deliverables summary
   - Next steps

---

## FIFO RTL Summary

### **Module Signature**
```systemverilog
module fifo #(
  parameter int DEPTH = 16,
  parameter int DATA_WIDTH = 8,
  parameter int PTR_WIDTH = $clog2(DEPTH) + 1
) (
  input logic clk, resetN,
  input logic write_en, logic [DATA_WIDTH-1:0] write_data,
  output logic full,
  input logic read_en,
  output logic [DATA_WIDTH-1:0] read_data,
  output logic empty,
  output logic [PTR_WIDTH-1:0] occupancy
);
```

### **Key Features**
- ✅ Circular buffer (16 x 8-bit memory)
- ✅ Independent read/write pointers
- ✅ Full flag (prevents overwrite)
- ✅ Empty flag (prevents read of stale data)
- ✅ Occupancy counter
- ✅ Simultaneous read/write capability
- ✅ Protocol assertions

### **Design Patterns**
- Pointer width = log2(DEPTH) + 1 (enables wrap detection)
- Address = pointer[PTR_WIDTH-2:0] (lower bits)
- Full = wr_ptr_next == rd_ptr
- Empty = wr_ptr == rd_ptr
- Supports parameterized depth and width

---

## Verification Strategy

### **Test Scenarios (9 Total)**
1. Basic write sequence (fill FIFO)
2. Basic read sequence (drain FIFO)
3. Mixed read/write (concurrent)
4. Pointer wraparound (circular behavior)
5. Back-to-back operations (rapid stimulus)
6. Edge cases (boundaries, single items)
7. Stress test (1000+ operations)
8. Full/empty transitions (flag timing)
9. Protocol violations (assertion checking)

### **Coverage Goals**
- Address coverage: 100%
- Data patterns: >80%
- Flags: 100%
- Operations: >85%
- State machine: 100%
- Occupancy: >85%
- Edge cases: >90%
- **Overall target: >80%**

### **Assertion Strategy**
- No write when full
- No read when empty
- Data integrity (written value = read value)
- Occupancy correctness

---

## Testbench Architecture (UVM)

### **Components**
```
FIFO_TEST
├─ FIFO_ENV
│  ├─ FIFO_AGENT
│  │  ├─ FIFO_DRIVER (applies stimulus)
│  │  ├─ FIFO_SEQUENCER (mediates sequences)
│  │  └─ FIFO_MONITOR (observes interface)
│  └─ FIFO_SCOREBOARD (verifies correctness)
└─ Sequences (write, read, mixed, stress, etc.)
```

### **Data Flow**
```
Sequence → Sequencer → Driver → FIFO DUT → Monitor → Scoreboard
                                                          (pass/fail)
```

### **Key Design Decisions**
- Single bidirectional agent (simpler than separate read/write agents)
- Scoreboard maintains internal FIFO queue (reference model)
- Dual analysis ports (write_ap, read_ap) for visibility
- Parameterized transactions (write_txn, read_txn)

---

## Sequence Types

### **Basic Sequences (Weeks 11)**
- `fifo_write_sequence` — Deterministic writes
- `fifo_read_sequence` — Deterministic reads
- `fifo_mixed_sequence` — Random read/write

### **Advanced Sequences (Week 12)**
- `fifo_constrained_write_sequence` — Target value ranges
- `fifo_burst_sequence` — Sequential addresses
- `fifo_full_drain_sequence` — Fill then empty
- `fifo_stress_sequence` — 100+ random operations
- `fifo_weighted_sequence` — Biased read/write ratio

---

## Coverage Points

### **Address Coverage**
- All 16 addresses exercised
- Boundary addresses (0, 15)
- Wraparound behavior

### **Data Coverage**
- All zeros (0x00)
- All ones (0xFF)
- Mid-range values
- Bit patterns

### **Flag Coverage**
- Full flag assertion/deassertion
- Empty flag transitions
- Flag timing accuracy

### **Operation Coverage**
- Single writes/reads
- Sequential operations
- Simultaneous read/write
- Back-to-back operations

### **State Coverage**
- Empty → Partial → Full
- Full → Partial → Empty
- State transitions

### **Occupancy Coverage**
- Empty (0)
- Quarter-full (1-4)
- Half-full (5-8)
- Three-quarter (9-12)
- Almost-full (13-15)
- Full (16)

---

## Next Steps (Week 11)

### **Monday 8/3: Environment & Agent Setup**
- Build FIFO_ENV and FIFO_AGENT
- Create FIFO_IF interface
- Set up configuration database

### **Tuesday 8/4: Transactions**
- Finalize fifo_write_transaction
- Finalize fifo_read_transaction
- Test randomization

### **Wednesday 8/5: Driver & Sequencer**
- Build FIFO_DRIVER
- Implement sequencer handshake
- Test stimulus application

### **Thursday 8/6: Monitor**
- Build FIFO_MONITOR
- Implement observation logic
- Set up analysis ports

### **Friday 8/7: Basic Sequences**
- Build write_sequence
- Build read_sequence
- Build mixed_sequence

### **Saturday 8/8: Test Class**
- Build base test
- Implement run_phase
- Add objections

### **Sunday 8/9: Checkpoint 11**
- Testbench elaborates
- Basic sequences run
- Push to GitHub

---

## Current Status

**Week 10:** ✅ Complete
- RTL designed (fifo.sv)
- Verification planned (verification_plan.md)
- Coverage strategy (coverage_plan.md)
- Architecture documented (architecture_diagram.md)
- Ready for implementation

**Week 11:** ⏳ Next
- Testbench structure (Mon-Sat)
- Elaboration verification (Sun)

**Weeks 12-14:** Future
- Full verification (Week 12)
- Documentation & polish (Week 13)
- Final integration & testing (Week 14)

---

## Key Files

| File | Lines | Purpose |
|------|-------|---------|
| fifo.sv | 200 | RTL module |
| VerificationPlan.md | 300 | Test strategy |
| CoveragePlan.md | 400 | Coverage measurement |
| simple_tb.sv | 100 | Elaboration test |
| architecture_diagram.md | 250 | UVM structure |
| week10_README.md | 300 | This overview |

**Total:** ~1,550 lines of documentation + code

---

## Lessons Learned

**Week 10 Takeaways:**
1. Plan verification before coding
2. Define coverage upfront
3. Design architecture for reusability
4. Document everything
5. Test plan drives implementation

---

**Status:** Week 10 Complete, Week 11 Ready to Start  
**Commit:** Checkpoint 10 pushed to GitHub  
**Next Phase:** Testbench implementation (Week 11)