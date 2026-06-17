// Code your design here
// Please not that this code won't run on EDA playground because the        // simulator
// Icarus Verilog 12.0 does not support 'type_def enum'. It should work in   // other simulators though. 
module simple_fsm (
  input logic clk, resetN, start,
  output logic active
);
  type def enum logic {Idle, Active} state_t; // state type
  state_t current_state, next_state; // state variables
  
  // State register
  always_ff @(posedge clk, negedge resetN)
    if(!resetN)
      current_state <= Idle;
  	else
      current_state <= next_state; // advance to next state
  
  // Next state logic
  always_comb begin
    next_state = current_state; // default (prevents latches)
    case(current_state)
      Idle: 
        if(start)
          next_state = Active; // go to active
      Active: 
        next_state = Idle; // auto transition (or use inputs)
    endcase
  end
  // Output logic (Moore)
  assign active = (current_state == Active);
endmodule