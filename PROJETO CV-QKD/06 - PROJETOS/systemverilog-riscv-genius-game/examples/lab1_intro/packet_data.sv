`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2025 10:11:35 AM
// Design Name: 
// Module Name: packet_data
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


typedef enum logic [3:0] {HEX, BIN, DEC} pp_t;
typedef enum logic [3:0] {ANY, SINGLE, MULTICAST, BROADCAST} ptype_t;

// packet class
class packet;

local string name;

  bit [3:0] target;
  bit [3:0] source;
  bit [7:0] data;

ptype_t ptype;

// add constructor to set instance name and source by arguments and packet type

function new (string name, int idt);
  
  this.name = name;
  source = 1 << idt;
  ptype = ANY;

endfunction

// get type function
function string gettype();

  return ptype.name();

endfunction

// get name function
function string getname();

  return name;

endfunction

// add print with policy
function void print (input pp_t pp = DEC);

  $display("---------------------------------------");
  $display("name  %s, type: %s", getname, gettype);
  
    case(pp)

      HEX: $display ("From source %h, to target %h, data: %h", source, target, data);
      DEC: $display ("From source %d, to target %d, data: %d", source, target, data);
      BIN: $display ("From source %b, to target %b, data: %b", source, target, data);
  
    endcase
endfunction
endclass
