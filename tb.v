// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 


module tb;

parameter num = 2048;	
parameter num_inp = 8;
parameter bw = 7;
parameter col = 4;
parameter row = 4;
parameter psum_bw = 16;
parameter total_cycle = 4;
parameter total_cycle_2nd = 8;

reg cen = 1;
reg acc = 1;
wire psum_wr;
wire relu;
wire [col*psum_bw-1:0]psum_mem_dout;
wire [col*psum_bw-1:0]psum_mem_din;
reg mode ;
reg [1:0] inst_w;
wire [col*psum_bw-1:0] psum_bus;
reg clk = 0;
reg rd = 0;
reg rd_ofifo = 0;
reg wr = 0;
reg  reset = 0;
reg [bw*col-1:0] w_vector_bin;
wire [bw*col-1:0] out;
wire full, ready,o_ready,o_valid,o_full;

integer w_file ; // file handler
integer a_file ; // file handler
integer w_scan_file ; // file handler
integer captured_data;
reg [bw-1:0] binary;
integer i; 
integer j; 
integer u; 

integer  w[total_cycle-1:0][col-1:0];


core #(.bw(bw),.row(row),.col(col),.psum_bw(psum_bw),.num_inp(num_inp),.num(num)) core_instance(
	.acc(acc),
	.relu(relu),
	.clk(clk),
	.reset(reset),
	.inst_w(inst_w),
	.mode(mode),
	.in_l0(w_vector_bin),
	.rd_l0(rd),
	.wr_l0(wr),
	.cen(cen),
	.o_full(o_full),
	.o_ready(o_ready),
	.out_l0(out),
	.full_l0(full),
	.ready_l0(ready)
);

initial begin 
  acc = 1;
  mode = 0;
  w_file = $fopen("b_data.txt", "r");  //weight data

  $dumpfile("tb.vcd");
  $dumpvars(0,tb);
 
  #1 clk = 1'b0;  
  #1 reset = 1'b1;
  #1 clk = 1'b1;  
  #1 clk = 1'b0;
  #1 reset = 1'b0;
  #1 cen = 0;
  $display("-------------------- 1st Computation start --------------------");
  
  wr = 1;
     #1 clk = 1'b1;
     #1 clk = 1'b0;
  for (i=0; i<total_cycle; i=i+1) begin

     for (j=0; j<col; j=j+1) begin

        w_scan_file = $fscanf(w_file, "%d\n", captured_data);
        w[i][j] = captured_data;
//        binary = w_bin(w[i][j]);  
        //w_vector_bin = {binary, w_vector_bin[bw*col-1:bw]};
        w_vector_bin = {captured_data,w_vector_bin[bw*col-1:bw]};//{binary, w_vector_bin[bw*col-1:bw]};
     end

     #1 clk = 1'b1;
     #1 clk = 1'b0;

  end

  wr = 0;
  #1 clk = 1'b1;
  #1 clk = 1'b0;


  rd = 1;

  inst_w = 2'b01;
     #1 clk = 1'b1;
     #1 clk = 1'b0;
  for (i=0; i<total_cycle; i=i+1) begin
     #1 clk = 1'b1;
     #1 clk = 1'b0;
  end
  rd = 0;

  $display("-------------------- Weight Loading first interation completed --------------------");


  a_file = $fopen("a_data.txt", "r");  //weight data

  #1 clk = 1'b0;  
  #1 clk = 1'b1;  

  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  wr = 1;
  #1 clk = 1'b1;
  #1 clk = 1'b0;
  for (i=0; i<total_cycle_2nd; i=i+1) begin
     for (j=0; j<col; j=j+1) begin
        w_scan_file = $fscanf(a_file, "%d\n", captured_data);
        w[i][j] = captured_data;
//        binary = w_bin(w[i][j]);  
        //w_vector_bin = {binary, w_vector_bin[bw*col-1:bw]};
        w_vector_bin = {captured_data,w_vector_bin[bw*col-1:bw]};//{binary, w_vector_bin[bw*col-1:bw]};
     end

     #1 clk = 1'b1;
     #1 clk = 1'b0;

  end

  wr = 0;
  #1 clk = 1'b1;
  #1 clk = 1'b0;

  mode = 1;
  rd = 1;

  inst_w = 2'b10;

  for (i=0; i<total_cycle_2nd; i=i+1) begin
     #1 clk = 1'b1;
     #1 clk = 1'b0;
  end
  rd = 0;
  inst_w = 2'b00;
  $display("-------------------- 1st Computation completed --------------------");
  for (i=0; i<total_cycle_2nd; i=i+1) begin
     #1 clk = 1'b1;
     #1 clk = 1'b0;
  end
  $display("-------------------- 2nd Computation started --------------------");

 wr = 1;
     #1 clk = 1'b1;
     #1 clk = 1'b0;
  for (i=0; i<total_cycle; i=i+1) begin

     for (j=0; j<col; j=j+1) begin

        w_scan_file = $fscanf(w_file, "%d\n", captured_data);
        w[i][j] = captured_data;
//        binary = w_bin(w[i][j]);  
        //w_vector_bin = {binary, w_vector_bin[bw*col-1:bw]};
        w_vector_bin = {captured_data,w_vector_bin[bw*col-1:bw]};//{binary, w_vector_bin[bw*col-1:bw]};
     end

     #1 clk = 1'b1;
     #1 clk = 1'b0;

  end

  wr = 0;
  #1 clk = 1'b1;
  #1 clk = 1'b0;


  rd = 1;

  inst_w = 2'b01;
     #1 clk = 1'b1;
     #1 clk = 1'b0;
  for (i=0; i<total_cycle; i=i+1) begin
     #1 clk = 1'b1;
     #1 clk = 1'b0;
  end
  rd = 0;

  $display("-------------------- Weight Loading first interation completed --------------------");


  a_file = $fopen("a_data.txt", "r");  //weight data

  #1 clk = 1'b0;  
  #1 clk = 1'b1;  

  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  wr = 1;
  #1 clk = 1'b1;
  #1 clk = 1'b0;
  for (i=0; i<total_cycle_2nd; i=i+1) begin
     for (j=0; j<col; j=j+1) begin
        w_scan_file = $fscanf(a_file, "%d\n", captured_data);
        w[i][j] = captured_data;
//        binary = w_bin(w[i][j]);  
        //w_vector_bin = {binary, w_vector_bin[bw*col-1:bw]};
        w_vector_bin = {captured_data,w_vector_bin[bw*col-1:bw]};//{binary, w_vector_bin[bw*col-1:bw]};
     end

     #1 clk = 1'b1;
     #1 clk = 1'b0;

  end

  wr = 0;
  #1 clk = 1'b1;
  #1 clk = 1'b0;

  mode = 1;
  rd = 1;

  inst_w = 2'b10;

  for (i=0; i<total_cycle_2nd; i=i+1) begin
     #1 clk = 1'b1;
     #1 clk = 1'b0;
  end
  inst_w = 2'b00;
  rd = 0;
  for (i=0; i<total_cycle_2nd; i=i+1) begin
     #1 clk = 1'b1;
     #1 clk = 1'b0;
  end
  $display("-------------------- 1st Computation completed --------------------");

end

endmodule





