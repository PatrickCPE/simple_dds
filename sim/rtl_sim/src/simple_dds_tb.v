module simple_dds_tb ();
   parameter SEED = 100;
   integer seed = SEED;
   parameter TRACE = 1;
   parameter TIMEOUT = 50000;
   parameter WB_CLOCK_PERIOD = 100;
   parameter WB_CLOCK_HALF_PERIOD = WB_CLOCK_PERIOD / 2;
   parameter DDS_CLOCK_PERIOD = 10;
   parameter DDS_CLOCK_HALF_PERIOD = DDS_CLOCK_PERIOD / 2;

   parameter DATA_WIDTH = 32;
   parameter ADDR_WIDTH = 16;
   parameter WAVE_WIDTH = 16;

   // Register Address Definitions
   parameter READY = 32'd0,
      ENABLE      = 32'd1,
      DDS_SRC     = 32'd2,
      TUNING_WORD = 32'd3,
      GAIN_WORD   = 32'd4,
      OFFSET_WORD = 32'd5;

   // Register Reset Values
   parameter READY_RST_VAL = 32'd0,
      ENABLE_RST_VAL = 32'd0,
      DDS_SRC_RST_VAL = 32'd0,
      TUNING_WORD_RST_VAL = 32'd1,
      GAIN_WORD_RST_VAL = 32'd0,
      OFFSET_WORD_RST_VAL = 32'h000000FF;


   reg wb_clk_i_tb;
   reg wb_rst_i_tb;
   reg [DATA_WIDTH-1:0] wb_dat_i_tb;
   reg [ADDR_WIDTH-1:0] wb_addr_i_tb;
   reg                  wb_we_i_tb;
   reg                  wb_stb_i_tb;

   wire [DATA_WIDTH-1:0] wb_dat_o_tb;
   wire                  wb_ack_o_tb;

   // Misc IO signals
   reg                   dds_clk_i_tb;

   wire [WAVE_WIDTH-1:0] wave_o_tb;


   simple_dds #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH), .WAVE_WIDTH(WAVE_WIDTH))
   dut0(
        // Outputs
        .wb_dat_o            (wb_dat_o_tb),
        .wb_ack_o            (wb_ack_o_tb),
        .wave_o              (wave_o_tb),
        // Inputs
        .wb_clk_i            (wb_clk_i_tb),
        .wb_rst_i            (wb_rst_i_tb),
        .wb_dat_i            (wb_dat_i_tb),
        .wb_addr_i           (wb_addr_i_tb),
        .wb_we_i             (wb_we_i_tb),
        .wb_stb_i            (wb_stb_i_tb),
        .dds_clk_i           (dds_clk_i_tb)
        );

   // Wave Dump
   if (TRACE == 1) initial begin
      $dumpfile("../out/wave_simple_dds.vcd");
      $dumpvars;
   end

   // Watchdog Timeout
   initial begin
      #TIMEOUT $finish;
   end

   // DDS Clock Generator
   initial begin
      forever #DDS_CLOCK_HALF_PERIOD dds_clk_i_tb = ~dds_clk_i_tb;
   end

   //// WB Clock Generator
   initial begin
      forever #WB_CLOCK_HALF_PERIOD wb_clk_i_tb = ~wb_clk_i_tb;
   end

   reg [DATA_WIDTH-1:0] read_data;
   reg [ADDR_WIDTH-1:0] read_addr;

   // DUT Random Register Values
   reg                  enable_tb;
   reg [1:0]            dds_src_tb;
   reg [7:0]           tuning_word_tb;
   reg [1:0]            gain_word_tb;
   reg [15:0]           offset_word_tb;

   integer              sample_cntr;
   initial begin
      $display("INFO: Testing Register Writes");
      // Initial Values for Registers-----------------
      wb_clk_i_tb  = 0;
      wb_rst_i_tb  = 0;
      wb_dat_i_tb  = 0;
      wb_addr_i_tb = 0;
      wb_we_i_tb   = 0;
      wb_stb_i_tb  = 0;
      dds_clk_i_tb = 0;

      read_data    = 0;
      read_addr    = 0;

      // Reset DUT------------------------------------
      @ (negedge wb_clk_i_tb);
      wb_rst_i_tb = 1;
      repeat (5) @ (posedge wb_clk_i_tb);
      wb_rst_i_tb = 0;
      @ (posedge wb_clk_i_tb);
      // Test Register R/W----------------------------
      randomize_test();
      run_reg_test();
      run_wave_test();
      #1000 $display("INFO: Test Complete");
      $finish;
   end // initial begin



   task wb_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
      begin
         $display("INFO: WB Writing 0x%h to 0x%h", data, addr);

         @ (negedge wb_clk_i_tb); // Sync to non sample edge
         wb_we_i_tb   = 1;
         wb_addr_i_tb = addr;
         wb_dat_i_tb  = data;
         wb_stb_i_tb = 1;
         @ (posedge wb_clk_i_tb); // Write to the DUT
         @ (posedge wb_clk_i_tb); // Get an ACK next cycle
         if (wb_ack_o_tb) $display("INFO: WB Wrote 0x%h to 0x%h", data, addr);
         else $display("ERROR: WB Write %h to 0x%h failed. No ACK", data, addr); wb_stb_i_tb = 0; // TR over
      end
   endtask // wb_write

   task wb_read(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data);
      begin
         $display("INFO: WB read from 0x%h", addr);

         @ (negedge wb_clk_i_tb); // Sync to non sample edge
         wb_we_i_tb   = 0;
         wb_addr_i_tb = addr;
         wb_stb_i_tb = 1;
         @ (posedge wb_clk_i_tb); // Write to the DUT
         @ (posedge wb_clk_i_tb); // Get an ACK next cycle and read data
         data = wb_dat_o_tb;
         if (wb_ack_o_tb) $display("INFO: WB read 0x%h from 0x%h", data, addr);
         else $display("ERROR: WB Read from 0x%h failed. No ACK", addr);
         wb_stb_i_tb = 0; // TR over
      end
   endtask // wb_read

   task run_reg_test();
      begin

         // Ensure DUT Reset Complete and DUT is ready
         while(read_data !== 32'd1) begin
            wb_read(READY, read_data);
         end

         // Read and assert proper reset values
         wb_read(ENABLE, read_data);
         if(!(read_data === ENABLE_RST_VAL)) $display("ERROR: ENABLE reset to wrong value: 0x%h", read_data);
         wb_read(DDS_SRC, read_data);
         if(!(read_data === DDS_SRC_RST_VAL)) $display("ERROR: DDS_SRC reset to wrong value: 0x%h", read_data);
         wb_read(TUNING_WORD, read_data);
         if(!(read_data === TUNING_WORD_RST_VAL)) $display("ERROR: TUNING_WORD reset to wrong value: 0x%h", read_data);
         wb_read(GAIN_WORD, read_data);
         if(!(read_data === GAIN_WORD_RST_VAL)) $display("ERROR: GAIN_WORD reset to wrong value: 0x%h", read_data);
         wb_read(OFFSET_WORD, read_data);
         if(!(read_data === OFFSET_WORD_RST_VAL)) $display("ERROR: OFFSET_WORD reset to wrong value: 0x%h", read_data);

         // Set
         wb_write(READY, 32'hffff_ffff);
         wb_write(ENABLE, 32'hffff_ffff);
         wb_write(DDS_SRC, 32'hffff_ffff);
         wb_write(TUNING_WORD, 32'hffff_ffff);
         wb_write(GAIN_WORD, 32'hffff_ffff);
         wb_write(OFFSET_WORD, 32'hffff_ffff);

         // Read and assert proper bit fields were set
         wb_read(ENABLE, read_data);
         if(!(read_data[0] === 1'b1)) $display("ERROR: ENABLE reset to wrong value: 0x%h", read_data);
         wb_read(DDS_SRC, read_data);
         if(!(read_data[1:0] === 2'b11)) $display("ERROR: DDS_SRC reset to wrong value: 0x%h", read_data);
         wb_read(TUNING_WORD, read_data);
         if(!(read_data[7:0] === 8'hff)) $display("ERROR: TUNING_WORD reset to wrong value: 0x%h", read_data);
         wb_read(GAIN_WORD, read_data);
         if(!(read_data[1:0] === 2'b11)) $display("ERROR: GAIN_WORD reset to wrong value: 0x%h", read_data);
         wb_read(OFFSET_WORD, read_data);
         if(!(read_data[15:0] === 16'hffff)) $display("ERROR: OFFSET_WORD reset to wrong value: 0x%h", read_data);

         // Clear
         wb_write(READY, 32'd0);
         wb_write(ENABLE, 32'd0);
         wb_write(DDS_SRC, 32'd0);
         wb_write(TUNING_WORD, 32'd0);
         wb_write(GAIN_WORD, 32'd0);
         wb_write(OFFSET_WORD, 32'd0);

         // Read and assert proper bit fields were cleared
         wb_read(ENABLE, read_data);
         if(!(read_data[0] === 1'b0)) $display("ERROR: ENABLE reset to wrong value: 0x%h", read_data);
         wb_read(DDS_SRC, read_data);
         if(!(read_data[1:0] === 2'b00)) $display("ERROR: DDS_SRC reset to wrong value: 0x%h", read_data);
         wb_read(TUNING_WORD, read_data);
         if(!(read_data[7:0] === 8'h00)) $display("ERROR: TUNING_WORD reset to wrong value: 0x%h", read_data);
         wb_read(GAIN_WORD, read_data);
         if(!(read_data[1:0] === 2'b00)) $display("ERROR: GAIN_WORD reset to wrong value: 0x%h", read_data);
         wb_read(OFFSET_WORD, read_data);
         if(!(read_data[15:0] === 16'h0000)) $display("ERROR: OFFSET_WORD reset to wrong value: 0x%h", read_data);
      end
   endtask // run_reg_test


   integer rand_1;
   integer rand_2;
   task randomize_test();
      begin
         // Randomize Test Environment and Print It To Log
         rand_1         = $urandom(seed);
         rand_2         = $urandom(seed);
         //dds_src_tb     = {30'd0, rand_1[1:0]};
         //tuning_word_tb = {24'd0, rand_2[23:16]};
         //gain_word_tb   = {30'd0, rand_1[3:2]};
         //offset_word_tb = {16'd0, rand_2[15:0]};

         // Temp Overrides
         dds_src_tb     = {30'd0, 2'b00};
         tuning_word_tb = {24'd0, 7'h01};
         gain_word_tb   = {30'd0, 2'b00};
         offset_word_tb = 16'h7fff;

         $display("---------------------------------------------------------------------------");
         case(dds_src_tb[1:0])
            2'b00 : $display("INFO: DDS_SRC: SINE");
            2'b01 : $display("INFO: DDS_SRC: SAW");
            2'b10 : $display("INFO: DDS_SRC: TRI");
            2'b11 : $display("INFO: DDS_SRC: RAND");
         endcase // case (dds_src_tb[1:0])
         $display("INFO: TUNING_WORD 0x%h", tuning_word_tb[7:0]);
         case(gain_word_tb[1:0])
            2'b00 : $display("INFO GAIN_WORD: x1");
            2'b01 : $display("INFO GAIN_WORD: x2");
            2'b10 : $display("INFO GAIN_WORD: x4");
            2'b11 : $display("INFO GAIN_WORD: x8");
         endcase
         $display("INFO: OFFSET_WORD 0x%h", offset_word_tb[15:0]);
         $display("---------------------------------------------------------------------------");
      end
   endtask // randomize_test

   task run_wave_test();
      begin
         wb_write(DDS_SRC, dds_src_tb);
         wb_write(TUNING_WORD, tuning_word_tb);
         wb_write(GAIN_WORD, gain_word_tb);
         wb_write(OFFSET_WORD, offset_word_tb);
         wb_write(ENABLE, 32'd1);
         for(sample_cntr = 0; sample_cntr < 500 ; sample_cntr++) begin
            @ (posedge dds_clk_i_tb) $display("INFO: sample:%d value:%d", sample_cntr, wave_o_tb);
         end
      end
   endtask // run_test

endmodule // simple_dds_tb

