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
   wb_clk_i, wb_rst_i, wb_dat_i, wb_addr_i, wb_lock_i, wb_cyc_i, wb_we_i,
   dds_clk_i
   ) ;
   //------------------------------------------------------------------------------------------------------------------------
   // Parameters
   //------------------------------------------------------------------------------------------------------------------------
   parameter DATA_WIDTH = 32;
   parameter ADDR_WIDTH = 5;
   parameter WAVE_WIDTH = 16;

   //------------------------------------------------------------------------------------------------------------------------
   // I/O
   //------------------------------------------------------------------------------------------------------------------------
   // Wishbone Interface Signals
   input wire wb_clk_i;
   input wire wb_rst_i;
   input wire [DATA_WIDTH-1:0] wb_dat_i;
   input wire [ADDR_WIDTH-1:0] wb_addr_i;
   input wire                  wb_lock_i;
   input wire                  wb_cyc_i;
   input wire                  wb_we_i;

   output wire [DATA_WIDTH-1:0] wb_dat_o;
   output wire                  wb_ack_o;

   // Misc IO signals
   input wire                   dds_clk_i;

   output wire [WAVE_WIDTH-1:0] wave_o;

   //------------------------------------------------------------------------------------------------------------------------
   // Internal Signals
   //------------------------------------------------------------------------------------------------------------------------
   // Register Map TODO move into reg_map
   reg [DATA_WIDTH-1:0]         ready_r;
   reg [DATA_WIDTH-1:0]         enable_r;
   reg [DATA_WIDTH-1:0]         dds_src_r;
   reg [DATA_WIDTH-1:0]         tuning_word_r;
   reg [DATA_WIDTH-1:0]         gain_word_r;
   reg [DATA_WIDTH-1:0]         offset_word_r;

   // Register Map Signals
   wire [DATA_WIDTH-1:0]         reg_map [5:0];
   wire                         map_wr_en;
   wire [ADDR_WIDTH-1:0]        map_wr_addr;
   wire [DATA_WIDTH-1:0]        map_wr_data;

   // User memory signals
   wire                         mem_wr_en;
   wire [ADDR_WIDTH-1:0]        mem_wr_addr;
   wire [DATA_WIDTH-1:0]        mem_wr_data;

   // Registered output signals
   reg [DATA_WIDTH-1:0]        wb_dat_r;
   reg                         wb_ack_r;
   reg [WAVE_WIDTH-1:0]        wave_r;

   //------------------------------------------------------------------------------------------------------------------------
   // Module Instantiations
   //------------------------------------------------------------------------------------------------------------------------
   //   wb_interface #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) interface_0(.wb_clk_i(wb_clk_i), .wb_rst_i(wb_rst_i), .wb_dat_i(wb_dat_i),
   //                                                                                .wb_addr_i(wb_addr_i), .wb_lock_i(wb_lock_i), .wb_cyc_i(wb_cyc_i),
   //                                                                                .wb_we_i(wb_we_i),
   //                                                                                .wb_dat_o(wb_dat_o), .wb_ack_o(wb_ack_o)
   //                                                                                .map_wr_en_o(map_wr_en), .map_wr_addr_o(map_wr_addr)
   //                                                                                .map_wr_dat_o(map_wr_dat),
   //                                                                                .mem_wr_en_o(mem_wr_en), .mem_wr_addr_o(mem_wr_addr)
   //                                                                                .mem_wr_dat_o(mem_wr_dat));

   //reg_map map_0(.map_wr_en_i(map_wr_en), .map_wr_addr_i(map_wr_addr_en), .map_wr_dat_i(map_wr_dat), .reg_map_o(reg_map));
   //mem mem_0(.mem_wr_en_i(mem_wr_en), .mem_wr_addr_i(mem_wr_addr_en), .mem_wr_dat_i(mem_wr_dat));
   //sine_lut sine_0();
   //sawtooth_lut sawtooth_0();
   //dds_core dds_0();

   //------------------------------------------------------------------------------------------------------------------------
   // Assigns
   //------------------------------------------------------------------------------------------------------------------------
   assign wb_dat_o = wb_dat_r;
   assign wb_ack_o = wb_ack_r;
   assign wave_o = wave_r;

endmodule // simple_dds
