// Code your design here
module sequence_detector (
  input logic clk, resetN,
  input logic data_in, // serial input (1 bit per clock)
  output logic detected // goes high when "101" detected
);
  
  typedef enum logic [1:0] {Idle, Got_1, Got_10} state_t;
  state_t current_state, next_state;
  
  // State register
  always_ff @(posedge clk, negedge resetN)
    if(!resetN)
      current_state <= Idle;
    else
      current_state <= next_state; // advance
  
  // Next state logic
  always_comb begin
    next_state = current_state; // default (prevents latches)
    case(current_state)
      Idle:
        if(data_in == 1)
          next_state = Got_1;
        else
          next_state = current_state;
      Got_1:
        if(data_in == 0)
          next_state = Got_10;
        else
          next_state = current_state;
      Got_10:
        if(data_in == 1)
          next_state = Idle;
        else
          next_state = Idle;
    endcase
  end
  
  // Output Logic(Mealy)
  assign detected = (current_state == Got_10) && (data_in == 1);
  
endmodule
                    