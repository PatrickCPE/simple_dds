//                              -*- Mode: Verilog -*-
// Filename        : dds_core.v
// Description     : Generates the DDS output signal. Note that 3 dds clock edges must occur before the signal becomes valid
// Author          : Patrick
// Created On      : Sun Dec  4 17:59:32 2022
// Last Modified By: Patrick
// Last Modified On: Sun Dec  4 17:59:32 2022
// Update Count    : 0
// Status          : Unknown, Use with caution!


module dds_core (/*AUTOARG*/
   // Outputs
   wave_o,
   // Inputs
   dds_clk_i, wb_clk_i, wb_rst_i, dds_src_i, tuning_word_i, gain_word_i,
   offset_word_i
   ) ;
   //------------------------------------------------------------------------------------------------------------------------
   // Parameters
   //------------------------------------------------------------------------------------------------------------------------
   parameter WAVE_WIDTH = 16;

   //--------------------------------------------------------------------------------------------------------------------------------------------
   // I/O
   //--------------------------------------------------------------------------------------------------------------------------------------------
   input wire dds_clk_i;
   input wire wb_clk_i;
   input wire wb_rst_i;
   input wire [1:0] dds_src_i;
   input wire [7:0] tuning_word_i;
   input wire [1:0]  gain_word_i;
   input wire [15:0] offset_word_i;

   output wire [WAVE_WIDTH-1:0] wave_o;

   //--------------------------------------------------------------------------------------------------------------------------------------------
   // Internal Signals
   //--------------------------------------------------------------------------------------------------------------------------------------------
   reg [7:0]                    phase_acum_r;
   wire [7:0]                    sine_w;
   wire [7:0]                    tri_w;
   wire [7:0]                    saw_w;
   wire [7:0]                    rand_w;

   reg [WAVE_WIDTH/2-1:0]          wave_pre_multiply;
   reg [WAVE_WIDTH-1:0]          wave_pre_offset;
   reg [WAVE_WIDTH-1:0]         wave_r;

   //--------------------------------------------------------------------------------------------------------------------------------------------
   // Module Instantiations
   //--------------------------------------------------------------------------------------------------------------------------------------------
   sine_lut sine_0(/// Outputs
                   .sine_o              (sine_w),
                   // Inputs
                   .address_i           (phase_acum_r));
   tri_lut tri_0(// Outputs
                 .tri_o                 (tri_w),
                 // Inputs
                 .address_i             (phase_acum_r));
   saw_lut saw_0(// Outputs
                 .saw_o                 (saw_w),
                 // Inputs
                 .address_i             (phase_acum_r));

   lfsr lfsr_0(// Outputs
               .rand_o                  (rand_w),
               // Inputs
               .clk_i                   (dds_clk_i),
               .rst_i                   (wb_rst_i));

   //--------------------------------------------------------------------------------------------------------------------------------------------
   // RTL
   //--------------------------------------------------------------------------------------------------------------------------------------------
   always @ (posedge dds_clk_i or posedge wb_clk_i) begin
      if (wb_clk_i & wb_rst_i) begin
         phase_acum_r <= 8'd0;
         wave_pre_multiply <= 0;
         wave_pre_offset <= 0;
         wave_r <= 0;
      end else begin
         phase_acum_r <= phase_acum_r + tuning_word_i;
         case (dds_src_i)
            2'b00 : wave_pre_multiply <= sine_w; // Sine
            2'b01 : wave_pre_multiply <= saw_w; // Sawtooth
            2'b10 : wave_pre_multiply <= tri_w; // Triangle
            2'b11 : wave_pre_multiply <= rand_w; // Random
         endcase // case (dds_src_i)
         case (gain_word_i)
            2'b00 : wave_pre_offset <= {8'b0, wave_pre_multiply}; // x1
            2'b01 : wave_pre_offset <= {7'b0, wave_pre_multiply, 1'b0}; // x2
            2'b10 : wave_pre_offset <= {6'b0, wave_pre_multiply, 2'b0}; // x4
            2'b11 : wave_pre_offset <= {5'b0, wave_pre_multiply, 3'b0}; // x8
         endcase // case (gain_word_i)
         wave_r <= wave_pre_offset + offset_word_i;
      end
   end

   //--------------------------------------------------------------------------------------------------------------------------------------------
   // Assigns
   //--------------------------------------------------------------------------------------------------------------------------------------------
   assign wave_o = wave_r;

endmodule // dds_core
