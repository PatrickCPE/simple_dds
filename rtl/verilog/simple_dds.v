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

   // User RAM and LUTs
   reg [7:0]                    user_ram_r [1023:0];
   reg [7:0]                    sine_lut_r [1023:0];
   reg [7:0]                    saw_lut_r [1023:0];

   // Registered output signals
   reg [DATA_WIDTH-1:0]        wb_dat_r;
   reg                         wb_ack_r;
   reg [WAVE_WIDTH-1:0]        wave_r;

   // DDS Core signals
   wire [7:0]                  dds_data;
   wire [9:0]                   phase_addr;

   // Random Number Generator Signals
   wire [7:0]                   rand_num;

   //--------------------------------------------------------------------------------------------------------------------------------------------
   // Module Instantiations
   //--------------------------------------------------------------------------------------------------------------------------------------------
   //dds_core dds_0();
   //lfsr lfsr_0();

   //--------------------------------------------------------------------------------------------------------------------------------------------
   // RTL
   //--------------------------------------------------------------------------------------------------------------------------------------------
   always @ (posedge wb_clk_i) begin
      if(wb_rst_i) begin
         // TODO reset any internal registers
         wb_ack_r <= 1'b0;

         // TODO include reset file via preprocessor to reset the ram for sine and sawtooth
         // include files are the auto-generated reset values for the Sine and sawtooth LUTs
      end else begin
         // Writes------------------------
         if((wb_stb_i) && (wb_we_i)) begin
            if((wb_addr_i > 16'h0000) && (wb_addr_i < 16'h0006)) reg_map_r[wb_addr_i[2:0]] <= wb_dat_i;        // Control/Status Registers
            if((wb_addr_i >= 16'h0400) && (wb_addr_i < 16'h07FF)) user_ram_r[wb_addr_i[9:0]] <= wb_dat_i[7:0]; // User RAM
         end

         // Reads-------------------------
         if((wb_stb_i) && (~wb_we_i)) begin
            if(wb_addr_i < 16'h0006) wb_dat_r <= reg_map_r[wb_addr_i[2:0]];                                        // Control/Status Registers
            if((wb_addr_i >= 16'h0400) && (wb_addr_i < 16'h07FF)) wb_dat_r <= {24'd0, user_ram_r[wb_addr_i[9:0]]}; // User RAM
            if((wb_addr_i >= 16'h0800) && (wb_addr_i < 16'h0BFF)) wb_dat_r <= {24'd0, sine_lut_r[wb_addr_i[9:0]]}; // Sine LUT
            if((wb_addr_i >= 16'h0C00) && (wb_addr_i < 16'h0FFF)) wb_dat_r <= {24'd0, saw_lut_r[wb_addr_i[9:0]]};  // Saw LUT
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
   assign wave_o = wave_r;

endmodule // simple_dds
