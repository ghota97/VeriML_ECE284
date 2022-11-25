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
	
	integer k;
	integer witer;
	initial begin 
	 acc = 1;
	 $dumpfile("tb.vcd");
	 $dumpvars(0,tb);
	 #1 clk = 1'b0;  
	 #1 reset = 1'b1;
	 #1 clk = 1'b1;  
	 #1 clk = 1'b0;
	 #1 reset = 1'b0;
	 #1 cen = 0;
	 for(witer = 0; witer<9;witer=witer+1)begin
		 wr = 1;
		 mode = 0;
		 #1 clk = 1'b1;
		 #1 clk = 1'b0;
		 w_file = $fopen("b_data.txt", "r");  //weight data
		 w_vector_bin = 0;
		 for (i=0; i<total_cycle; i=i+1) begin
		    for (j=0; j<col; j=j+1) begin
		       w_scan_file = $fscanf(w_file, "%d\n", captured_data);
		       w_vector_bin = {captured_data,w_vector_bin[bw*col-1:bw]};//{binary, w_vector_bin[bw*col-1:bw]};
		    end
		    #1 clk = 1'b1;
		    #1 clk = 1'b0;
		    if(i==total_cycle-2)begin
			wr = 0;
		 	rd = 1;
		        inst_w = 2'b01;
		    end
		 end
	   	 $fclose(w_file);	
		 for (i=0; i<total_cycle; i=i+1) begin
		    #1 clk = 1'b1;
		    #1 clk = 1'b0;
		 end
		 rd = 0;
		 $display("--------------------Weight Loading first interation completed --------------------");
	  	 for ( k = 0; k<1; k = k+1) begin
	  		wr = 1;
		  	mode = 0;
		  	#1 clk = 1'b1;
		  	#1 clk = 1'b0;
		 	a_file = $fopen("a_data.txt", "r");  //activation data
			w_vector_bin = 0;
			for (i=0; i<total_cycle_2nd; i=i+1) begin
		  	   for (j=0; j<col; j=j+1) begin
		  	      w_scan_file = $fscanf(a_file, "%d\n", captured_data);
		  	      w_vector_bin = {captured_data,w_vector_bin[bw*col-1:bw]};//{binary, w_vector_bin[bw*col-1:bw]};
		  	   end
		  	   #1 clk = 1'b1;
		  	   #1 clk = 1'b0;
		  	   if(i==total_cycle_2nd-2)begin
				wr = 0;
		  	//	mode = 1;rd=1;inst_w=2'b10;
			   end
		  	end
		
			$fclose(a_file);
		  	#1 clk = 1'b1;
		  	#1 clk = 1'b0;
		
	  		mode = 1;rd=1;inst_w=2'b10;
		
		  	for (i=0; i<total_cycle_2nd; i=i+1) begin
		  	   #1 clk = 1'b1;
		  	   #1 clk = 1'b0;
		  	end
		  	rd = 0;
		  	inst_w = 2'b00;
		  	$display("-------------------- %d Computation completed --------------------",k);
		  	for (i=0; i<2*total_cycle_2nd; i=i+1) begin
		  	   #1 clk = 1'b1;
		  	   #1 clk = 1'b0;
		  	end
		  end
		end
	end
endmodule




