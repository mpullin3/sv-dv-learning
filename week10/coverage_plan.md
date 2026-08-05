# FIFO Functional Coverage Plan

## Coverage Overview

**Purpose:** Measure test completeness by tracking which FIFO behaviors are exercised.

**Goal:** Achieve >80% coverage across all cover points by end of Week 12.

**Measurement tool:** SystemVerilog covergroups (testbench monitors coverage during simulation)

---

## Address/Pointer Coverage

### **Write Pointer Coverage**

Measure: Which addresses are written to?

**Cover Points:**
- `write_ptr_low`: Addresses 0-7 (lower half)
- `write_ptr_high`: Addresses 8-15 (upper half)
- `write_ptr_min`: Address 0 (boundary)
- `write_ptr_max`: Address 15 (boundary)
- `write_ptr_wrap`: Pointer wraps (0 → 15 → 0)

**Why?** Ensures all memory locations can be written

### **Read Pointer Coverage**

Measure: Which addresses are read from?

**Cover Points:**
- `read_ptr_low`: Addresses 0-7
- `read_ptr_high`: Addresses 8-15
- `read_ptr_min`: Address 0 (boundary)
- `read_ptr_max`: Address 15 (boundary)
- `read_ptr_wrap`: Pointer wraps

**Why?** Ensures all memory locations can be read

---

## Data Coverage

### **Write Data Patterns**

Measure: What data values are written?

**Cover Points:**
- `data_all_zeros`: 8'h00
- `data_all_ones`: 8'hFF
- `data_low_byte`: Data 0x00-0x7F (lower half)
- `data_high_byte`: Data 0x80-0xFF (upper half)
- `data_mid_range`: Data 0x01-0xFE (middle values)

**Why?** Catches bit-specific bugs (stuck bits, bit swaps)

### **Read Data Patterns**

Same as write data patterns - verify read_data matches written values

---

## Flag Coverage

### **Full Flag Behavior**

Measure: When does full flag assert/deassert?

**Cover Points:**
- `full_asserts`: FIFO becomes full (wr_ptr_next == rd_ptr)
- `full_deasserts`: FIFO becomes not full (after read)
- `full_transitions`: Transitions between full/not-full states
- `full_sticky`: Full flag held for multiple cycles
- `full_with_write`: Write prevented when full

**Why?** Critical for data integrity - can't lose data

### **Empty Flag Behavior**

Measure: When does empty flag assert/deassert?

**Cover Points:**
- `empty_asserts`: FIFO becomes empty (wr_ptr == rd_ptr)
- `empty_deasserts`: FIFO becomes not empty (after write)
- `empty_transitions`: Transitions between empty/not-empty
- `empty_sticky`: Empty flag held for multiple cycles
- `empty_with_read`: Read blocked when empty

**Why?** Prevents reading stale data

---

## Operation Coverage

### **Write Operations**

Measure: Different write scenarios

**Cover Points:**
- `single_write`: Single write transaction
- `sequential_writes`: Multiple writes in a row
- `writes_to_each_address`: Write to each of 16 addresses
- `writes_full_fifo`: Writes that fill FIFO completely
- `writes_after_read`: Writes following read operations

**Why?** Validates write mechanics under various conditions

### **Read Operations**

Measure: Different read scenarios

**Cover Points:**
- `single_read`: Single read transaction
- `sequential_reads`: Multiple reads in a row
- `reads_from_each_address`: Read from each of 16 addresses
- `reads_empty_fifo`: Reads that drain FIFO completely
- `reads_after_write`: Reads following write operations

**Why?** Validates read mechanics under various conditions

### **Simultaneous Read/Write**

Measure: Concurrent operations

**Cover Points:**
- `read_write_same_cycle`: Read and write same clock edge
- `read_write_different_addresses`: R/W to different addresses simultaneously
- `read_write_high_speed`: Back-to-back R/W pairs
- `simultaneous_full_empty`: Transitions while R/W active

**Why?** Most complex scenario - ensures pointers move independently

---

## State Machine Coverage

### **FIFO States**

Measure: Which states are exercised?

**States:**
- `EMPTY`: rd_ptr == wr_ptr (no data)
- `PARTIAL`: Data present, not full (normal operation)
- `FULL`: All entries occupied (next write blocked)

**Cover Points:**
- `empty_to_partial`: Transition via write
- `partial_to_full`: Fill FIFO completely
- `full_to_partial`: Transition via read
- `partial_to_empty`: Drain FIFO
- `full_to_empty`: (rare) Fill then drain without partial
- `cycles_in_each_state`: How long in each state

**Why?** Validates state machine logic and transitions

---

## Occupancy Coverage

### **Occupancy Levels**

Measure: FIFO fullness during operation

**Cover Points:**
- `occupancy_empty`: Count = 0
- `occupancy_quarter_full`: Count 1-4
- `occupancy_half_full`: Count 5-8
- `occupancy_three_quarter`: Count 9-12
- `occupancy_almost_full`: Count 13-15
- `occupancy_full`: Count = 16
- `occupancy_increasing`: Count goes up (writes)
- `occupancy_decreasing`: Count goes down (reads)

**Why?** Ensures FIFO operates correctly at all fill levels

---

## Edge Cases & Boundary Conditions

### **Single Entry Operations**

**Cover Points:**
- `write_one_read_one`: Write single item, read it immediately
- `fill_to_one_entry`: Leave exactly 1 entry
- `drain_to_one_entry`: Read down to 1 entry remaining
- `full_with_one_space`: One space left before full

### **Wraparound Scenarios**

**Cover Points:**
- `wrap_at_boundary`: Pointer wraps from 15→0
- `write_across_wrap`: Writes straddle wrap point
- `read_across_wrap`: Reads straddle wrap point
- `both_pointers_wrapping`: R/W both wrap in sequence

### **Protocol Edge Cases**

**Cover Points:**
- `write_when_almost_full`: Write with exactly 1 space left
- `read_last_item`: Read final item (becomes empty)
- `rapid_full_empty_transitions`: Quick full→empty cycles
- `blocked_writes`: Writes attempted while full
- `blocked_reads`: Reads attempted while empty

---

## Coverage Targets

### **By Category**

| Category | Target | Rationale |
|----------|--------|-----------|
| Address coverage | 100% | All locations must be accessible |
| Data patterns | >80% | Catch bit-specific bugs |
| Flag behavior | 100% | Critical for correctness |
| Operations | >85% | All modes must work |
| State transitions | 100% | State machine validation |
| Occupancy levels | >85% | Operation at all fill levels |
| Edge cases | >90% | Boundary conditions matter |
| **Overall** | **>80%** | Target for Week 12 completion |

---

## Coverage Measurement Strategy

### **How Coverage Is Measured**

**In Monitor (fifo_monitor.sv):**
```systemverilog
// Continuously sample coverage during simulation
if (vif.write_en && !vif.full) begin
  write_addr_cov.sample(vif.addr_a);      // Sample write address
  write_data_cov.sample(vif.write_data);  // Sample write data
end

if (vif.read_en && !vif.empty) begin
  read_addr_cov.sample(vif.addr_b);       // Sample read address
  read_data_cov.sample(vif.read_data);    // Sample read data
end

// Sample state
state_cov.sample(vif.full, vif.empty, vif.occupancy);
```

**Coverage Report (after simulation):**
```
Coverage Summary:
================
Address Coverage:         100%  ✓
Data Coverage:             87%  ✓
Flag Coverage:            100%  ✓
Operation Coverage:        92%  ✓
State Coverage:           100%  ✓
Occupancy Coverage:        88%  ✓
Edge Case Coverage:        91%  ✓
────────────────────────────────
OVERALL:                   93%  ✓
```

---

## Coverage Gaps & Mitigation

### **Potential Gaps**

| Gap | Impact | Mitigation |
|-----|--------|-----------|
| Missed data patterns | Bit errors undetected | Add constrained sequence targeting specific values |
| No simultaneous R/W | Real-world scenario untested | Add mixed sequences with tight R/W timing |
| Insufficient edge cases | Corner case bugs slip through | Add dedicated edge-case sequence |
| Low occupancy coverage | Mid-range behavior untested | Add sequences targeting specific occupancy levels |

### **Coverage-Driven Test Selection**

**Week 11:**
- Basic sequences (write, read, mixed)
- Monitor coverage during runs
- Identify gaps

**Week 12:**
- Create targeted sequences for gaps
- Add constrained sequences
- Stress test high-value areas
- Run regression to achieve >80%

---

## Coverage Integration with Testbench

### **Flow**

```
Sequence generates transactions
    ↓
Driver applies to FIFO
    ↓
Monitor observes + samples coverage
    ↓
Coverage accumulates during test
    ↓
Report phase prints coverage summary
    ↓
If <80%: Add more sequences
If >80%: Coverage goal met
```

### **Coverage Report in Test**

```systemverilog
function void report_phase(uvm_phase phase);
  super.report_phase(phase);
  
  // Print coverage from all cover groups
  $display("=== COVERAGE REPORT ===");
  write_addr_cov.sample(-1);     // Finalize
  write_data_cov.sample(-1);
  read_addr_cov.sample(-1);
  read_data_cov.sample(-1);
  flag_cov.sample(-1);
  state_cov.sample(-1);
  occupancy_cov.sample(-1);
  
  // Print percentages
  $display("Coverage achieved: [results]");
endfunction
```

---

## Coverage Milestones

### **Week 11 (Initial)**
- Basic sequences running
- Coverage tracking enabled
- Target: >50% (proof of concept)

### **Week 12 (Optimization)**
- Targeted sequences for gaps
- Constrained randomization
- Regression suite
- Target: >80% (success)

### **After Testing (September)**
- Lab results show actual coverage
- Update documentation with results
- Include in GitHub portfolio

---

## Why Coverage Matters

**Without coverage measurement:**
- Don't know if tests are complete
- Bugs might slip through
- Can't prove FIFO is verified

**With coverage measurement:**
- Quantifies completeness
- Identifies gaps systematically
- Shows employer "we verified this"
- Professional verification practice

---

**Status:** Coverage plan complete, ready for Week 11 integration into testbench