// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module tb;

	parameter num = 2048;	
	parameter num_inp = 64;
	parameter kij_len = 9;
	parameter bw = 4;
	parameter col = 8;
	parameter row = 8;
	parameter psum_bw = 16;
	reg [psum_bw-1:0] temp;
	reg cen = 1;
	reg acc = 1;
    	reg inp_sram_ceni = 0;
    	reg inp_sram_weni = 0;
    	reg inp_sram_cenw = 0;
    	reg inp_sram_wenw = 0;
	reg clk_gating_enable = 0;
	wire psum_wr;
	wire relu;
	wire [col*psum_bw-1:0]psum_mem_dout;
	wire [col*psum_bw-1:0]psum_mem_din;
	wire mode ;
	wire [1:0] inst_w;
	wire [col*psum_bw-1:0] psum_bus;
	reg clk = 0;
    	reg [10:0] Ai = 0;
    	reg [10:0] Aw = 0;
	wire rd ;
	reg rd_ofifo = 0;
	wire wr ;
	reg w_x;
	reg  reset = 0;
	reg [bw*col-1:0] w_vector_bini;
	reg [bw*col-1:0] w_vector_binw;
    	reg [bw*col-1:0] D_2D_in[255:0];
	wire [bw*col-1:0] out;
	wire full, ready,o_ready,o_valid,o_full;
	wire compute_done;	
	integer w_file ; // file handler
	integer a_file ; // file handler
	integer out_file ;
	integer w_scan_file ; // file handler
	integer w_scan_file_ref ; // file handler
	integer captured_data;
	integer captured_data_ref;
	integer psum_file_ref;
	integer psum_file;
	integer err_count = 0;
	reg [bw-1:0] binary;
	integer i; 
	integer j; 
	integer u; 
	wire iter_done ;
	reg start = 0;
	integer  w[row-1:0][col-1:0];
	reg psum_rd = 0;
	controller #(.row(row),.col(col),.num_inp(num_inp),.kij_len(kij_len)) controller_instance(
	.start(start),
	.clk(clk),
	.reset(reset),
	.wr(wr),
	.rd(rd),
	.mode(mode),
	.inst_w(inst_w),
	.clk_gating_enable(clk_gating_enable),
	.clk_gating_enable_sramw(inp_sram_cenw),
	.clk_gating_enable_srami(inp_sram_ceni),
	.compute_done(compute_done),
	.iter_done(iter_done),
	.sramw_gated_clk(sramw_gated_clk),
	.srami_gated_clk(srami_gated_clk)
);
	
	core #(.bw(bw),.row(row),.col(col),.psum_bw(psum_bw),.num_inp(num_inp),.num(num)) core_instance(
		.acc(acc),
		.relu(relu),
		.clk(clk),
		.reset(reset),
		.inst_w(inst_w),
		.mode(mode),
		.Di(w_vector_bini),
		.Dw(w_vector_binw),
		.rd_l0(rd),
		.wr_l0(wr),
		.cen(cen),
		.o_full(o_full),
		.o_ready(o_ready),
		.out_l0(out),
		.full_l0(full),
		.ready_l0(ready),
		.Ai(Ai),
		.Aw(Aw),
        	.inp_sram_ceni(inp_sram_ceni),
        	.inp_sram_weni(inp_sram_weni),
        	.inp_sram_cenw(inp_sram_cenw),
        	.inp_sram_wenw(inp_sram_wenw),
		.psum_rd(psum_rd),
		.psum_mem_dout(psum_mem_dout),
		.w_x(w_x),
		.clk_gating_enable(clk_gating_enable),
		.sramw_gated_clk(sramw_gated_clk),
		.srami_gated_clk(srami_gated_clk)
);
	
	integer k;
    	integer t = 0;
	integer iter,iters;
	always #1 clk = ~clk;
	initial begin 
	 	$dumpfile("tb.vcd");
	 	$dumpvars(0,tb);
		$display("Simulation start = 1 \n");
		#1 start =0;
	 	acc = 1;
		reset = 0; 
		clk_gating_enable = 0;
		#2 reset = 1; 
		#2 reset = 0;
		inp_sram_ceni = 0; inp_sram_cenw=0;
	 	cen = 0;
        	inp_sram_weni = 0; inp_sram_wenw=0;
		Ai=0; Aw=0;
		w_file = $fopen("b_data_9.txt", "r");  //weight data
		for(iter = 0; iter<kij_len;iter=iter+1) begin
		 	w_vector_binw = 0;
	//		for(iters = 0; iters<iter;iters=iters+1) 
	//	 		for (i=0; i<row; i=i+1) 
	//	 	   		for (j=0; j<col; j=j+1) 
	//	 	      			w_scan_file = $fscanf(w_file, "%d\n", captured_data);
			
		 	for (i=0; i<row; i=i+1) begin
		 	   for (j=0; j<col; j=j+1) begin
		 	      w_scan_file = $fscanf(w_file, "%d\n", captured_data);
		 	      w_vector_binw = {captured_data,w_vector_binw[bw*col-1:bw]};//{binary, w_vector_bin[bw*col-1:bw]};
		 	      D_2D_in[t][31:0] = w_vector_binw;
                  	      t++;
              		    end
		 	    #2 Aw = Aw + 1;
		 	end

	//		$fclose(w_file);
		end
		$fclose(w_file);
		$display("Loaded Weight SRAM with all the weights required for 3x3 iterations successfully");
        	inp_sram_cenw = 1; 
		a_file = $fopen("a_data.txt", "r");  //activation data
		w_vector_bini = 0;
		for (i=0; i<num_inp; i=i+1) begin
		   for (j=0; j<col; j=j+1) begin
		      w_scan_file = $fscanf(a_file, "%d\n", captured_data);
		      w_vector_bini = {captured_data,w_vector_bini[bw*col-1:bw]};//{binary, w_vector_bin[bw*col-1:bw]};
		      D_2D_in[t][31:0] = w_vector_bini;
                      t++;
            	    end
		    #2 Ai = Ai + 1;
		end
		$fclose(a_file);
		$display("Loaded Activation SRAM with all the input activations reused for 3x3 iterations successfully \n");
        	inp_sram_ceni = 1; 
        	inp_sram_weni = 1; 
        	inp_sram_wenw = 1; 
		Ai = 0;
		Aw = 0;
		start = 1;
		//#2;
		for( iter = 0; iter < kij_len; iter=iter+1) begin
			inp_sram_cenw = 0; 	
			w_x = 1;
			#2
			for(i =0;i<row;i++) 
				#2 Aw = Aw + 1;
			//#2
			inp_sram_cenw = 1; 	
			inp_sram_ceni = 0; 	
			w_x = 0;
			for(i =0;i<num_inp;i++) 
				#2 Ai = Ai + 1;
			//#2
			inp_sram_ceni = 1; 	
			Ai=0;
			wait(iter_done);
			$display("Loaded Weights and then Activations into L0 Fifo. Mac Array Computation iteration Done, iter value = ",iter);
			#2 reset = 1'b1;
			#2 reset = 1'b0;
		end
		wait(compute_done);
		$display("Convolution Done");
		psum_rd = 1;
		$display("Reading from psum to output_psum.txt");
		out_file = $fopen("output_psum_clk_gating_enabled.txt","w");
		for (i=0; i <num_inp; i++)begin
			#2;
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
	        end
	        $fclose(out_file);
	        psum_rd = 0;

	        psum_file_ref = $fopen("sum_ref.txt", "r");  //psum data
	        psum_file = $fopen("output_psum_clk_gating_enabled.txt", "r");  //psum data
		$display("Comparing output_psum.txt to psum_ref.txt");
	        for (i=0; i<num_inp; i=i+1) begin
	           for (j=0; j<col; j=j+1) begin
	           	    w_scan_file_ref = $fscanf(psum_file_ref, "%d\n", captured_data_ref);	
	           	    w_scan_file = $fscanf(psum_file, "%d\n", captured_data);	
	           	    if(captured_data !== captured_data_ref)begin
	        	    	$display(captured_data , captured_data_ref);
	        	    	$display("Error in Output Generated and Reference at %d Row, %d Column",i+1,j+1);
	        	    	err_count++;
	                end
	           end
	        end
	        if(err_count === 0)
	        	$display("All the outputs matched, QuantConvolution Successfully implemented in Hardware");
	        $fclose(psum_file);
	        $fclose(psum_file_ref);
	        $finish;
	end
endmodule





