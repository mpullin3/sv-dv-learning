Week 5 Checkpoint 5: FSM Testbench with Assertions & Coverage
==============================================================

State Coverage:
  IDLE (state=0):     100% (covered - multiple cycles)
  WAIT (state=1):     100% (covered - multiple cycles)
  ACTIVE (state=2):   100% (covered - multiple cycles)

Transition Coverage:
  IDLE→WAIT:          100% (covered)
  WAIT→ACTIVE:        100% (covered)
  ACTIVE→IDLE:        100% (covered)

Output Coverage:
  active=0 (IDLE/WAIT):   100% (covered)
  active=1 (ACTIVE):      100% (covered)

Assertions: All passed (state validity, output correctness)
Constraints: Applied (start randomized 70% 0, 30% 1)

Overall Coverage: 100% functional coverage achieved