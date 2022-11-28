// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1ns/1ps
module tb;

	parameter num = 2048;	
	parameter num_inp = 64;
	parameter kij_len = 1;
	parameter bw = 4;
	parameter col = 8;
	parameter row = 8;
	parameter psum_bw = 16;
	reg [psum_bw-1:0] temp;
	reg cen = 1;
	reg acc = 1;
    	reg inp_sram_cen = 0;
    	reg inp_sram_wen = 0;
	wire psum_wr;
	wire relu;
	wire [col*psum_bw-1:0]psum_mem_dout;
	wire [col*psum_bw-1:0]psum_mem_din;
	wire mode ;
	wire [1:0] inst_w;
	wire [col*psum_bw-1:0] psum_bus;
	reg clk = 0;
    	reg [10:0] A = 0;
	wire rd ;
	reg rd_ofifo = 0;
	wire wr ;
	reg  reset = 0;
	reg [bw*col-1:0] w_vector_bin;
    	reg [bw*col-1:0] D_2D_in[255:0];
	wire [bw*col-1:0] out;
	wire full, ready,o_ready,o_valid,o_full;
	wire compute_done;	
	integer w_file ; // file handler
	integer a_file ; // file handler
	integer out_file ;
	integer w_scan_file ; // file handler
	integer captured_data;
	reg [bw-1:0] binary;
	integer i; 
	integer j; 
	integer u; 
	wire iter_done;
	reg start = 0;
	integer  w[row-1:0][col-1:0];
	reg psum_rd;
	controller #(.row(row),.col(col),.num_inp(num_inp),.kij_len(kij_len)) controller_instance(
	.start(start),
	.clk(clk),
	.reset(reset),
	.wr(wr),
	.rd(rd),
	.mode(mode),
	.inst_w(inst_w),
	.compute_done(compute_done),
	.iter_done(iter_done)
);
	
	core #(.bw(bw),.row(row),.col(col),.psum_bw(psum_bw),.num_inp(num_inp),.num(num)) core_instance(
		.acc(acc),
		.relu(relu),
		.clk(clk),
		.reset(reset),
		.inst_w(inst_w),
		.mode(mode),
		.D(w_vector_bin),
		.rd_l0(rd),
		.wr_l0(wr),
		.cen(cen),
		.o_full(o_full),
		.o_ready(o_ready),
		.out_l0(out),
		.full_l0(full),
		.ready_l0(ready),
		.A(A),
        	.inp_sram_cen(inp_sram_cen),
        	.inp_sram_wen(inp_sram_wen),
		.psum_rd(psum_rd),
		.psum_mem_dout(psum_mem_dout));
	
	integer k;
    	integer t = 0;
	integer iter,iters;
	always #1 clk = ~clk;
	initial begin 
	 	$dumpfile("tb_dbasu.vcd");
	 	$dumpvars(0,tb);
		$display("Simulation about to begin \n");
		for(iter = 0; iter<kij_len;iter=iter+1) begin
			#4;
			$display("Iteration No =%d \n",iter);
			inp_sram_cen = 0;
			start =0;
		 	w_file = $fopen("b_data.txt", "r");  //weight data
		 	w_vector_bin = 0;
			#2 reset = 1'b1;
	 		#2 reset = 1'b0;
	 		acc = 1;
 			//#2 reset = 1'b1;
	 		//#2 reset = 1'b0;
	 		#2 cen = 0;
			//#2 start = 1;
        		#2 inp_sram_wen = 0; 
			/*
			for(iters = 0; iters<iter;iters=iters+1) 
		 		for (i=0; i<row; i=i+1) 
		 	   		for (j=0; j<col; j=j+1) 
		 	      			w_scan_file = $fscanf(w_file, "%d\n", captured_data);
			*/
		 	for (i=0; i<row; i=i+1) begin
		 	   for (j=0; j<col; j=j+1) begin
		 	      w_scan_file = $fscanf(w_file, "%d\n", captured_data);
		 	      w_vector_bin = {captured_data,w_vector_bin[bw*col-1:bw]};//{binary, w_vector_bin[bw*col-1:bw]};
		 	      D_2D_in[t][31:0] = w_vector_bin;
                  	      t++;
              		end
		 	   #2 A = A + 1;
		 	end

			$display("Loading of b_data.txt done \n");
			$fclose(w_file);
			$display("Loading of a_data.txt about to begin \n");
		 	a_file = $fopen("a_data.txt", "r");  //activation data
		 	w_vector_bin = 0;
		 	for (i=0; i<num_inp; i=i+1) begin
		 	   for (j=0; j<col; j=j+1) begin
		 	      w_scan_file = $fscanf(a_file, "%d\n", captured_data);
		 	      w_vector_bin = {captured_data,w_vector_bin[bw*col-1:bw]};//{binary, w_vector_bin[bw*col-1:bw]};
		 	      D_2D_in[t][31:0] = w_vector_bin;
                  	      t++;
            		end
		 	   #2 A = A + 1;
		 	end
			$display("Loading of a_data.txt done \n");
			$fclose(a_file);
			/*
			#2 reset = 1'b1;
	 		#2 reset = 1'b0;
	 		acc = 1;
 			#2 reset = 1'b1;
	 		#2 reset = 1'b0;
	 		#2 cen = 0;
			#2 start = 1;
        		#2 inp_sram_wen = 0; 
			*/
			inp_sram_cen = 0;
        
			start = 1;
			#2 inp_sram_wen = 1; A = 0;
			
			for(i =0;i<row;i++) begin
				#2 A = A + 1;
			end

			// inp_sram_cen = 1;

			// #2 inp_sram_cen = 0; inp_sram_wen = 1;

			for(i=0;i<num_inp;i++) begin
				#2 A = A + 1;
			end
        	
			#2 	inp_sram_wen = 0; inp_sram_cen = 1;
	       
		
		$display("Iter Done Value =%d \n",iter_done);
		wait(iter_done);
		$display("Iter Done Value =%d \n",iter_done);
		#2 reset = 1'b1;
		#2 reset = 1'b0;
		end
		wait(compute_done);
		psum_rd = 1;
		#2;
		$display("Reading from psum to output_dbasu.txt");
		out_file = $fopen("output_psum_dbasu.txt","w");
		for (i=0; i <num_inp; i++)begin
		temp = psum_mem_dout[(0+1)*psum_bw-1:psum_bw*0];
		$fwrite(out_file,"%d",$signed(temp));
		temp = psum_mem_dout[(1+1)*psum_bw-1:psum_bw*1];
		$fwrite(out_file,"%d",$signed(temp));
		temp = psum_mem_dout[(2+1)*psum_bw-1:psum_bw*2];
		$fwrite(out_file,"%d",$signed(temp));
		temp = psum_mem_dout[(3+1)*psum_bw-1:psum_bw*3];
		$fwrite(out_file,"%d",$signed(temp));
		temp = psum_mem_dout[(4+1)*psum_bw-1:psum_bw*4];
		$fwrite(out_file,"%d",$signed(temp));
		temp = psum_mem_dout[(5+1)*psum_bw-1:psum_bw*5];
		$fwrite(out_file,"%d",$signed(temp));
		temp = psum_mem_dout[(6+1)*psum_bw-1:psum_bw*6];
		$fwrite(out_file,"%d",$signed(temp));
		temp = psum_mem_dout[(7+1)*psum_bw-1:psum_bw*7];
		$fwrite(out_file,"%d",$signed(temp));
		$fwrite(out_file,"\n");
	        #2;
	    end
		psum_rd = 0;
		$finish;
	end
endmodule





