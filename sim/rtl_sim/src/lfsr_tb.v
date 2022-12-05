module lfsr_tb (/*AUTOARG*/) ;
   parameter TRACE = 1;

   reg clk_i_tb;
   reg rst_i_tb;
   wire [7:0] rand_o_tb;


   lfsr lfsr0(/*AUTOINST*/
              // Outputs
              .rand_o                   (rand_o_tb),
              // Inputs
              .clk_i                    (clk_i_tb),
              .rst_i                    (rst_i_tb));

   initial begin
      clk_i_tb     = 0;
      rst_i_tb     = 0;
      #10 rst_i_tb = 1;
      #10 rst_i_tb = 0;
      #10000 $finish;
   end

   initial begin
      forever begin
         #10 clk_i_tb = ~clk_i_tb;
      end
   end


   always @ (posedge clk_i_tb) $display("Current Value of Random Out:%d %h", rand_o_tb, rand_o_tb);

   if (TRACE == 1) initial begin
      $dumpfile("../out/wave_lfsr.vcd");
      $dumpvars;
   end


endmodule // lfsr_tb
