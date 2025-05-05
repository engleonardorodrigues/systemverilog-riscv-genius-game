`timescale 1ns / 1ps
/*-----------------------------------------------------------------
File name     : packet_data.sv
Developers    : Brian Dickinson
Created       : 01/08/19
Description   : lab1 packet data item 
Notes         : From the Cadence "Essential SystemVerilog for UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2019
-----------------------------------------------------------------*/

// Follow instructions in lab book
  
// add print and type policies here

typedef enum logic [3:0] {HEX, BIN, DEC} pp_t;
typedef enum logic [3:0] {ANY, SINGLE, MULTICAST, BROADCAST} ptype_t;

// packet class
class packet;

local string name;

  rand bit [3:0] target;
       bit [3:0] source;
  rand bit [7:0] data;

rand ptype_t ptype;

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

// constraint class for target cannot be zero

constraint t_not0 {target != 0;}
constraint ts_bits {{target & source} == 4'b0;}

// solve and create a conditional constraints

constraint ptype_order {solve ptype before target;}

constraint packet_type {ptype == SINGLE    -> target inside {1,2,4,8};
                        ptype == MULTICAST -> target inside {3,[5:7],[9:14]};
                        ptype == BROADCAST -> target == 15;}
                        
// add print with policy
function void print (input pp_t pp = BIN);

  $display("---------------------------------------");
  $display("name  %s, type: %s", getname, gettype);
  
    case(pp)

      HEX: $display ("From source %h, to target %h, data: %h", source, target, data);
      DEC: $display ("From source %d, to target %d, data: %d", source, target, data);
      BIN: $display ("From source %b, to target %b, data: %b", source, target, data);
  
    endcase
endfunction
endclass

