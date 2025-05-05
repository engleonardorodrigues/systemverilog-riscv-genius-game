`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2025 02:48:49 PM
// Design Name: 
// Module Name: typedefs
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


package typedefs;

    localparam VERSION = "1.1";  
   
    /*typedef enum logic [2:0] {
    
        _HLT = 3'b000,           // Halt
        _SKZ = 3'b001,           // Skip if zero == 1
        _ADD = 3'b010,           // data + accumulator
        _AND = 3'b011,           // data & accumulator
        _XOR = 3'b100,           // data ^ accumulator 
        _LDA = 3'b101,           // load accumulator
        _STO = 3'b110,           // Store acumulator
        _JMP = 3'b111            // Jump to address
    
    } opcodes_t;*/

    /*Define states for controller*/

    typedef enum logic [7:0] {
        
        IDLE,
        GRN,
        MATRIX_VALUES,
        ADD_PLAYER_SEQUENCE,
        EVALUATE,
        SHOW_SEQUENCE_VALUES,
        GET_PLAYER_INPUT,
        COMPARISON,
        DEFEAT,
        VICTORY,
        SCORE
        
    } states_t;   
        
     
endpackage    
    
    
    
    
    
    