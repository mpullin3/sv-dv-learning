# FIFO Verification Plan

## DUT Overview

**Module:** `fifo.sv`
- Synchronous FIFO (single clock domain)
- Parameterized: DEPTH=16, DATA_WIDTH=8
- Circular buffer with read/write pointers
- Full/empty flags, occupancy counter

---

## Verification Objectives

**Primary Goals:**
- ✅ Verify write operations when not full
- ✅ Verify read operations when not empty
- ✅ Verify full flag assertion and prevention
- ✅ Verify empty flag assertion
- ✅ Verify simultaneous read/write capability
- ✅ Verify pointer wraparound behavior
- ✅ Verify data integrity (write X → read X)
- ✅ Verify occupancy counting

---

## Test Scenarios (9 Total)

### **Scenario 1: Basic Write Sequence**
- Fill FIFO with sequential values
- Verify full flag asserts when full
- Verify data stored correctly
- Verify wr_ptr increments

**Coverage:**
- All addresses (0-15)
- Full flag behavior

### **Scenario 2: Basic Read Sequence**
- Read from populated FIFO
- Verify empty flag asserts when empty
- Verify data read matches written
- Verify rd_ptr increments

**Coverage:**
- All addresses (0-15)
- Empty flag behavior

### **Scenario 3: Mixed Read/Write**
- Simultaneous read and write
- Verify both pointers move independently
- Verify full/empty flags update correctly

**Coverage:**
- Concurrent operations
- Pointer independence

### **Scenario 4: Pointer Wraparound**
- Fill FIFO, read some, write more
- Verify pointers wrap at DEPTH boundary
- Verify wrap doesn't break full/empty detection

**Coverage:**
- Pointer MSB tracking
- Wrap arithmetic

### **Scenario 5: Back-to-Back Operations**
- Continuous writes without waiting
- Continuous reads without waiting
- Verify FIFO handles rapid operations

**Coverage:**
- Stress testing
- Timing sensitivity

### **Scenario 6: Edge Cases**
- Write single item, read immediately
- Fill to exactly full, drain to empty
- Alternating single read/write pairs
- Maximum occupancy transitions

**Coverage:**
- Boundary conditions
- State transitions

### **Scenario 7: Stress Test**
- Random read/write for 1000+ cycles
- Varying write/read enable patterns
- Verify no data loss or corruption

**Coverage:**
- Extended operation
- Random patterns

### **Scenario 8: Full/Empty Transitions**
- Fill → full flag
- Drain → empty flag
- Fill → empty → fill again
- Verify flags are timing-accurate

**Coverage:**
- Flag timing
- State machine transitions

### **Scenario 9: Protocol Violations (Error Detection)**
- Attempt write while full (should be blocked)
- Attempt read while empty (should be blocked)
- Verify assertions catch violations

**Coverage:**
- Protocol compliance
- Assertion effectiveness

---

## Verification Metrics

### **Functional Coverage Points**

**Address Coverage:**
- Low addresses (0-7)
- High addresses (8-15)
- Boundary addresses (0, 15)

**Data Coverage:**
- All zeros (0x00)
- All ones (0xFF)
- Mid-range values (0x01-0xFE)

**Operation Coverage:**
- Writes (with/without full)
- Reads (with/without empty)
- Simultaneous r/w
- Pointer wraparounds

**State Coverage:**
- Empty state transitions
- Full state transitions
- Partial occupancy transitions

### **Coverage Goals**

| Metric | Target |
|--------|--------|
| Address coverage | 100% |
| Data pattern coverage | >80% |
| Operation combinations | >90% |
| Full state exercise | 100% |
| Empty state exercise | 100% |
| Wraparound scenarios | 100% |

---

## Assertion Strategy

### **Protocol Assertions**

```systemverilog
// No write when full
assert_no_write_when_full:
  if (write_en) → !full;

// No read when empty
assert_no_read_when_empty:
  if (read_en) → !empty;

// Data consistency
assert_data_integrity:
  written_data[addr] == read_data[addr];

// Occupancy correctness
assert_occupancy_valid:
  occupancy == (wr_ptr - rd_ptr);
```

---

## Test Plan Timeline

### **Week 11: Testbench Structure**
- Build UVM components
- Implement basic sequences
- Get elaboration working
- ~40 tests run, basic pass/fail

### **Week 12: Advanced Testing**
- Add coverage tracking
- Implement constrained sequences
- Stress testing
- Regression suite
- >80% coverage

---

## Verification Approach

### **Stimulus Generation**
- **Basic sequences:** Deterministic writes/reads
- **Random sequences:** Constrained random r/w
- **Directed sequences:** Target specific scenarios
- **Stress sequences:** High-volume patterns

### **Observation**
- Monitor both read and write ports
- Track full/empty flag timing
- Collect occupancy data

### **Checking**
- Scoreboard verifies data integrity
- Assertions catch protocol violations
- Coverage metrics track completeness

### **Success Criteria**
- ✅ All 9 test scenarios pass
- ✅ Coverage >80%
- ✅ Zero assertion failures
- ✅ Data integrity verified

---

## Known Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Simulator unavailable | Can't test | Use for conceptual work first |
| Pointer bug | Wraparound fails | Extensive wraparound tests |
| Full/empty timing | Flags incorrect | Monitor transition timing |
| Data corruption | Loses data | Integrity checking in scoreboard |

---

## Testbench Architecture

```
UVM Hierarchy:
├── test_base
│   ├── env
│   │   ├── agent
│   │   │   ├── driver (applies write_en, write_data)
│   │   │   ├── sequencer
│   │   │   └── monitor (observes writes)
│   │   ├── agent (read side)
│   │   │   ├── driver (applies read_en)
│   │   │   ├── sequencer
│   │   │   └── monitor (observes reads, read_data)
│   │   └── scoreboard
│   │       └── verifies data integrity
│   │
│   └── sequences
│       ├── basic_write_seq
│       ├── basic_read_seq
│       ├── mixed_read_write_seq
│       └── stress_seq

Coverage:
├── address_coverage
├── data_coverage
├── operation_coverage
└── state_coverage

Assertions:
├── write_when_not_full
├── read_when_not_empty
└── occupancy_valid
```

---

## Success Definition

**FIFO is verified when:**
- ✅ All test scenarios complete without errors
- ✅ Coverage metrics >80%
- ✅ Zero assertion violations
- ✅ Data integrity verified across all tests
- ✅ Wraparound behavior correct
- ✅ Full/empty flags timing accurate
- ✅ Simultaneous r/w works correctly

---

**Status:** Verification plan complete, ready for Week 11 testbench development