// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 


module tb;

parameter bw = 6;
parameter col = 4;
parameter row = 4;
parameter psum_bw = 16;
parameter total_cycle = 4;
parameter total_cycle_2nd = 8;

wire mode ;
wire [1:0] inst_w;
wire [col*psum_bw-1:0] psum_bus;
assign mode = 0;
assign inst_w = 2'b01;
reg clk = 0;
reg rd = 0;
reg rd_ofifo = 0;
reg wr = 0;
reg  reset = 0;
reg [bw*col-1:0] w_vector_bin;
wire [bw*col-1:0] out;
wire full, ready,o_ready,o_valid,o_full;

integer w_file ; // file handler
integer w_scan_file ; // file handler
integer captured_data;
reg [bw-1:0] binary;
integer i; 
integer j; 
integer u; 

integer  w[total_cycle-1:0][col-1:0];



function [3:0] w_bin ;
  input integer  weight ;
  begin

    if (weight>-1)
     w_bin[5] = 0;
    else begin
     w_bin[5] = 1;
     weight = weight + 32;
    end
    if (weight>17)
     w_bin[4] = 0;
    else begin
     w_bin[4] = 1;
     weight = weight -16;
    end

    if (weight>7)
     w_bin[3] = 0;
    else begin
     w_bin[3] = 1;
     weight = weight - 8;
    end

    if (weight>3) begin
     w_bin[2] = 1;
     weight = weight - 4;
    end
    else 
     w_bin[2] = 0;

    if (weight>1) begin
     w_bin[1] = 1;
     weight = weight - 2;
    end
    else 
     w_bin[1] = 0;

    if (weight>0) 
     w_bin[0] = 1;
    else 
     w_bin[0] = 0;

  end
endfunction

core #(.bw(bw),.row(row),.col(col),.psum_bw(psum_bw)) core_instance(
	.clk(clk),
	.reset(reset),
	.inst_w(inst_w),
	.mode(mode),
	.in_l0(w_vector_bin),
	.rd_l0(rd),
	.wr_l0(wr),
	.rd_ofifo(rd_ofifo),
	.psum_mem_bus(psum_bus),
	.o_full(o_full),
	.o_ready(o_ready),
	.o_valid(o_valid),
	.out_l0(out),
	.full_l0(full),
	.ready_l0(ready)
);

initial begin 

  w_file = $fopen("b_data.txt", "r");  //weight data

  $dumpfile("tb.vcd");
  $dumpvars(0,tb);
 
  #1 clk = 1'b0;  
  #1 reset = 1'b1;
  #1 clk = 1'b1;  
  #1 clk = 1'b0;
  #1 reset = 1'b0;

  $display("-------------------- 1st Computation start --------------------");
  
  wr = 1;
  for (i=0; i<total_cycle; i=i+1) begin

     for (j=0; j<col; j=j+1) begin

        w_scan_file = $fscanf(w_file, "%d\n", captured_data);
	$display(captured_data);
        w[i][j] = captured_data;
        binary = w_bin(w[i][j]);  
        //w_vector_bin = {binary, w_vector_bin[bw*col-1:bw]};
        w_vector_bin = {captured_data,w_vector_bin[bw*col-1:bw]};//{binary, w_vector_bin[bw*col-1:bw]};
     end

     #1 clk = 1'b1;
     #1 clk = 1'b0;

  end

  wr = 0;
  #1 clk = 1'b1;
  #1 clk = 1'b0;

//
//  rd = 1;
//
//  for (i=0; i<2*total_cycle; i=i+1) begin
//     #1 clk = 1'b1;
//     #1 clk = 1'b0;
//  end
//  rd = 0;
//
//  $display("-------------------- 1st Computation completed --------------------");
//
//
//
//
//  $display("-------------------- 2nd Computation start --------------------");
//
//  wr = 1;
//  for (i=0; i<total_cycle_2nd; i=i+1) begin
//
//     for (j=0; j<col; j=j+1) begin
//
//        w_scan_file = $fscanf(w_file, "%d\n", captured_data);
//        w[i][j] = captured_data;
//        binary = w_bin(w[i][j]);  
//        w_vector_bin = {binary, w_vector_bin[bw*col-1:bw]};
//     end
//
//     #1 clk = 1'b1;
//     #1 clk = 1'b0;
//
//  end
//
//  wr = 0;
//  #1 clk = 1'b1;
//  #1 clk = 1'b0;
//
//
//  rd = 1;
//
//  for (i=0; i<2*total_cycle_2nd; i=i+1) begin
//     #1 clk = 1'b1;
//     #1 clk = 1'b0;
//  end
//  rd = 0;
//
//  $display("-------------------- 2nd Computation completed --------------------");
//
//  #10 $finish;
//

end

endmodule





