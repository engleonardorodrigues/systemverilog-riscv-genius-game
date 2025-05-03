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

    input  logic player_input_button,
    input  logic speed_button,
    input  logic dificulty_button,
    input  logic mode_game_button,
    input  logic start_button,
    
    output logic game_mode,
    output logic settings_values,
    output logic ,


    output logic mem_rd,
    output logic mem_wr,

);

states_t state = IDLE, next_state;
    
always_comb begin: finite_state_machine

  next_state = state;
  
  case(state)
    
     _INST_ADDR:  next_state = _INST_FETCH;
     _INST_FETCH: next_state = _INST_LOAD;
     _INST_LOAD:  next_state = _IDLE;  
     _IDLE:       next_state = _OP_ADDR;
     _OP_ADDR:    next_state = _OP_FETCH;
     _OP_FETCH:   next_state = _ALU_OP;
     _ALU_OP:     next_state = _STORE;
     _STORE:      next_state = _INST_ADDR;
  
  endcase   
  
end 
  
    
always_ff @(posedge clk, negedge rst_)begin
 
 /****INST_ADDR STATE****/   

    if(!rst_)begin
        
        state   <= _INST_ADDR;
        mem_rd  <= 1'b0;
        load_ir <= 1'b0;
        halt    <= 1'b0;
        inc_pc  <= 1'b0;
        load_ac <= 1'b0;
        load_pc <= 1'b0;
        mem_wr  <= 1'b0;
    
    end else begin
        
        state <= next_state;
        
    end     
end 
   
always_comb begin: state_decode    
 
  /****INST_FETCH STATE****/
    case(state)
 
     _INST_FETCH: begin 
            
        mem_rd  = 1'b1;
        load_ir = 1'b0;
        halt    = 1'b0;
        inc_pc  = 1'b0;
        load_ac = 1'b0;
        load_pc = 1'b0;
        mem_wr  = 1'b0;
            
    end    
            
 /****INST_LOAD STATE****/
     _INST_LOAD: begin 
            
        mem_rd  = 1'b1;
        load_ir = 1'b1;
        halt    = 1'b0;
        inc_pc  = 1'b0;
        load_ac = 1'b0;
        load_pc = 1'b0;
        mem_wr  = 1'b0;
            
    end 
 
 /******IDLE STATE******/
  
     _IDLE: begin 
            
        mem_rd  = 1'b1;
        load_ir = 1'b1;
        halt    = 1'b0;
        inc_pc  = 1'b0;
        load_ac = 1'b0;
        load_pc = 1'b0;
        mem_wr  = 1'b0;
            
    end 
  
 /****OP_ADDR STATE****/
 
    _OP_ADDR: begin 
            
        mem_rd  = 1'b0;
        load_ir = 1'b0;
        halt    = (opcode == _HLT);
        inc_pc  = 1'b1;
        load_ac = 1'b0;
        load_pc = 1'b0;
        mem_wr  = 1'b0;
            
    end 
 /****OP_FETCH STATE****/
 
     _OP_FETCH: begin 
            
      if(opcode == _ADD || opcode == _AND || opcode == _XOR || opcode == _LDA) begin          
        mem_rd  = 1'b1;
      end else begin
        mem_rd  = 1'b0;
      end         
        load_ir = 1'b0;
        halt    = 1'b0;
        inc_pc  = 1'b0;
        load_ac = 1'b0;
        load_pc = 1'b0;
        mem_wr  = 1'b0;
            
    end 
 
 /****ALU_OP STATE****/
   
     _ALU_OP: begin 
            
      if(opcode == _ADD || opcode == _AND || opcode == _XOR || opcode == _LDA) begin          
        mem_rd  = 1'b1;
      end else begin
        mem_rd  = 1'b0;
      end         
        
        load_ir = 1'b0;
        halt    = 1'b0;
 
        inc_pc  = ((opcode == _SKZ) && zero);
      
      if(opcode == _ADD || opcode == _AND || opcode == _XOR || opcode == _LDA) begin          
        load_ac = 1'b1;
      end else begin
        load_ac = 1'b0;
      end             
        
        load_pc = (opcode == _JMP);
        mem_wr  = 1'b0;
            
    end 
 
 /****STORE STATE****/
 
      _STORE: begin 
      //ALUOP      
      if(opcode == _ADD || opcode == _AND || opcode == _XOR || opcode == _LDA) begin          
        mem_rd  = 1'b1;
      end else begin
        mem_rd  = 1'b0;
      end
      
        load_ir = 1'b0;
        halt    = 1'b0;  
        inc_pc = (opcode == _JMP);
        
      //ALUOP      
      if(opcode == _ADD || opcode == _AND || opcode == _XOR || opcode == _LDA) begin          
        load_ac  = 1'b1;
      end else begin
         load_ac = 1'b0;
      end   
      
      load_pc = (opcode == _JMP);
      mem_wr  = (opcode == _STO);   
      end
endcase  
end 
endmodule