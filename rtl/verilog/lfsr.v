//                              -*- Mode: Verilog -*-
// Filename        : lfsr.v
// Description     : LFSR Random Number Generator
// Author          : Patrick
// Created On      : Sun Dec  4 18:12:53 2022
// Last Modified By: Patrick
// Last Modified On: Sun Dec  4 18:12:53 2022
// Update Count    : 0
// Status          : Unknown, Use with caution!
// Based on https://simplefpga.blogspot.com/2013/02/random-number-generator-in-verilog-fpga.html


module lfsr (/*AUTOARG*/
   // Outputs
   rand_o,
   // Inputs
   clk_i, rst_i
   ) ;
   input wire clk_i;
   input wire rst_i;
   output wire [7:0] rand_o;

   wire              feedback_w;

   reg [7:0] rand_r;

   always @ (posedge clk_i) begin
      if (rst_i) begin
         rand_r <= 8'hFF;
      end else begin
         rand_r <= {rand_r[6:0], feedback_w};
      end
   end

   assign feedback_w = rand_r[7] ^ rand_r[5]  ^ rand_r[4]  ^ rand_r[3];
   assign rand_o = rand_r;
endmodule // lfsr
