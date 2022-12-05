//                              -*- Mode: Verilog -*-
// Filename        : simple_dds.v
// Description     : A direct digital synthesis core capable of sine, sawtooth, random, and user defined waves
// Author          : Patrick Hoey
// Created On      : Sun Nov 27 18:23:16 2022
// Last Modified By: Patrick Hoey
// Last Modified On: Sun Nov 27 18:23:16 2022
// Update Count    : 0
// Status          : Unknown, Use with caution!

module simple_dds (/*AUTOARG*/
   // Outputs
   wb_dat_o, wb_ack_o, wave_o,
   // Inputs
   wb_clk_i, wb_rst_i, wb_dat_i, wb_addr_i, wb_we_i, wb_stb_i, dds_clk_i
   ) ;
   //------------------------------------------------------------------------------------------------------------------------
   // Parameters
   //------------------------------------------------------------------------------------------------------------------------
   parameter DATA_WIDTH = 32;
   parameter ADDR_WIDTH = 16;
   parameter WAVE_WIDTH = 16;

   //--------------------------------------------------------------------------------------------------------------------------------------------
   // I/O
   //--------------------------------------------------------------------------------------------------------------------------------------------
   // Wishbone Interface Signals
   input wire wb_clk_i;
   input wire wb_rst_i;
   input wire [DATA_WIDTH-1:0] wb_dat_i;
   input wire [ADDR_WIDTH-1:0] wb_addr_i;
   input wire                  wb_we_i;
   input wire                  wb_stb_i;

   output wire [DATA_WIDTH-1:0] wb_dat_o;
   output wire                  wb_ack_o;

   // Misc IO signals
   input wire                   dds_clk_i;

   output wire [WAVE_WIDTH-1:0] wave_o;

   //--------------------------------------------------------------------------------------------------------------------------------------------
   // Internal Signals
   //--------------------------------------------------------------------------------------------------------------------------------------------
   // Register Map Signals
   // TODO add in the seeded version for lfsr
   reg [DATA_WIDTH-1:0]         reg_map_r [5:0]; // Consult Spec for register map

   // Observation wires to ensure registers work properly
   /* verilator lint_off UNUSED */
   wire [DATA_WIDTH-1:0]         ready_w;
   wire [DATA_WIDTH-1:0]         enable_w;
   wire [DATA_WIDTH-1:0]         dds_src_w;
   wire [DATA_WIDTH-1:0]         tuning_word_w;
   wire [DATA_WIDTH-1:0]         gain_word_w;
   wire [DATA_WIDTH-1:0]         offset_word_w;
   /* verilator lint_on UNUSED */

   // Registered output signals
   reg [DATA_WIDTH-1:0]        wb_dat_r;
   reg                         wb_ack_r;
   wire [WAVE_WIDTH-1:0]        wave_res;

   // Random Number Generator Signals
   // TODO wire [7:0]                   rand_num;

   //--------------------------------------------------------------------------------------------------------------------------------------------
   // Module Instantiations
   //--------------------------------------------------------------------------------------------------------------------------------------------
   dds_core dds_0(// Outputs
                  .wave_o               (wave_res),
                  // Inputs
                  .dds_clk_i            (dds_clk_i),
                  .wb_clk_i             (wb_clk_i),
                  .wb_rst_i             (wb_rst_i),
                  .dds_src_i            (dds_src_w[1:0]),
                  .tuning_word_i        (tuning_word_w[7:0]),
                  .gain_word_i          (gain_word_w[1:0]),
                  .offset_word_i        (offset_word_w[15:0]));


   //--------------------------------------------------------------------------------------------------------------------------------------------
   // RTL
   //--------------------------------------------------------------------------------------------------------------------------------------------
   always @ (posedge wb_clk_i) begin
      if(wb_rst_i) begin
         // TODO reset any internal registers
         wb_ack_r      <= 1'b0;
         reg_map_r[0]  <= 1; // TODO determine if ready needs some other condition
         reg_map_r[1]  <= 0;
         reg_map_r[2]  <= 0;
         reg_map_r[3]  <= 1;
         reg_map_r[4]  <= 0;
         reg_map_r[5]  <= 32'h0000_7FFF;
      end else begin
         // Writes------------------------
         if((wb_stb_i) && (wb_we_i)) begin
            if((wb_addr_i > 16'h0000) && (wb_addr_i < 16'h0006)) begin
               reg_map_r[wb_addr_i[2:0]] <= wb_dat_i;
            end
         end

         // Reads-------------------------
         else if((wb_stb_i) && (~wb_we_i)) begin
            if(wb_addr_i < 16'h0006) begin
               wb_dat_r <= reg_map_r[wb_addr_i[2:0]];
            end
         end

         // Acknowledge transaction------
         wb_ack_r <= wb_stb_i;
      end
   end

   //--------------------------------------------------------------------------------------------------------------------------------------------
   // Assigns
   //--------------------------------------------------------------------------------------------------------------------------------------------
   // Wishbone
   assign wb_dat_o = wb_dat_r;
   assign wb_ack_o = wb_ack_r;

   // Waveform
   assign wave_o = enable_w[0] ? wave_res : 0;

   // Register Observation Wires
   assign ready_w = reg_map_r[0];
   assign enable_w = reg_map_r[1];
   assign dds_src_w = reg_map_r[2];
   assign tuning_word_w = reg_map_r[3];
   assign gain_word_w = reg_map_r[4];
   assign offset_word_w = reg_map_r[5];

endmodule // simple_dds
