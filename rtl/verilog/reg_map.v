module reg_map (/*AUTOARG*/ ) ;
   reg [DATA_WIDTH-1:0]         reg_map [5:0];
   wire                         map_wr_en;
   wire [ADDR_WIDTH-1:0]        map_wr_addr;
   wire [DATA_WIDTH-1:0]        map_wr_data;
endmodule // reg_map
