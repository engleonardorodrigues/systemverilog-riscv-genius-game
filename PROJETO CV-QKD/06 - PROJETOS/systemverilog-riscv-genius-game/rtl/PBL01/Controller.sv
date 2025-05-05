`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2025 04:27:15 PM
// Design Name: 
// Module Name: control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module controller

    import typedefs::*;
(
    input  logic clk,
    input  logic rst_,

    signals_interface genius_signals

    /*input  logic player_input_button,
    input  logic speed_button,
    input  logic dificulty_button,
    input  logic mode_game_button,
    input  logic start_button,
    
    output logic game_mode,
    output logic settings_values,
    output logic update_score,
    output logic enable_led,
    output logic reg_player_wr,
    output logic random_out,
    output logic 


    output logic mem_rd,
    output logic mem_wr,*/

);

states_t state = IDLE, next_state;
    
always_comb begin: finite_state_machine

  next_state = state;
  
  case(state)
    
     IDLE:               next_state = GRN;
     GRN:                next_state = MATRIX_VALUES;
     MATRIX_VALUES:      next_state = SHOW_SEQUENCE_VALUES;  
     GET_PLAYER_INPUT:   next_state = COMPARISON;
     COMPARISON:         next_state = DEFEAT;
     COMPARISON:         next_state = EVALUATE;
     COMPARISON:         next_state = GET_PLAYER_INPUT;
     EVALUATE:           next_state = GRN;
     EVALUATE:           next_state = VICTORY;
     VICTORY:            next_state = IDLE;
     DEFEAT:             next_state = IDLE;
  
  endcase   
  
end 
  
    
always_ff @(posedge clk, negedge rst_)begin
 
 /****IDLE STATE****/   

    if(!rst_)begin
        
        state   <= IDLE;
    
    end else begin
        
        state <= next_state;
        
    end     
end 
   
always_comb begin: state_decode    
 
  /****GRN STATE****/
    case(state)
 
     GRN: begin 
            
      // Chamar gerador de número aleatório que está em outro .sv
            
    end    
  
endcase  
end 
endmodule