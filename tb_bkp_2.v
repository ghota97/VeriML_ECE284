// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 


module tb_ref;

	parameter num = 2048;	
	parameter num_inp = 8;
	parameter bw = 7;
	parameter col = 4;
	parameter row = 4;
	parameter psum_bw = 16;
	
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
	
	integer  w[row-1:0][col-1:0];
	
	
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
	
	integer k;
	integer iter,iters;

	initial begin 
	 	acc = 1;
	 	$dumpfile("tb_ref.vcd");
	 	$dumpvars(0,tb_ref);
	 	#1 clk = 1'b0;  
	 	#1 reset = 1'b1;
	 	#1 clk = 1'b1;  
	 	#1 clk = 1'b0;
	 	#1 reset = 1'b0;
	 	#1 cen = 0;

		for( iter = 0; iter<9;iter=iter+1) begin
		    fork
		    	begin
				wr = 1; mode = 0; 
				#1 clk = 1'b1 ; #1 clk = 1'b0;
		 		w_file = $fopen("b_data.txt", "r");  //weight data
		 		w_vector_bin = 0;
		 		for (i=0; i<row; i=i+1) begin
		 		   for (j=0; j<col; j=j+1) begin
		 		      w_scan_file = $fscanf(w_file, "%d\n", captured_data);
		 		      w_vector_bin = {captured_data,w_vector_bin[bw*col-1:bw]};//{binary, w_vector_bin[bw*col-1:bw]};
		 		   end
				#1 clk = 1'b1 ; #1 clk = 1'b0;
				end
		 		a_file = $fopen("a_data.txt", "r");  //activation data
				w_vector_bin = 0;
		 		for (i=0; i<num_inp; i=i+1) begin
		 		   for (j=0; j<col; j=j+1) begin
		 		      w_scan_file = $fscanf(a_file, "%d\n", captured_data);
		 		      w_vector_bin = {captured_data,w_vector_bin[bw*col-1:bw]};//{binary, w_vector_bin[bw*col-1:bw]};
		 		   end
				   #1 clk = 1'b1 ; #1 clk = 1'b0;
				   if(i==num_inp-2)
				   	wr = 0;
				end
			end
		        begin
				#1 clk = 1'b1 ; #1 clk = 1'b0;
				rd = 1; 
				for(k=0;k<row;k=k+1)begin
					inst_w = 2'b01;	
					mode = 0;
					#1 clk = 1'b1 ; #1 clk = 1'b0;
				end
				rd = 0;	
				#1 clk = 1'b1 ; #1 clk = 1'b0;
				for(k=0;k<num_inp;k=k+1)begin
					inst_w = 2'b10;	
					mode = 1;
					rd = 1;	
					#1 clk = 1'b1 ; #1 clk = 1'b0;
				end
				inst_w = 2'b00;
				rd = 0;	
				#1 clk = 1'b1 ; #1 clk = 1'b0;
				for(k=0;k<col+row+1;k=k+1)begin
				    #1 clk = 1'b1 ; #1 clk = 1'b0;
				end
			end
		  join
	    end
	end
endmodule





