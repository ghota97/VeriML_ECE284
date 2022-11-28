// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module l0 (clk, in, out, rd, mode,wr, o_full, reset, o_ready);

  parameter row  = 8;
  parameter bw = 4;
  parameter col = 8;

  input  clk;
  input  wr;
  input  rd;
  input mode;
  input  reset;
  input  [row*bw-1:0] in;
  output [row*bw-1:0] out;
  output o_full;
  output o_ready;

//  reg [4:0] counter;
  wire [row-1:0] empty;
  wire [row-1:0] full;
  reg [row-1:0] rd_en;
  reg [row-1:0] wr_en;
  

  assign o_ready = ~o_full ;
  assign o_full  = |(full);

  genvar i;
  for (i=0; i<row ; i=i+1) begin : row_num
      fifo_depth64 #(.bw(bw)) fifo_instance (
         .rd_clk(clk),
         .wr_clk(clk),
         .rd(rd_en[i]),
         .wr(wr_en[i]),
         .o_empty(empty[i]),
         .o_full(full[i]),
         .in(in[(i+1)*bw-1 : i*bw]),
         .out(out[(i+1)*bw-1 : i*bw]),
         .reset(reset));
  end


  always @ (posedge clk) begin
   if (reset) 
      rd_en <= 0;
  else if(mode == 0)
      /////////////// version1: read all row at a time ////////////////
       rd_en <= {(row){rd}};
  else if (mode ==1)
      //////////////// version2: read 1 row at a time /////////////////
      rd_en <= {rd_en[row-2:0],rd};
  end

  always @ (posedge clk) begin
      if (reset) 
          wr_en <= 8'b00000000;
      else 
	  wr_en <= {(row){wr}};
   end

endmodule
